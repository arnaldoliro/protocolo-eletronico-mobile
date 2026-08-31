import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Card padrão da tela de conta: ícone + título, descrição e conteúdo.
///
/// Mesmos tokens dos cards de cadastro e recuperação de senha.
class AccountCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  /// Tinta do ícone e do título. Nulo usa [AppColors.primary].
  final Color? accent;

  const AccountCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tint = accent ?? colors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: tint, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.inputText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
