import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../account/widgets/account_card.dart';

/// Passo ainda não implementado, exibido dentro da trilha do assistente.
class StepPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const StepPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AccountCard(
      icon: icon,
      title: title,
      description: description,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: colors.textMuted),
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
