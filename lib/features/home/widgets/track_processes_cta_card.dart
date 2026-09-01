import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Card de destaque levando à listagem completa de protocolos.
///
/// Irmão do [NewProcessCtaCard], com o mesmo layout. Usa `Material` +
/// `InkWell` em vez de `InkWell` + `Container` opaco: aquele esconde o splash,
/// porque o fundo do filho pinta por cima do Material ancestral.
class TrackProcessesCtaCard extends StatelessWidget {
  final VoidCallback onTap;

  const TrackProcessesCtaCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: 'Acompanhar meus protocolos',
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryMedium,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fact_check_outlined,
                      color: onBrandColor(colors.primaryMedium),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acompanhar meus protocolos',
                          style: TextStyle(
                            color: colors.inputText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Veja a situação de tudo que você já solicitou',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
