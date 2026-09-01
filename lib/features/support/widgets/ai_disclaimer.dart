import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/field_help_sheet.dart';

// TODO(juridico): este texto tem teor jurídico e precisa da revisão de quem
// responde pelo órgão. E, como o conteúdo pode mudar sem release, o certo é
// ele vir do backend — mesmo raciocínio dos TODO(suporte) e TODO(ajuda).
const _shortNotice =
    'Respostas geradas por inteligência artificial podem conter erros. '
    'Confirme prazos e exigências nos canais oficiais.';

const _longNotice =
    'Este assistente é automático e responde com base em informações gerais '
    'sobre o uso do aplicativo.\n\n'
    'Ele pode errar, e não substitui o atendimento da prefeitura. Antes de '
    'contar com qualquer prazo, documento exigido ou valor, confirme nos '
    'canais oficiais do órgão.\n\n'
    'O assistente também não consulta, abre nem altera protocolos — para isso, '
    'use as telas do próprio aplicativo.';

/// Aviso permanente de que as respostas não são oficiais.
///
/// Fica no rodapé, e não no topo nem como primeira mensagem: a primeira
/// mensagem sai da tela quando a conversa cresce — justamente quando o aviso
/// mais importa — e uma bolha do assistente dizendo "não confie em mim" é lida
/// como conteúdo do assistente. Com a lista invertida, a atenção fica
/// permanentemente no rodapé.
class AiDisclaimer extends StatelessWidget {
  const AiDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: 'Sobre o assistente. $_shortNotice',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () => showFieldHelpSheet(
            context,
            title: 'Sobre o assistente',
            message: _longNotice,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.textMuted),
                const SizedBox(width: 8),
                // Sem maxLines: texto de aviso nunca pode ser cortado por
                // reticências.
                Expanded(
                  child: Text(
                    _shortNotice,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
