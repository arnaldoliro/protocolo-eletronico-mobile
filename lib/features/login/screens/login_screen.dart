import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      // TODO: substituir pela chamada real ao backend
      await Future.delayed(const Duration(seconds: 2));

      // Simulação de erro do backend — remover quando integrar a API
      throw Exception('Credenciais inválidas');
    } catch (e) {
      setState(() => _loginError = 'E-mail ou senha incorretos');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.inputFill.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.asset('assets/images/logo_ilheus.jpeg'),
                ),
              ),
              const SizedBox(height: 48),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.inputText,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            color: AppColors.inputText,
                          ),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
