import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/services/mock/password_recovery_mock_service.dart';
import '../../../core/services/password_recovery_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth_background.dart';
import '../../../core/widgets/auth_card_header.dart';
import '../../../core/widgets/labeled_text_field.dart';

/// Mensagem deliberadamente genérica: nunca revela se o e-mail está
/// cadastrado. Dizer "e-mail não encontrado" entregaria a existência de
/// contas a quem só precisa de uma lista de e-mails para testar.
const _confirmationMessage =
    'Se este e-mail estiver cadastrado, enviamos um link para você definir '
    'uma nova senha.';

/// Solicitação do link de redefinição de senha.
///
/// Depois de enviar, o mesmo card vira o estado de confirmação — sem rota
/// nova. Por isso a troca precisa ser anunciada ao leitor de tela: sem
/// navegação, ele não tem como perceber que algo mudou.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PasswordRecoveryService _service = PasswordRecoveryMockService();
  final _emailController = TextEditingController();

  /// Recebe o foco quando o card vira confirmação. É o que faz o TalkBack
  /// perceber a troca — o anúncio abaixo é só reforço.
  final _confirmationFocus = FocusNode();

  bool _sent = false;
  bool _isSubmitting = false;
  String? _emailError;
  String? _submitError;

  @override
  void dispose() {
    _emailController.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  void _clearEmailError() {
    if (_emailError == null) return;
    setState(() => _emailError = null);
  }

  Future<void> _submit() async {
    // Guarda contra double-tap antes do rebuild e contra o Enter do teclado
    // durante o envio.
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final error = Validators.email(email);
    if (error != null) {
      setState(() => _emailError = error);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _emailError = null;
      _submitError = null;
    });

    try {
      // O e-mail vai com trim, mas sem toLowerCase: a parte local é
      // case-sensitive por RFC, e normalizar é decisão do backend.
      await _service.requestReset(email);

      if (!mounted) return;
      FocusScope.of(context).unfocus();
      setState(() => _sent = true);
      _announceConfirmation();
    } catch (_) {
      // Falha de transporte: o servidor não chegou a emitir juízo sobre o
      // e-mail, então avisar do erro não revela se a conta existe. O
      // vazamento só existiria se a mensagem variasse conforme o e-mail.
      if (mounted) {
        setState(
          () => _submitError =
              'Não foi possível enviar o link. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// A troca é in-place, sem rota nova: sem isso o leitor de tela não recebe
  /// nenhum sinal de que a tela mudou.
  void _announceConfirmation() {
    // O Android depreciou os eventos de anúncio (forçam o TalkBack a limpar a
    // fila de fala) e nem toda plataforma os suporta — por isso o anúncio é
    // best-effort e o foco é o mecanismo principal.
    if (MediaQuery.supportsAnnounceOf(context)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        _confirmationMessage,
        Directionality.of(context),
      );
    }
    // Depois do frame: o botão que recebe o foco só existe após o rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confirmationFocus.requestFocus();
    });
  }

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _tryAnotherEmail() {
    setState(() {
      _sent = false;
      _submitError = null;
    });
  }

  ButtonStyle _primaryButtonStyle(AppColors colors) {
    return ElevatedButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
      disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shadowColor: colors.primary.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AuthBackground(
      // Center FORA do scroll: dentro dele o viewport dá altura infinita ao
      // filho e o Center vira no-op vertical, deixando o card colado no topo.
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            // Suaviza só a mudança de altura entre os dois estados. Um
            // AnimatedSwitcher manteria o formulário montado durante a
            // transição — teclado preso, foco disputado e o leitor de tela
            // enxergando os dois estados ao mesmo tempo.
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: colors.cardShadow,
                ),
                child: _sent ? _buildSent(colors) : _buildForm(colors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppColors colors) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthCardHeader(
            icon: Icons.lock_reset,
            title: 'Recuperar senha',
            subtitle: 'Enviaremos um link para o seu e-mail',
          ),
          const SizedBox(height: 20),

          Text(
            'Informe o e-mail usado no seu cadastro. Você receberá um link '
            'para definir uma nova senha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          LabeledTextField(
            label: 'E-mail',
            isRequired: true,
            hint: 'seu@email.com',
            prefixIcon: Icons.mail_outline,
            controller: _emailController,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            // Autocorreção mutila e-mail digitado.
            suggestionsEnabled: false,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => _clearEmailError(),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),

          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _submitError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusError, fontSize: 13),
              ),
            ),

          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            style: _primaryButtonStyle(colors),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 20),
            label: Text(_isSubmitting ? 'Enviando...' : 'Enviar link'),
          ),
          const SizedBox(height: 4),

          // TextButton em vez do GestureDetector(Text) usado no cadastro: já
          // vem com alvo de toque de 48px e semântica de botão.
          TextButton.icon(
            onPressed: _isSubmitting ? null : _goToLogin,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Voltar ao login'),
            style: TextButton.styleFrom(foregroundColor: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSent(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthCardHeader(
          icon: Icons.mark_email_read_outlined,
          title: 'Verifique seu e-mail',
          subtitle: 'Enviamos as instruções de recuperação',
          iconBackground: colors.statusSuccess,
        ),
        const SizedBox(height: 20),

        Text(
          _confirmationMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Não recebeu? Confira a caixa de spam.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          focusNode: _confirmationFocus,
          onPressed: _goToLogin,
          style: _primaryButtonStyle(colors),
          child: const Text('Voltar ao login'),
        ),
        const SizedBox(height: 4),

        TextButton(
          onPressed: _tryAnotherEmail,
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          child: const Text('Tentar outro e-mail'),
        ),
      ],
    );
  }
}
