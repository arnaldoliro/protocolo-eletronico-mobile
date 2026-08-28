import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Topo do card de cadastro: ícone, título e subtítulo.
class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.inputText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cadastre-se para abrir e acompanhar protocolos',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
