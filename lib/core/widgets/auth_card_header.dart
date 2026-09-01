import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Topo dos cards das telas de autenticação: ícone em quadrado arredondado,
/// título e subtítulo.
class AuthCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Fundo do quadrado do ícone. Nulo usa [AppColors.primary].
  final Color? iconBackground;

  const AuthCardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final background = iconBackground ?? colors.primary;

    final foreground = onBrandColor(background);

    return Column(
      children: [
        // O ícone é decorativo: o título já diz o que a tela é.
        ExcludeSemantics(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: foreground, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.inputText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
