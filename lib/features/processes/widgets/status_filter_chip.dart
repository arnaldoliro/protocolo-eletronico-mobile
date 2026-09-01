import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Chip de seleção de status.
///
/// Não é o `FilterChip` do Material: os padrões dele saem do `ColorScheme`,
/// que não acompanha as paletas de alto contraste do app — o chip apareceria
/// com as cores base do Material sobre fundo preto ou branco puro.
class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final background = selected ? colors.primary : colors.inputFill;
    final foreground = selected ? onBrandColor(background) : colors.inputText;

    return Semantics(
      button: true,
      // `selected`, não `toggled`: toggled é de interruptor, e faria o leitor
      // de tela anunciar "ativado" em vez de "selecionado".
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              // 48dp é o alvo mínimo de toque.
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? background : colors.inputBorder,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
