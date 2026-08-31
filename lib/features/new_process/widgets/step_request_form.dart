import 'package:flutter/material.dart';

import '../../../core/models/service_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/labeled_dropdown.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../account/widgets/account_card.dart';
import '../models/new_process_draft.dart';

/// Passo 1: o que o cidadão está pedindo.
class StepRequestForm extends StatelessWidget {
  final ServiceCatalog catalog;
  final NewProcessDraft draft;
  final TextEditingController descriptionController;
  final TextEditingController observationsController;
  final ValueChanged<NewProcessDraft> onChanged;
  final bool enabled;

  const StepRequestForm({
    super.key,
    required this.catalog,
    required this.draft,
    required this.descriptionController,
    required this.observationsController,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AccountCard(
      icon: Icons.description_outlined,
      title: 'Sobre sua solicitação',
      description:
          'Conte de forma clara o que você precisa. Quanto mais detalhe, '
          'mais rápido o setor consegue analisar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledDropdown<String>(
            label: 'Categoria do serviço',
            isRequired: true,
            hint: 'Selecione...',
            prefixIcon: Icons.category_outlined,
            helpMessage:
                'O grande grupo a que o seu pedido pertence — meio ambiente, '
                'obras, saúde, educação ou tributos. Se estiver em dúvida, '
                'escolha a que mais se aproxima: o setor redireciona quando '
                'necessário.',
            value: draft.categoryId,
            items: [
              for (final c in catalog.categories)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: enabled
                ? (id) => onChanged(draft.copyWith(categoryId: id))
                : null,
          ),
          const SizedBox(height: 14),

          LabeledDropdown<String>(
            label: 'Porte do serviço',
            isRequired: true,
            hint: 'Selecione...',
            prefixIcon: Icons.straighten_outlined,
            helpMessage:
                'O tamanho do que você está pedindo. Um pedido simples é '
                'pontual e resolvido em uma visita; um complexo envolve '
                'projeto, vistoria ou mais de um setor.',
            value: draft.sizeId,
            items: [
              for (final s in catalog.sizes)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: enabled
                ? (id) => onChanged(draft.copyWith(sizeId: id))
                : null,
          ),
          const SizedBox(height: 14),

          LabeledDropdown<String>(
            label: 'Assunto',
            isRequired: true,
            hint: 'Selecione...',
            prefixIcon: Icons.label_outline,
            helpMessage:
                'O serviço específico que você quer solicitar. É o que define '
                'o fluxo que o seu protocolo vai seguir dentro do órgão.',
            value: draft.subjectId,
            items: [
              for (final s in catalog.subjects)
                DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name, maxLines: 2),
                ),
            ],
            onChanged: enabled
                ? (id) => onChanged(draft.copyWith(subjectId: id))
                : null,
          ),
          const SizedBox(height: 14),

          LabeledDropdown<String>(
            label: 'Secretaria de destino',
            isRequired: true,
            hint: 'Selecione...',
            prefixIcon: Icons.apartment_outlined,
            helpMessage:
                'Para qual secretaria o pedido vai. Se escolher a errada, o '
                'protocolo não se perde: ele é redirecionado internamente, '
                'mas isso costuma atrasar a análise.',
            value: draft.departmentId,
            items: [
              for (final d in catalog.departments)
                DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name, maxLines: 2),
                ),
            ],
            onChanged: enabled
                ? (id) => onChanged(draft.copyWith(departmentId: id))
                : null,
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Descrição da sua solicitação',
            isRequired: true,
            hint:
                'Ex.: Solicito a poda da árvore em frente ao número 123 da '
                'Rua das Flores, que está com risco de queda sobre a rede '
                'elétrica.',
            helpMessage:
                'Descreva o que precisa, onde fica e desde quando. Endereço '
                'com número de referência e a situação atual são o que mais '
                'ajudam o setor a avaliar sem precisar entrar em contato.',
            controller: descriptionController,
            // Contador âmbar enquanto falta texto. Vai no helperText, não num
            // Text irmão: helper e error são mutuamente exclusivos, então ele
            // sai de cena sozinho se um erro real aparecer.
            helperText: draft.hasEnoughDescription
                ? null
                : 'Descreva com pelo menos $kMinDescriptionLength caracteres '
                      '(${draft.descriptionLength}/$kMinDescriptionLength).',
            helperColor: colors.statusPending,
            maxLines: 6,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
            enabled: enabled,
            onChanged: (v) => onChanged(draft.copyWith(description: v)),
          ),
          const SizedBox(height: 14),

          LabeledTextField(
            label: 'Observações',
            hint: 'Algo mais que o setor precise saber? (opcional)',
            helpMessage:
                'Campo opcional, para o que não coube na descrição: horários '
                'em que você pode ser encontrado, tentativas anteriores de '
                'resolver, número de protocolo relacionado.',
            controller: observationsController,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            enabled: enabled,
            onChanged: (v) => onChanged(draft.copyWith(observations: v)),
          ),
        ],
      ),
    );
  }
}
