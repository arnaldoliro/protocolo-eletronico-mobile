/// CNPJ com formato aceitável, mas inexistente na base. Distinta de falha de
/// rede: a mensagem ao usuário é diferente.
class CompanyNotFoundException implements Exception {
  const CompanyNotFoundException();
}

abstract class CompanyService {
  /// Devolve a razão social de um CNPJ. [cnpj] apenas dígitos (14).
  ///
  /// A consulta à base oficial (Receita Federal) é responsabilidade do
  /// backend — o app nunca fala com serviços externos diretamente.
  Future<String> findCompanyName(String cnpj);
}
