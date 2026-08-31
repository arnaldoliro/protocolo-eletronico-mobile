import 'package:flutter/material.dart';

import '../../../core/models/service_catalog.dart';
import '../../../core/services/mock/process_catalog_mock_service.dart';
import '../../../core/services/process_catalog_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../models/new_process_draft.dart';
import '../widgets/step_placeholder.dart';
import '../widgets/step_request_form.dart';
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

  // Os controllers vivem no pai: assim o texto sobrevive à troca de passo.
  final _descriptionController = TextEditingController();
  final _observationsController = TextEditingController();

  _LoadState _state = _LoadState.loading;
  ServiceCatalog? _catalog;

  NewProcessDraft _draft = const NewProcessDraft();
  int _currentStep = 0;

  /// Só para anunciar a virada "agora dá para continuar" uma única vez.
  bool _lastCanContinue = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
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
      canPop: _draft.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
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
        body: switch (_state) {
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
              descriptionController: _descriptionController,
              observationsController: _observationsController,
              onChanged: _onDraftChanged,
            ),
            1 => const StepPlaceholder(
              icon: Icons.attach_file_outlined,
              title: 'Documentos',
              description:
                  'Anexe os documentos exigidos para este tipo de serviço.',
            ),
            _ => const StepPlaceholder(
              icon: Icons.fact_check_outlined,
              title: 'Confirmar',
              description:
                  'Revise os dados da solicitação antes de enviar ao setor.',
            ),
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
    // No passo 0 o Continuar depende da validação; os passos seguintes são
    // placeholders e não têm o que validar.
    final enabled = _currentStep == 0 ? canContinue : !isLastStep;

    final continueButton = ElevatedButton.icon(
      onPressed: enabled
          ? () => setState(() => _currentStep = _currentStep + 1)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colors.primary.withValues(alpha: 0.3),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: enabled ? 4 : 0,
        shadowColor: colors.primary.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.arrow_forward, size: 20),
      label: const Text('Continuar'),
    );

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _currentStep = _currentStep - 1),
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
