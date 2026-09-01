import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_input_decoration.dart';

/// Campo de escrita e botão de enviar.
class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isAwaitingReply;

  /// Falso quando a conversa foi encerrada — o histórico segue legível, mas
  /// não aceita mensagem nova.
  final bool enabled;

  final ValueChanged<String> onSend;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.isAwaitingReply,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(
              textField: true,
              label: enabled ? 'Escreva sua dúvida' : 'Conversa encerrada',
              child: TextField(
                controller: controller,
                enabled: enabled,
                // Cresce até 4 linhas e depois rola: com o teclado aberto e a
                // fonte no máximo, 5 linhas deixariam quase nada de conversa
                // visível.
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                // newline e não send: o `send` fecha o teclado a cada mensagem
                // e impede quebra de linha num campo onde o cidadão escreve um
                // parágrafo. Quem envia é o botão.
                textInputAction: TextInputAction.newline,
                // LGPD: impede o teclado de guardar no dicionário pessoal o
                // que for digitado aqui — que costuma incluir CPF, endereço e
                // às vezes dado de saúde.
                enableIMEPersonalizedLearning: false,
                // Sem autofocus: abrir o teclado ao entrar esconderia a
                // mensagem de boas-vindas e o aviso sobre o assistente.
                style: TextStyle(color: colors.inputText),
                decoration: appInputDecoration(
                  colors,
                  hint: enabled
                      ? 'Escreva sua dúvida'
                      : 'Conversa encerrada',
                  enabled: enabled,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Só o botão reconstrói a cada tecla — não a tela.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend =
                  enabled && value.text.trim().isNotEmpty && !isAwaitingReply;
              return IconButton(
                onPressed: canSend ? () => onSend(value.text) : null,
                tooltip: 'Enviar mensagem',
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: canSend
                      ? colors.primaryMedium
                      : colors.inputFill,
                  foregroundColor: canSend
                      ? onBrandColor(colors.primaryMedium)
                      : colors.textMuted,
                  side: BorderSide(
                    color: canSend ? colors.primaryMedium : colors.inputBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
