/// Campos que o usuário pode alterar no próprio perfil.
///
/// E-mail e CPF **não estão aqui de propósito**: desabilitar um campo na UI
/// não é proteção nenhuma (o app pode ser desmontado e o tráfego forjado), e
/// o backend precisa rejeitar qualquer tentativa de alterá-los. Não carregar
/// os campos é o que torna a intenção explícita.
///
/// ATENÇÃO — LGPD: dado pessoal. Nunca logar, nunca persistir, nunca mandar a
/// analytics. `toString()` NÃO é sobrescrito.
///
/// Celular e CEP chegam aqui apenas com dígitos — a tela remove a máscara
/// antes de montar o request.
class UpdateProfileRequest {
  final String name;
  final String phone;
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String stateCode;
  final String city;

  const UpdateProfileRequest({
    required this.name,
    required this.phone,
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.stateCode,
    required this.city,
  });
}
