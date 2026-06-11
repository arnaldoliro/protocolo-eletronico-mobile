import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';
import 'process_card.dart';

class RecentProcessesSection extends StatelessWidget {
  final List<ProcessModel> processes;

  const RecentProcessesSection({super.key, required this.processes});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.62;

    return Column(
      children: [
        // Cabeçalho da seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Processos',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cards com scroll horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: processes.map((p) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: cardWidth,
                height: 220,
                child: ProcessCard(process: p),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
