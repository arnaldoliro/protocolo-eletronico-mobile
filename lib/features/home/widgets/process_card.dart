import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';

class ProcessCard extends StatelessWidget {
  final ProcessModel process;

  const ProcessCard({super.key, required this.process});

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Color _statusColor(ProcessStatus status, AppColors colors) => switch (status) {
    ProcessStatus.emAnalise => colors.primary,
    ProcessStatus.aprovado => colors.statusSuccess,
    ProcessStatus.pendente => colors.statusPending,
    ProcessStatus.cancelado => colors.statusError,
  };

  Color _statusBgColor(ProcessStatus status, AppColors colors) => switch (status) {
    ProcessStatus.emAnalise => colors.cardBackground,
    ProcessStatus.aprovado => colors.statusSuccessBg,
    ProcessStatus.pendente => colors.statusPendingBg,
    ProcessStatus.cancelado => colors.statusError.withValues(alpha: 0.10),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final status = process.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone de documento
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.iconBorder),
            ),
            child: Icon(Icons.description_outlined, color: colors.primary, size: 20),
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            process.type,
            style: TextStyle(
              color: colors.inputText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Badge de status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBgColor(status, colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                color: _statusColor(status, colors),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Data
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: colors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatDate(process.date),
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Divisor
          Divider(color: colors.cardBorder, height: 1),
          const SizedBox(height: 8),

          // Número do protocolo
          Text(
            'Protocolo #${process.id}',
            style: TextStyle(
              fontSize: 11,
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
