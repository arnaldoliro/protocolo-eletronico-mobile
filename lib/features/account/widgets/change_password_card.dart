import 'package:flutter/material.dart';

import '../../../core/services/mock/profile_mock_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import 'account_card.dart';

enum _PasswordField { current, next, confirm }

/// Troca de senha do usuário autenticado.
///
/// Não compartilha estado com o card de dados pessoais: são endpoints
/// independentes, e um não deve travar o outro.
class ChangePasswordCard extends StatefulWidget {
  const ChangePasswordCard({super.key});

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  final ProfileService _service = ProfileMockService();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final Map<_PasswordField, String?> _errors = {};
  String? _submitError;
  String? _successMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearError(_PasswordField field) {
    if (_errors[field] == null && _submitError == null) return;
    setState(() {
      _errors[field] = null;
      _submitError = null;
    });
  }

  /// Validação apenas de UX. O backend é a autoridade sobre a política de
  /// senha — por isso o app NÃO checa maiúscula/minúscula/número: replicar a
  /// regra aqui faria o app recusar senha válida até um novo release sempre
  /// que o servidor mudasse a política.
  bool _validate() {
    final errors = <_PasswordField, String?>{
      _PasswordField.current: Validators.required(
        _currentController.text,
        message: 'Informe a senha atual',
      ),
      _PasswordField.next: Validators.minLength(
        _newController.text,
        8,
        'A senha deve ter no mínimo 8 caracteres',
      ),
      _PasswordField.confirm: Validators.passwordMatch(
        _newController.text,
        _confirmController.text,
      ),
    };

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });

    return errors.values.every((error) => error == null);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_validate()) {
      // errorText aparecendo não gera anúncio nenhum no leitor de tela.
      announceToScreenReader(context, 'Há campos com erro no formulário de senha.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
      _successMessage = null;
    });

    try {
      await _service.changePassword(_currentController.text, _newController.text);
      if (!mounted) return;

      FocusScope.of(context).unfocus();
      // Limpar é obrigatório: senão a senha nova em claro fica viva num
      // TextEditingController pelo resto da sessão.
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();

      setState(() => _successMessage = 'Senha atualizada.');
      announceToScreenReader(context, 'Senha atualizada.');
    } on WrongPasswordException {
      if (mounted) {
        setState(
          () => _errors[_PasswordField.current] = 'Senha atual incorreta',
        );
      }
    } on PasswordPolicyException catch (e) {
      // A política é do servidor: a mensagem dele vai direto no campo, senão
      // o usuário não sabe o que corrigir.
      if (mounted) setState(() => _errors[_PasswordField.next] = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _submitError =
              'Não foi possível atualizar a senha. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AccountCard(
      icon: Icons.lock_outline,
      title: 'Trocar senha',
      description: 'Escolha uma senha forte que você consiga lembrar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledTextField(
            label: 'Senha atual',
            controller: _currentController,
            errorText: _errors[_PasswordField.current],
            obscureText: true,
            prefixIcon: Icons.vpn_key_outlined,
            suggestionsEnabled: false,
            enabled: !_isSubmitting,
            onChanged: (_) => _clearError(_PasswordField.current),
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Nova senha',
            controller: _newController,
            errorText: _errors[_PasswordField.next],
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            // TODO: este texto enuncia a política do servidor. Deveria vir do
            // backend — hoje, se a política mudar lá, a tela mente aqui.
            helperText: 'Mínimo 8 caracteres, maiúsculas, minúsculas e números.',
            suggestionsEnabled: false,
            enabled: !_isSubmitting,
            onChanged: (_) => _clearError(_PasswordField.next),
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Confirmar nova senha',
            controller: _confirmController,
            errorText: _errors[_PasswordField.confirm],
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            suggestionsEnabled: false,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _clearError(_PasswordField.confirm),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 18),

          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _submitError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusError, fontSize: 13),
              ),
            ),
          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _successMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.statusSuccess, fontSize: 13),
              ),
            ),

          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            // Cores explícitas: OutlinedButton sem estilo puxa do ColorScheme,
            // que nunca muda quando o alto contraste liga.
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              disabledForegroundColor: colors.textMuted,
              side: BorderSide(color: colors.inputBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_isSubmitting ? 'Atualizando...' : 'Atualizar senha'),
          ),
        ],
      ),
    );
  }
}
