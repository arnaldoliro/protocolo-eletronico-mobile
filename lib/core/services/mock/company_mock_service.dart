import '../company_service.dart';

// TODO: remover ao integrar o backend real
//
// A consulta real de CNPJ depende da Receita Federal e é intermediada pelo
// backend. Este mock só exercita a UI.
class CompanyMockService implements CompanyService {
  static const _byCnpj = <String, String>{
    '11222333000181': 'Construtora Exemplo Ltda',
    '11444777000161': 'Serviços Municipais S.A.',
  };

  @override
  Future<String> findCompanyName(String cnpj) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final name = _byCnpj[cnpj];
    if (name == null) throw const CompanyNotFoundException();
    return name;
  }
}
