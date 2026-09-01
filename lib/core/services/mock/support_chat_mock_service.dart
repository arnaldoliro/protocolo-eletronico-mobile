import '../../models/chat_message.dart';
import '../support_chat_service.dart';

// TODO: remover ao integrar o backend real
//
// As respostas são deliberadamente GENÉRICAS: nenhuma cita prazo, valor,
// artigo de lei, telefone ou horário, e nenhuma afirma que consultou, abriu ou
// verificou um protocolo.
//
// Não é preciosismo. Resposta convincente num mock vira captura de tela em
// reunião, captura vira expectativa e expectativa vira requisito — e conteúdo
// procedimental fixado no app é exatamente o que os TODO(suporte) e
// TODO(ajuda) já proíbem: isso muda por decisão administrativa e teria de
// esperar um release na loja para ser corrigido.
class SupportChatMockService implements SupportChatService {
  @override
  Future<String> reply({
    required String text,
    required List<ChatMessage> history,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // Mesmo gatilho de erro do ProcessListMockService — consistência entre
    // mocks vale mais que criatividade.
    if (_normalize(text) == 'falha') {
      throw Exception('Falha de rede simulada');
    }

    final normalized = _normalize(text);
    for (final entry in _cannedReplies.entries) {
      if (entry.key.any(normalized.contains)) return entry.value;
    }
    return _fallback;
  }

  static const _closing =
      '\n\nConfirme sempre nos canais oficiais da prefeitura antes de contar '
      'com qualquer prazo ou exigência.';

  static const _fallback =
      'Ainda estou aprendendo e posso não ter a resposta para isso. Você pode '
      'reformular a pergunta, ou procurar o atendimento da prefeitura.$_closing';

  static const _cannedReplies = <List<String>, String>{
    ['abrir', 'novo protocolo', 'solicitar', 'solicitacao']:
        'Para abrir um protocolo, use "Abrir novo protocolo" na tela inicial. '
        'O aplicativo pede a categoria, o assunto, o local e uma descrição do '
        'que você precisa.$_closing',
    ['acompanhar', 'andamento', 'status', 'meus protocolos', 'consultar']:
        'Você acompanha seus protocolos em "Meus protocolos", pela lupa na '
        'barra inferior ou pelo menu. Lá dá para buscar pelo número ou pelo '
        'assunto e filtrar pela situação.$_closing',
    ['documento', 'anexo', 'procuracao', 'arquivo']:
        'Os documentos exigidos aparecem no segundo passo da abertura do '
        'protocolo. Quando alguém solicita em nome de outra pessoa, costuma '
        'ser necessária procuração e documento com foto.$_closing',
    ['senha', 'entrar', 'login', 'acesso', 'cadastro']:
        'Dá para trocar a senha em "Minha conta". Se não conseguir entrar, a '
        'tela de acesso tem a opção "Esqueceu a senha?", que envia um link '
        'para o seu e-mail.$_closing',
  };

  /// Caixa baixa e sem acento, para "solicitacao" casar com "solicitação".
  static String _normalize(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(_accentFolding[char] ?? char);
    }
    return buffer.toString();
  }

  static const _accentFolding = <String, String>{
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };
}
