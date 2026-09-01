import 'package:flutter/material.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/theme/app_theme.dart';

/// Uma mensagem da conversa.
///
/// Distingue autor por TRÊS pistas redundantes — cor, alinhamento e ícone —
/// porque nenhuma sozinha funciona nas quatro paletas: em alto contraste
/// escuro `surface`, `cardBackground` e `inputFill` são todos `#000000` (e
/// todos `#FFFFFF` no claro), e no tema claro `surface` contra `background` dá
/// 1,05:1. Cor de fundo sozinha não desenha bolha em nenhuma ponta.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  /// Marca a bolha como região viva para o leitor de tela anunciá-la ao
  /// chegar. Só a resposta MAIS RECENTE do assistente — marcar genericamente
  /// "a última" faria o TalkBack ler de volta o que o usuário acabou de
  /// digitar.
  final bool isLatestAssistantMessage;

  final VoidCallback onRetry;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isLatestAssistantMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isUser = message.author == ChatAuthor.user;
    final failed = message.status == ChatMessageStatus.failed;

    final authorLabel = isUser ? 'Você' : 'Assistente';
    final semanticsLabel =
        '$authorLabel: ${message.text}${failed ? '. Não enviado.' : ''}';

    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: isLatestAssistantMessage,
          label: semanticsLabel,
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  _AssistantAvatar(colors: colors),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: ConstrainedBox(
                    // Sem teto a bolha ocupa 100% da largura e destrói a pista
                    // de alinhamento.
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                    ),
                    child: _buildBubble(colors, isUser: isUser, failed: failed),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (failed) _buildFailureRow(colors),
      ],
    );
  }

  Widget _buildBubble(
    AppColors colors, {
    required bool isUser,
    required bool failed,
  }) {
    // primaryMedium e NÃO primary: branco sobre primary (#3F7DFF) dá 3,76:1 e
    // reprova o AA. O onBrandColor devolve branco ali porque o limiar do
    // Material é enviesado para texto claro, não porque passa no WCAG.
    final background = isUser ? colors.primaryMedium : colors.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        // A borda carrega as paletas de alto contraste, onde os fundos são
        // todos da mesma cor; a sombra carrega claro e escuro.
        border: Border.all(
          color: failed
              ? colors.statusError
              : (isUser ? background : colors.cardBorder),
        ),
        boxShadow: isUser ? null : colors.cardShadow,
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isUser ? onBrandColor(background) : colors.inputText,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFailureRow(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 14, color: colors.statusError),
          const SizedBox(width: 4),
          Text(
            'Não enviado',
            style: TextStyle(color: colors.statusError, fontSize: 12),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  final AppColors colors;

  const _AssistantAvatar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.iconBorder),
      ),
      child: Icon(
        // O mesmo ícone do botão de assistente na barra de acessibilidade.
        Icons.auto_awesome_outlined,
        size: 15,
        color: colors.primary,
      ),
    );
  }
}
