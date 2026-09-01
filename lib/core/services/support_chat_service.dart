import '../models/chat_message.dart';

/// Assistente virtual do suporte.
///
/// Devolve o TEXTO da resposta, não uma [ChatMessage] pronta: id e horário são
/// carimbados por quem exibe. Um serviço que fabricasse a mensagem inteira
/// estaria inventando dados de servidor, e o tipo contradiria isso no dia da
/// integração.
///
/// Sem estado, com [history] explícito de propósito: um serviço que guardasse
/// a conversa internamente esconderia, de quem lê o código, que a transcrição
/// inteira sai do aparelho. Aqui isso fica visível no ponto de chamada.
///
/// SEGURANÇA e LGPD — responsabilidades do BACKEND, não desta camada:
///  - o histórico contém texto livre do cidadão, que costuma incluir CPF,
///    endereço e às vezes dado de saúde. Onde é registrado, por quanto tempo e
///    quem acessa são decisões que precisam estar tomadas ANTES de ligar num
///    provedor de IA — mandar isso a um terceiro é transferência de dado
///    pessoal.
///  - a identidade do usuário sai da sessão, nunca de um campo do request.
///  - NUNCA adicionar um parâmetro de instrução/prompt do lado do cliente:
///    qualquer texto embutido no app é lido por quem o descompilar, e a
///    fronteira entre "conteúdo do usuário" e "instrução do sistema" precisa
///    ficar no servidor. É o que impede injeção de prompt pelo conteúdo
///    digitado.
///  - o backend é a autoridade sobre o que o assistente pode afirmar. O app
///    apenas renderiza.
abstract class SupportChatService {
  Future<String> reply({
    required String text,
    required List<ChatMessage> history,
  });
}
