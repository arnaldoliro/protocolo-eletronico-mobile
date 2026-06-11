import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SummarySection extends StatelessWidget {
  final int inProgress;
  final int completed;
  final int pending;

  const SummarySection({
    super.key,
    required this.inProgress,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo',
          style: TextStyle(
            color: colors.inputText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.description_outlined,
                value: inProgress,
                label: 'Em andamento',
                iconColor: colors.primary,
                iconBg: colors.cardBackground,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_box_outlined,
                value: completed,
                label: 'Concluídos',
                iconColor: colors.statusSuccess,
                iconBg: colors.statusSuccessBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.hourglass_empty_outlined,
                value: pending,
                label: 'Pendentes',
                iconColor: colors.statusPending,
                iconBg: colors.statusPendingBg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color iconColor;
  final Color iconBg;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              color: colors.inputText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
