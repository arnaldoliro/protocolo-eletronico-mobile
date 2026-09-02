import 'package:flutter/material.dart';

import '../../../core/models/municipality.dart';
import '../../../core/theme/app_theme.dart';

/// Um município na lista de seleção.
///
/// O selecionado é marcado por **borda e ícone**, nunca só por cor de fundo:
/// em alto contraste escuro `surface`, `cardBackground` e `inputFill` são
/// todos `#000000`, e no claro todos `#FFFFFF` — não há diferença de fundo a
/// explorar nessas paletas.
class MunicipalityTile extends StatelessWidget {
  final Municipality municipality;
  final bool isSelected;
  final VoidCallback onTap;

  const MunicipalityTile({
    super.key,
    required this.municipality,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${municipality.name}, ${municipality.stateCode}',
      child: ExcludeSemantics(
        // Material por fora e sem Container opaco por dentro: o splash do
        // InkWell é pintado pelo Material ancestral, e um fundo opaco no filho
        // o esconderia.
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.inputBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city_outlined,
                    size: 20,
                    color: isSelected ? colors.primary : colors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          municipality.name,
                          // Duas linhas: "São José do Rio Preto" com a fonte
                          // no máximo não cabe numa só em tela estreita.
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.inputText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          municipality.stateCode,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.check_circle, size: 22, color: colors.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
