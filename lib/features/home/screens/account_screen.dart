import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder: tela de conta/perfil ainda não implementada.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Conta'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Em breve',
              style: TextStyle(
                color: colors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
