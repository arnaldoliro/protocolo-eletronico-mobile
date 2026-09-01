import 'package:flutter/material.dart';

import '../../../core/models/service_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../account/widgets/account_card.dart';
import '../models/new_process_draft.dart';

/// Passo 3: revisão antes do envio.
class StepReview extends StatelessWidget {
  final ServiceCatalog catalog;
  final NewProcessDraft draft;

  const StepReview({super.key, required this.catalog, required this.draft});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final notice = catalog.subjectById(draft.subjectId)?.paymentNotice;

    // Ordem do formulário, não a do mockup: quem toca em "Voltar" para
    // corrigir encontra o campo onde espera. Categoria entra porque é
    // obrigatória no passo 1 — omitir deixaria sem conferência algo que o
    // usuário foi obrigado a preencher.
    final rows = <_SummaryRow>[
      _SummaryRow(
        icon: Icons.category_outlined,
        label: 'Categoria',
        value: catalog.categoryName(draft.categoryId),
      ),
      _SummaryRow(
        icon: Icons.straighten_outlined,
        label: 'Porte',
        value: catalog.sizeName(draft.sizeId),
      ),
      _SummaryRow(
        icon: Icons.label_outline,
        label: 'Assunto',
        value: catalog.subjectName(draft.subjectId),
      ),
      _SummaryRow(
        icon: Icons.apartment_outlined,
        label: 'Secretaria',
        value: catalog.departmentName(draft.departmentId),
      ),
      _SummaryRow(
        icon: Icons.place_outlined,
        label: 'Local',
        value: draft.location.trim(),
      ),
      _SummaryRow(
        icon: Icons.notes_outlined,
        label: 'Descrição',
        value: draft.description.trim(),
      ),
      _SummaryRow(
        icon: Icons.sticky_note_2_outlined,
        label: 'Observações',
        value: draft.observations.trim(),
      ),
      // Sempre "Sem anexos" enquanto o seletor de arquivos não existe.
      const _SummaryRow(
        icon: Icons.attach_file,
        label: 'Anexos',
        value: 'Sem anexos',
      ),
    ];

    return AccountCard(
      icon: Icons.fact_check_outlined,
      title: 'Confira antes de enviar',
      description:
          'Confira se tudo está certo. Após enviar, o protocolo é encaminhado '
          'para a secretaria escolhida e você pode acompanhar pelo app.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(color: colors.inputBorder, thickness: 1, height: 24),
            rows[i],
          ],

          if (notice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.statusPendingBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.statusPending),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.statusPending,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Uma linha do resumo: ícone, rótulo e valor.
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Nulo ou vazio vira um traço — a linha nunca some, para o usuário
  /// perceber a inconsistência em vez de achar que o campo não existia.
  final String? value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final filled = value != null && value!.isNotEmpty;
    final display = filled ? value! : '—';

    return MergeSemantics(
      child: Semantics(
        // Rótulo em caixa normal: o leitor de tela costuma soletrar texto
        // todo-maiúsculo como sigla.
        label: label,
        value: filled ? value : 'não informado',
        readOnly: true,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                // Rótulo acima e valor abaixo, nunca lado a lado: a largura
                // útil aqui é ~216dp e a descrição precisa de espaço.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Sem maxLines e sem overflow: a descrição é justamente o
                    // que precisa ser relido inteiro antes de enviar.
                    Text(
                      display,
                      style: TextStyle(
                        color: filled ? colors.inputText : colors.textMuted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
