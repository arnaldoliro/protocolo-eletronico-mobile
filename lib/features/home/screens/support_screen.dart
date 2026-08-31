import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder: canal de suporte ainda não definido.
///
// TODO(suporte): definir o canal antes de produção (e-mail, telefone da
// ouvidoria, formulário ou chat). O conteúdo — horários, telefones, prazos
// de resposta — vem do backend; nada disso deve ser fixado no app.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Suporte'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_outlined, size: 48, color: colors.textMuted),
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
