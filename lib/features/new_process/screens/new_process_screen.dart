import 'package:flutter/material.dart';

import '../../../core/models/process_model.dart';
import '../../../core/models/service_catalog.dart';
import '../../../core/services/mock/process_catalog_mock_service.dart';
import '../../../core/services/mock/process_submission_mock_service.dart';
import '../../../core/services/process_catalog_service.dart';
import '../../../core/services/process_submission_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../models/new_process_draft.dart';
import '../../account/widgets/account_card.dart';
import '../widgets/step_documents.dart';
import '../widgets/step_request_form.dart';
import '../widgets/step_review.dart';
import '../widgets/wizard_stepper.dart';

enum _LoadState { loading, error, ready }

const _stepLabels = ['Solicitação', 'Documentos', 'Confirmar'];

/// Abertura de protocolo, em 3 passos.
///
/// O estado dos passos mora aqui, no pai. O corpo é um `switch` e não um
/// [IndexedStack]: aquele é um RenderStack, que se dimensiona pelo MAIOR
/// filho — nos passos 2 e 3, que são placeholders curtos, o usuário rolaria a
/// altura inteira do passo 1.
class NewProcessScreen extends StatefulWidget {
  const NewProcessScreen({super.key});

  @override
  State<NewProcessScreen> createState() => _NewProcessScreenState();
}

class _NewProcessScreenState extends State<NewProcessScreen> {
  final ProcessCatalogService _service = ProcessCatalogMockService();
  final ProcessSubmissionService _submissionService =
      ProcessSubmissionMockService();

  // Os controllers vivem no pai: assim o texto sobrevive à troca de passo.
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _observationsController = TextEditingController();

  _LoadState _state = _LoadState.loading;
  ServiceCatalog? _catalog;

  NewProcessDraft _draft = const NewProcessDraft();
  int _currentStep = 0;

  /// Só para anunciar a virada "agora dá para continuar" uma única vez.
  bool _lastCanContinue = false;

  bool _isSubmitting = false;
  String? _submitError;

