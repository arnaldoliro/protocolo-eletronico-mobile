import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';
import 'ongoing_process_tile.dart';

/// Seção "EM ANDAMENTO": título uppercase seguido de uma lista vertical
/// dos processos do usuário que ainda estão em tramitação.
class OngoingProcessesSection extends StatelessWidget {
  final List<ProcessModel> processes;
  final ValueChanged<ProcessModel>? onTapProcess;

  const OngoingProcessesSection({
    super.key,
    required this.processes,
    this.onTapProcess,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EM ANDAMENTO',
          style: TextStyle(
            color: colors.inputText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        ...processes.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OngoingProcessTile(
              process: p,
              onTap: onTapProcess != null ? () => onTapProcess!(p) : null,
            ),
          ),
        ),
      ],
    );
  }
}
