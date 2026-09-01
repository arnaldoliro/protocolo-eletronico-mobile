import 'package:flutter/material.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/state/support_chat_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/typing_indicator.dart';

/// Suporte por assistente virtual.
///
// TODO(suporte): esta tela substituiu o placeholder de canal de suporte, mas a
// dívida original continua: NÃO existe caminho para um atendente humano. O
// assistente é automático e sem escalonamento, enquanto o rótulo no menu
// segue "Suporte" — que promete atendimento. Ouvidoria acessível é exigência
// da Lei 13.460/2017; definir o canal (e-mail, telefone, formulário) antes de
// produção. Horários, telefones e prazos vêm do backend, nada fixado no app.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // A conversa e o envio vivem no store, não aqui: sair da tela enquanto a
  // resposta vem não pode descartá-la.
  final SupportChatStore _store = SupportChatStore.instance;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Se a conversa anterior foi encerrada, começa uma nova agora. É o que faz
    // o encerramento surtir efeito ao sair e voltar, em vez de apagar na cara
    // do usuário no instante em que ele encerra.
    _store.restartIfEnded();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmEnd() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Encerrar conversa',
      message:
          'Você poderá reler o que foi dito, mas não enviar novas mensagens. '
          'Ao sair e voltar, uma conversa nova começa.',
      confirmLabel: 'Encerrar',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    _store.end();
    _controller.clear();
    FocusScope.of(context).unfocus();
    announceToScreenReader(context, 'Conversa encerrada.');
  }

  void _send(String text) {
    _store.send(text);
    _controller.clear();

    // Com a lista invertida, o deslocamento 0 é o rodapé e é válido
    // independente do layout novo — nada de esperar o próximo quadro, como
    // seria preciso numa lista normal para conhecer o maxScrollExtent.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Suporte'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
        actions: [
          ListenableBuilder(
            listenable: _store,
            builder: (context, _) => PopupMenuButton<void>(
              enabled: !_store.isEnded,
              tooltip: 'Mais opções',
              icon: const Icon(Icons.more_vert),
              // Cor explícita: o menu puxa do ThemeData, que não acompanha as
              // paletas de alto contraste.
              color: colors.surface,
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: _confirmEnd,
                  child: Text(
                    'Encerrar conversa',
                    style: TextStyle(color: colors.inputText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // resizeToAvoidBottomInset fica no default: o Scaffold já remove o
      // viewInsets do corpo, então qualquer conta manual de teclado aqui
      // dentro seria código morto.
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final messages = _store.messages;
          final latestAssistantId = _latestAssistantId(messages);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  // Cresce de baixo para cima, como um chat: a âncora é o
                  // rodapé, então mensagem nova e teclado abrindo não exigem
                  // rolagem programática.
                  reverse: true,
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Os dados ficam em ordem cronológica; só a exibição
                    // inverte.
                    final message = messages[messages.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChatBubble(
                        // A chave é requisito de acessibilidade: sem ela, ao
                        // inserir uma mensagem os índices deslocam e o foco do
                        // leitor de tela fica sobre outro conteúdo.
                        key: ValueKey(message.id),
                        message: message,
                        isLatestAssistantMessage:
                            message.id == latestAssistantId,
                        onRetry: () => _store.retry(message.id),
                      ),
                    );
                  },
                ),
              ),

              if (_store.isAwaitingReply) const TypingIndicator(),
              if (_store.isEnded) _buildEndedMarker(colors),

              SafeArea(
                top: false,
                child: Column(
                  children: [
                    const AiDisclaimer(),
                    ChatComposer(
                      controller: _controller,
                      isAwaitingReply: _store.isAwaitingReply,
                      enabled: !_store.isEnded,
                      onSend: _send,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Fica fora da lista, pelo mesmo motivo do indicador de digitando: dentro
  /// dela viraria um item sintético com índice invertido.
  Widget _buildEndedMarker(AppColors colors) {
    return Semantics(
      label: 'Conversa encerrada. Ao sair e voltar, uma nova começa.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: colors.inputBorder)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Conversa encerrada',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: colors.inputBorder)),
            ],
          ),
        ),
      ),
    );
  }

  /// Só a resposta mais recente é região viva — marcar todas faria o leitor de
  /// tela reler a conversa, e marcar "a última mensagem" faria ele repetir o
  /// que o próprio usuário acabou de digitar.
  String? _latestAssistantId(List<ChatMessage> messages) {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].author == ChatAuthor.assistant) return messages[i].id;
    }
    return null;
  }
}
