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
        if (processes.isEmpty)
          // Sem isto sobra só o título solto quando a lista está vazia — o que
          // passou a ser alcançável agora que ela é estado dinâmico.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: colors.cardShadow,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: colors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum protocolo em andamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.inputText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quando você abrir um protocolo, ele aparece aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
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
