import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/mock/support_chat_mock_service.dart';
import '../services/support_chat_service.dart';

/// Conversa em curso com o assistente de suporte.
///
/// Vive fora da tela de propósito: o usuário manda a pergunta, vê o indicador
/// de digitando, se impacienta e volta para a Home. Se o envio morasse no
/// State da tela, ele seria descartado junto com ela e a pergunta ficaria
/// pendurada sem resposta para sempre.
///
/// A conversa é só de memória — nada toca o disco. O que o cidadão digita
/// costuma incluir CPF, endereço e às vezes dado de saúde, e não gravar é o
/// que evita criar obrigação de retenção do lado do aplicativo.
///
/// ATENÇÃO: por ser compartilhado, sobrevive à troca de usuário. [reset] é
/// chamado no logout (`core/widgets/logout_action.dart`) — sem isso, o próximo
/// usuário veria a conversa do anterior. Se algum dia existir outro caminho de
/// saída de sessão, ele também precisa chamar o reset.
class SupportChatStore extends ChangeNotifier {
  SupportChatStore._();

  static final SupportChatStore instance = SupportChatStore._();

  final SupportChatService _service = SupportChatMockService();

  List<ChatMessage> _messages = _seed();
  bool _isAwaitingReply = false;
  bool _isEnded = false;
  int _sequence = 0;

  /// Invalida respostas que ainda estavam a caminho quando a sessão terminou.
  ///
  /// Sem isto: o usuário manda "meu CPF é X", sai da conta, e um segundo
  /// depois a resposta chega e é anexada ao store recém-limpo — que agora é a
  /// conversa do PRÓXIMO usuário.
  int _epoch = 0;

  /// Ordem cronológica: a mais antiga primeiro. A tela é quem inverte para
  /// exibir.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get isAwaitingReply => _isAwaitingReply;

  /// Conversa encerrada pelo usuário: continua legível, mas não aceita mais
  /// mensagens. A limpeza é adiada para a próxima abertura da tela.
  bool get isEnded => _isEnded;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isAwaitingReply || _isEnded) return;

    final message = ChatMessage(
      id: _nextId(),
      author: ChatAuthor.user,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    _messages = [..._messages, message];
    _isAwaitingReply = true;
    notifyListeners();

    await _requestReply(message);
  }

  /// Reenvia uma mensagem que falhou, no lugar onde ela já está.
  Future<void> retry(String messageId) async {
    if (_isAwaitingReply || _isEnded) return;

    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;

    final restored = _messages[index].copyWith(status: ChatMessageStatus.sent);
    _messages = [..._messages]..[index] = restored;
    _isAwaitingReply = true;
    notifyListeners();

    await _requestReply(restored);
  }

  Future<void> _requestReply(ChatMessage message) async {
    final epoch = _epoch;

    try {
      final reply = await _service.reply(
        text: message.text,
        // Sem a própria pergunta: ela vai em `text`.
        history: _messages.where((m) => m.id != message.id).toList(),
      );
      // A sessão terminou enquanto a resposta vinha — descartar.
      if (epoch != _epoch) return;

      _messages = [
        ..._messages,
        ChatMessage(
          id: _nextId(),
          author: ChatAuthor.assistant,
          text: reply,
          sentAt: DateTime.now(),
        ),
      ];
    } catch (_) {
      if (epoch != _epoch) return;

      // A mensagem permanece na lista, marcada — apagá-la descartaria o que o
      // cidadão escreveu, às vezes um parágrafo inteiro.
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index >= 0) {
        _messages = [..._messages]..[index] = _messages[index].copyWith(
          status: ChatMessageStatus.failed,
        );
      }
    } finally {
      if (epoch == _epoch) {
        _isAwaitingReply = false;
        notifyListeners();
      }
    }
  }

  /// Encerra a conversa em curso.
  ///
  /// Nada é apagado agora: o usuário continua podendo reler o que foi dito. A
  /// limpeza acontece em [restartIfEnded], na próxima vez que a tela abrir.
  void end() {
    if (_isEnded) return;

    // Mesma invalidação do reset: uma resposta a caminho não pode aterrissar
    // numa conversa que o usuário já deu por encerrada. Como a época muda, o
    // `finally` do envio não vai mais mexer no estado — daí zerar aqui.
    _epoch++;
    _isEnded = true;
    _isAwaitingReply = false;
    notifyListeners();
  }

  /// Chamado ao abrir a tela. É o que faz o encerramento surtir efeito só
  /// depois de sair e voltar.
  void restartIfEnded() {
    if (!_isEnded) return;
    reset();
  }

  void reset() {
    _epoch++;
    _messages = _seed();
    _isAwaitingReply = false;
    _isEnded = false;
    notifyListeners();
  }

  String _nextId() => '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  /// A conversa nunca nasce vazia: além de dar as boas-vindas, isso evita um
  /// estado vazio ancorado no rodapé, que é como ele apareceria numa lista
  /// invertida.
  static List<ChatMessage> _seed() {
    return [
      ChatMessage(
        id: 'welcome',
        author: ChatAuthor.assistant,
        text:
            'Olá! Sou o assistente virtual da prefeitura. Posso ajudar a '
            'entender como abrir e acompanhar protocolos pelo aplicativo. '
            'Sobre o que você quer saber?',
        sentAt: DateTime.now(),
      ),
    ];
  }
}
