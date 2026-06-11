import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProcessActionsRow extends StatelessWidget {
  const ProcessActionsRow({super.key});

  static const _items = [
    (label: 'Acompanhar', icon: Icons.track_changes),
    (label: 'Cadastrar', icon: Icons.add_circle_outline),
    (label: 'Cancelar', icon: Icons.cancel_outlined),
    (label: 'Mais', icon: Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.map((item) {
          return InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Em breve'),
                duration: Duration(seconds: 1),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.iconBorder),
                  ),
                  child: Icon(item.icon, color: colors.primary, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
