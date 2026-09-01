/// Quem escreveu a mensagem.
enum ChatAuthor { user, assistant }

/// Só faz sentido em mensagem do usuário — a do assistente ou chegou, ou não
/// existe.
enum ChatMessageStatus { sent, failed }

/// Uma mensagem da conversa de suporte.
///
/// ATENÇÃO — LGPD: [text] é escrito livremente pelo cidadão e pode conter CPF,
/// endereço, número de processo e até dado de saúde. Nunca logar, nunca
/// persistir em disco, nunca mandar a analytics. `toString()` NÃO é
/// sobrescrito.
class ChatMessage {
  /// Carimbado por quem exibe a mensagem, não pelo serviço. É o que mantém o
  /// elemento da lista preso à mensagem certa quando itens são inseridos.
  final String id;

  final ChatAuthor author;
  final String text;

  /// Guardado mas não exibido: nenhum token "apagado" da paleta escura tem
  /// contraste suficiente sobre a superfície do card para um timestamp.
  final DateTime sentAt;

  final ChatMessageStatus status;

  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.sentAt,
    this.status = ChatMessageStatus.sent,
  });

  ChatMessage copyWith({ChatMessageStatus? status}) {
    return ChatMessage(
      id: id,
      author: author,
      text: text,
      sentAt: sentAt,
      status: status ?? this.status,
    );
  }
}
