import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';

class RecentActivitySection extends StatelessWidget {
  final ProcessModel process;
  final List<ProcessStep> steps;

  const RecentActivitySection({
    super.key,
    required this.process,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividades Recentes',
          style: TextStyle(
            color: colors.inputText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do processo
              Text(
                process.type,
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Protocolo #${process.id}',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // Timeline
              ...List.generate(steps.length, (i) {
                return _TimelineItem(
                  step: steps[i],
                  isLast: i == steps.length - 1,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ProcessStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna do indicador + linha
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _StepIndicator(step: step),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.status == StepStatus.completed
                          ? colors.primary.withValues(alpha: 0.25)
                          : colors.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Conteúdo da etapa
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      color: step.status == StepStatus.pending
                          ? colors.textMuted
                          : colors.inputText,
                      fontSize: 13,
                      fontWeight: step.status != StepStatus.pending
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (step.completedAt != null)
                    Text(
                      _formatDateTime(step.completedAt!),
                      style: TextStyle(
                        color: colors.textTime,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatefulWidget {
  final ProcessStep step;

  const _StepIndicator({required this.step});

  @override
  State<_StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<_StepIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    if (widget.step.status == StepStatus.current) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);

      _scale = Tween<double>(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _opacity = Tween<double>(begin: 0.4, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.step.status == StepStatus.current) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final status = widget.step.status;

    if (status == StepStatus.current) {
      return SizedBox(
        width: 20,
        height: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anel pulsante externo
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Círculo sólido central
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (status == StepStatus.completed) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
        ),
      );
    }

    // Pendente
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.cardBorder, width: 2),
        color: colors.surface,
      ),
    );
  }
}
