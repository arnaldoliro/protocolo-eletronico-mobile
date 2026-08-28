import '../models/address_model.dart';

/// CEP com formato aceitável, mas inexistente na base. Distinta de falha de
/// rede: a mensagem ao usuário é diferente ("corrija o que digitou" vs.
/// "tente de novo").
class CepNotFoundException implements Exception {
  const CepNotFoundException();
}

abstract class AddressService {
  /// [cep] apenas dígitos (8). A consulta à base oficial é responsabilidade
  /// do backend — o app nunca fala com serviços externos de CEP diretamente.
  Future<AddressModel> findByCep(String cep);

  /// Cidades de uma UF, já ordenadas pelo backend.
  Future<List<String>> citiesByState(String stateCode);
}
