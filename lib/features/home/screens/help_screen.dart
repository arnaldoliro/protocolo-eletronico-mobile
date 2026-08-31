import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder: tutorial de uso do portal.
///
// TODO(ajuda): o passo a passo precisa vir do backend, não ser fixado no app.
// Conteúdo hardcoded diverge do portal na primeira mudança de tela lá, e
// corrigir passaria a exigir um release na loja.
//
// Distinto do SupportScreen: aqui é material de autoatendimento; lá é
// contato com gente.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Como usar o portal'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 48, color: colors.textMuted),
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
