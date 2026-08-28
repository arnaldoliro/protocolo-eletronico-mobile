import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';

/// Item de lista vertical representando um processo em andamento.
class OngoingProcessTile extends StatelessWidget {
  final ProcessModel process;
  final VoidCallback? onTap;

  const OngoingProcessTile({super.key, required this.process, this.onTap});

  Color _statusColor(ProcessStatus status, AppColors colors) => switch (status) {
    ProcessStatus.emAnalise => colors.primary,
    ProcessStatus.aprovado => colors.statusSuccess,
    ProcessStatus.pendente => colors.statusPending,
    ProcessStatus.cancelado => colors.statusError,
    ProcessStatus.emTramitacao => colors.statusPending,
  };

  Color _statusBgColor(ProcessStatus status, AppColors colors) => switch (status) {
    ProcessStatus.emAnalise => colors.cardBackground,
    ProcessStatus.aprovado => colors.statusSuccessBg,
    ProcessStatus.pendente => colors.statusPendingBg,
    ProcessStatus.cancelado => colors.statusError.withValues(alpha: 0.10),
    ProcessStatus.emTramitacao => colors.statusPendingBg,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final status = process.status;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: colors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${process.protocolNumber}',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: 6),
            Text(
              process.requesterMaskedCpf,
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 12, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(
                  process.openedRelativeLabel,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
