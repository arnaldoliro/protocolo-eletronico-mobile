import 'package:flutter/material.dart';

import '../../../core/models/process_model.dart';
import '../../../core/theme/app_theme.dart';

/// Card de protocolo na listagem.
///
/// Não reusa o `OngoingProcessTile` da Home por três motivos: aquele não
/// mostra o assunto (justamente o campo que a busca casa), exibe o CPF do
/// requerente — redundante numa lista dos protocolos do próprio usuário — e
/// tem o cabeçalho num `Row` sem `Flexible`, que já estoura com a fonte no
/// máximo em telas estreitas.
class ProcessCard extends StatelessWidget {
  final ProcessModel process;
  final VoidCallback? onTap;

  const ProcessCard({super.key, required this.process, this.onTap});

  Color _statusColor(AppColors colors) => switch (process.status) {
    ProcessStatus.emAnalise => colors.primary,
    ProcessStatus.aprovado => colors.statusSuccess,
    ProcessStatus.pendente => colors.statusPending,
    ProcessStatus.cancelado => colors.statusError,
    ProcessStatus.emTramitacao => colors.statusPending,
  };

  Color _statusBgColor(AppColors colors) => switch (process.status) {
    ProcessStatus.emAnalise => colors.cardBackground,
    ProcessStatus.aprovado => colors.statusSuccessBg,
    ProcessStatus.pendente => colors.statusPendingBg,
    ProcessStatus.cancelado => colors.statusError.withValues(alpha: 0.10),
    ProcessStatus.emTramitacao => colors.statusPendingBg,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: onTap != null,
      // Uma frase só: sem isto o leitor de tela lê quatro nós soltos por card,
      // o que numa lista longa fica insuportável.
      label:
          'Protocolo ${process.protocolNumber}. ${process.type}. '
          '${process.status.label}. ${process.openedRelativeLabel}.',
      child: ExcludeSemantics(
        // Material por fora e sem Container opaco por dentro: o splash do
        // InkWell é pintado pelo Material ancestral, então um fundo opaco no
        // filho o esconderia.
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    process.type,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.inputText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Flexible nos dois: número e etiqueta juntos passam da
                      // largura útil com a fonte grande em tela estreita.
                      Flexible(
                        child: Text(
                          '#${process.protocolNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBgColor(colors),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            process.status.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _statusColor(colors),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          process.openedRelativeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
