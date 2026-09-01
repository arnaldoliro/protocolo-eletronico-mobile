/// Dados enviados ao backend para abrir um protocolo.
///
/// Não carrega CPF nem qualquer identificação do requerente **de propósito**:
/// quem abriu o protocolo é derivado da sessão no backend. Aceitar um id vindo
/// do cliente seria abrir a porta para alguém abrir protocolo em nome de
/// outra pessoa.
///
/// ATENÇÃO — LGPD: a descrição é texto livre do cidadão e pode conter dado
/// pessoal. Nunca logar, nunca persistir localmente, nunca mandar a
/// analytics. `toString()` NÃO é sobrescrito.
class NewProcessRequest {
  final String categoryId;
  final String sizeId;
  final String subjectId;
  final String departmentId;
  final String location;
  final String description;

  /// Vazio quando o usuário não preencheu.
  final String observations;

  const NewProcessRequest({
    required this.categoryId,
    required this.sizeId,
    required this.subjectId,
    required this.departmentId,
    required this.location,
    required this.description,
    this.observations = '',
  });
}