  /// Preenchido no envio bem-sucedido. É ele que faz o PopScope devolver o
  /// protocolo em vez de perguntar se o usuário quer descartar.
  ProcessModel? _created;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final catalog = await _service.loadCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _state = _LoadState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _LoadState.error);
    }
  }

  void _onDraftChanged(NewProcessDraft draft) {
    setState(() => _draft = draft);

    // Anúncio só na transição, nunca por tecla: no Android o anúncio limpa a
    // fila de fala do TalkBack e interromperia o caractere recém-digitado.
    final canContinue = missingRequirements(_draft).isEmpty;
    if (canContinue && !_lastCanContinue) {
      announceToScreenReader(context, 'Tudo pronto, você já pode continuar.');
    }
    _lastCanContinue = canContinue;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    // Revalida na fronteira: o estado pode ter mudado desde a última pintura.
    final request = _draft.toRequest();
    if (request == null) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final created = await _submissionService.submit(request);
      if (!mounted) return;
      setState(() => _created = created);
      announceToScreenReader(
        context,
        'Protocolo enviado. Número ${created.protocolNumber}.',
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _submitError =
              'Não foi possível enviar o protocolo. Tente novamente.',
        );
        announceToScreenReader(context, 'Falha ao enviar o protocolo.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    // A troca de passo reconstrói o conteúdo inteiro sem gerar fala nenhuma.
    // Seguro aqui porque é evento de botão, não de digitação.
    announceToScreenReader(
      context,
      'Passo ${step + 1} de ${_stepLabels.length}, ${_stepLabels[step]}.',
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: 'Descartar solicitação?',
      message: 'Você preencheu alguns campos e ainda não enviou.',
      confirmLabel: 'Descartar',
      cancelLabel: 'Continuar preenchendo',
      isDestructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      // O voltar do AppBar e o gesto do sistema saem da tela pelo mesmo
      // caminho. Divergir faria o usuário não conseguir prever se perde o que
      // digitou; para voltar um passo existe o botão "Voltar" do rodapé.
      // Continua falso mesmo depois de enviar: liberar o pop faria o botão do
      // sistema popar com null e a Home perderia o protocolo criado. Quem
      // decide é o callback. Navigator.pop imperativo não consulta o canPop,
      // então o pop(_created) abaixo passa direto.
      canPop: _draft.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_created != null) {
          Navigator.of(context).pop(_created);
          return;
        }
        if (_isSubmitting) return;
        _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Novo protocolo'),
          backgroundColor: colors.surface,
          foregroundColor: colors.inputText,
          elevation: 0,
        ),
        body: _created != null
            ? _buildSuccess(colors, _created!)
            : switch (_state) {
                _LoadState.loading => Center(
                  child: CircularProgressIndicator(color: colors.primary),
                ),
                _LoadState.error => _buildError(colors),
                _LoadState.ready => _buildContent(colors),
              },
      ),
    );
  }

  Widget _buildError(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar os tipos de serviço',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.inputBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Substitui o corpo inteiro — sem trilha e sem rodapé de navegação: o
  /// assistente acabou.
  Widget _buildSuccess(AppColors colors, ProcessModel created) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountCard(
            icon: Icons.check_circle_outline,
            title: 'Protocolo aberto',
            description:
                'Sua solicitação foi encaminhada para a secretaria escolhida. '
                'Anote o número abaixo para acompanhar.',
            accent: colors.statusSuccess,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: colors.statusSuccessBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.statusSuccess),
                  ),
                  child: Semantics(
                    label: 'Número do protocolo',
                    value: created.protocolNumber,
                    readOnly: true,
                    child: ExcludeSemantics(
                      child: Text(
                        created.protocolNumber,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.inputText,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(created),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: onBrandColor(colors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: colors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.list_alt_outlined, size: 20),
                  label: const Text('Ver meus protocolos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    final missing = missingRequirements(_draft);
    final canContinue = missing.isEmpty;

    // SingleChildScrollView e não ListView: o ListView descarta filhos fora da
    // tela, e num formulário desta altura isso causa salto de foco e scroll.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WizardStepper(currentStep: _currentStep, labels: _stepLabels),
          const SizedBox(height: 24),

          switch (_currentStep) {
            0 => StepRequestForm(
              catalog: _catalog!,
              draft: _draft,
              locationController: _locationController,
              descriptionController: _descriptionController,
              observationsController: _observationsController,
              onChanged: _onDraftChanged,
            ),
            1 => const StepDocuments(),
            _ => StepReview(catalog: _catalog!, draft: _draft),
          },
          const SizedBox(height: 20),

          if (_currentStep == 0 && !canContinue)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Para continuar, falta: ${missing.join(', ')}.',
                style: TextStyle(
                  color: colors.statusPending,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),

          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _submitError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusError, fontSize: 13),
              ),
            ),

          _buildFooter(colors, canContinue: canContinue, missing: missing),
        ],
      ),
    );
  }

  Widget _buildFooter(
    AppColors colors, {
    required bool canContinue,
    required List<String> missing,
  }) {
    final isLastStep = _currentStep == _stepLabels.length - 1;
    // No passo 0 depende da validação; o passo 2 (documentos) é opcional; no
    // último o botão envia.
    final enabled = (_currentStep == 0 ? canContinue : true) && !_isSubmitting;
    final onPrimary = onBrandColor(colors.primary);

    final continueButton = ElevatedButton.icon(
      onPressed: enabled
          ? (isLastStep ? _submit : () => _goToStep(_currentStep + 1))
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        // Branco fixo reprova o contraste em alto contraste escuro, onde o
        // primary é claro.
        foregroundColor: onPrimary,
        disabledBackgroundColor: colors.primary.withValues(alpha: 0.3),
        disabledForegroundColor: onPrimary.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: enabled ? 4 : 0,
        shadowColor: colors.primary.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isSubmitting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: onPrimary,
              ),
            )
          : Icon(isLastStep ? Icons.send : Icons.arrow_forward, size: 20),
      label: Text(
        _isSubmitting
            ? 'Enviando...'
            : (isLastStep ? 'Enviar protocolo' : 'Continuar'),
      ),
    );

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _goToStep(_currentStep - 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.inputBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Voltar'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          // O botão desabilitado NÃO é pulado pelo leitor de tela — ele é
          // anunciado como "desativado". O que faltava era dizer por quê, e o
          // hint funde no nó do próprio botão.
          child: canContinue || _currentStep > 0
              ? continueButton
              : Semantics(
                  hint: 'Falta: ${missing.join(', ')}',
                  child: continueButton,
                ),
        ),
      ],
    );
  }
}
