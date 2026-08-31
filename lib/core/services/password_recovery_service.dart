/// Solicita o envio do link de redefinição de senha.
///
/// SEGURANÇA — requisitos que são do BACKEND, não desta camada:
///  - resposta idêntica em status, corpo e LATÊNCIA para e-mail cadastrado e
///    não cadastrado. Enviar e-mail leva centenas de ms, o no-op é
///    instantâneo: a diferença de tempo é um oráculo de enumeração tão bom
///    quanto a mensagem seria.
///  - rate limit por IP e por e-mail; sem isso o endpoint é um canhão de spam.
///  - o 429 do rate limit NÃO pode depender da existência do e-mail, senão
///    vira o mesmo oráculo por outra via.
///  - o token do link precisa ser de uso único, com validade curta, e ser
///    invalidado ao ser usado ou ao trocar a senha por outro caminho.
///
/// Esta interface NUNCA deve ganhar um erro tipado "e-mail não encontrado".
/// Sucesso = requisição aceita pelo servidor. Exceção = falha de transporte ou
/// de servidor, sobre a qual o app pode avisar sem vazar nada, porque o
/// servidor não emitiu juízo algum sobre o e-mail.
abstract class PasswordRecoveryService {
  Future<void> requestReset(String email);
}
