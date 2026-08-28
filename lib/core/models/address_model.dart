/// Endereço devolvido pela consulta de CEP. Todos os campos vêm do backend —
/// o app não deriva nem valida nenhum deles.
class AddressModel {
  /// Apenas dígitos (8).
  final String cep;
  final String street;
  final String neighborhood;
  final String city;

  /// Sigla da UF, ex.: 'SP'.
  final String stateCode;

  const AddressModel({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.stateCode,
  });
}
