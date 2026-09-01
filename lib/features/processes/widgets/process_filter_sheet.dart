import 'package:flutter/material.dart';

import '../../../core/models/process_model.dart';
import '../../../core/models/process_query.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/labeled_dropdown.dart';
import 'status_filter_chip.dart';

/// Abre a folha de filtros. Devolve a consulta nova, ou nulo se o usuário
/// fechou sem aplicar.
Future<ProcessQuery?> showProcessFilterSheet(
  BuildContext context, {
  required ProcessQuery current,
}) {
  final colors = AppColors.of(context);

  return showModalBottomSheet<ProcessQuery>(
    context: context,
    // Sem isto a folha trava em 9/16 da tela e corta o conteúdo com a fonte
    // no máximo.
    isScrollControlled: true,
    useSafeArea: true,
    // Cores e formato explícitos: o default vem do BottomSheetThemeData.
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterSheet(current: current),
  );
}

class _FilterSheet extends StatefulWidget {
  final ProcessQuery current;

  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  // Rascunho local: a consulta só é aplicada no botão. Filtrar a cada toque
  // dispararia uma busca atrás de uma folha que cobre justamente o resultado.
  late Set<ProcessStatus> _statuses = {...widget.current.statuses};
  late ProcessPeriod _period = widget.current.period;

  void _toggleStatus(ProcessStatus status) {
    setState(() {
      if (!_statuses.remove(status)) _statuses.add(status);
    });
  }

  /// Limpa em lugar, sem fechar — fechar-e-aplicar a partir do "Limpar"
  /// surpreende quem só queria recomeçar a escolha.
  void _clear() {
    setState(() {
      _statuses = {};
      _period = ProcessPeriod.any;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                'Filtros',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Flexible + scroll: sem ele a folha cresce além da tela e os
            // botões saem do viewport com a fonte grande.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Situação',
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Wrap e não Row: os chips quebram em várias linhas com a
                    // fonte grande, e Expanded dentro de Wrap lança.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in ProcessStatus.values)
                          StatusFilterChip(
                            label: status.label,
                            selected: _statuses.contains(status),
                            onTap: () => _toggleStatus(status),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    LabeledDropdown<ProcessPeriod>(
                      label: 'Período de abertura',
                      hint: 'Qualquer data',
                      prefixIcon: Icons.calendar_today_outlined,
                      value: _period,
                      items: [
                        for (final period in ProcessPeriod.values)
                          DropdownMenuItem(
                            value: period,
                            child: Text(period.label),
                          ),
                      ],
                      onChanged: (value) => setState(
                        () => _period = value ?? ProcessPeriod.any,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Empilhados: dois botões lado a lado dariam ~136dp cada, e o
            // rótulo quebraria em três linhas com a fonte no máximo.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(
                  widget.current.copyWith(
                    statuses: _statuses,
                    period: _period,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: onBrandColor(colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: colors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _clear,
                style: TextButton.styleFrom(
                  foregroundColor: colors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Limpar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
