import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Separador de seção dentro do formulário (ex.: "Endereço").
class SectionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;

  const SectionHeader({super.key, required this.title, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Text.rich(
      TextSpan(
        text: title,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (isRequired)
            TextSpan(text: ' *', style: TextStyle(color: colors.statusError)),
        ],
      ),
    );
  }
}
