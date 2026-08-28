import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Linha de 3 tiles de estatística: em andamento, concluídos e avisos.
class StatsRow extends StatelessWidget {
  final int inProgress;
  final int completed;
  final int warnings;

  const StatsRow({
    super.key,
    required this.inProgress,
    required this.completed,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: inProgress,
            label: 'EM ANDAMENTO',
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: completed,
            label: 'CONCLUÍDOS',
            color: colors.statusSuccess,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: warnings,
            label: 'AVISOS',
            color: colors.statusPending,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
