import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mock/auth_mock_service.dart';
import '../../../core/tenant/municipality_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_background.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../home/screens/home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthMockService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool valid = true;

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _emailError = 'Informe um e-mail válido');
      valid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Informe a senha');
      valid = false;
    }

    return valid;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeShell(user: user)),
      );
    } catch (_) {
      setState(() => _loginError = 'E-mail ou senha incorretos');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _MunicipalityLine(),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Senha',
                obscureText: true,
                controller: _passwordController,
                errorText: _passwordError,
              ),
              const SizedBox(height: 24),
              if (_loginError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _loginError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: colors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: colors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Cadastre-se',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Município escolhido, com atalho para trocar.
///
/// A linha inteira é o alvo de toque, em vez de um botão separado ao lado:
/// assim não há dois alvos competindo, e um nome longo como "São José do Rio
/// Preto" ocupa o espaço que precisar em vez de disputar largura.
///
/// Daqui a troca vai direto ao seletor, sem confirmação — ninguém está
/// autenticado ainda, não há nada a descartar.
class _MunicipalityLine extends StatelessWidget {
  const _MunicipalityLine();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final municipality = MunicipalityScope.of(context).selected;

    // Defensivo: se o dado sumir, a tela não quebra — só não mostra a linha.
    if (municipality == null) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: 'Município: ${municipality.label}. Toque para trocar.',
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/municipality', (_) => false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 18, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      municipality.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Trocar',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
