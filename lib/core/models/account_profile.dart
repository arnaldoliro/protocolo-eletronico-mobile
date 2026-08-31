/// Perfil do usuário autenticado, como o backend devolve.
///
/// ATENÇÃO — LGPD: carrega dado pessoal (e-mail, celular, endereço). Nunca
/// logar (`print`/`debugPrint`), nunca persistir localmente e nunca enviar a
/// analytics ou crash reporting. Por isso `toString()` NÃO é sobrescrito.
class AccountProfile {
  final String name;

  /// Não editável pelo usuário. Trocar e-mail exige confirmação de posse do
  /// endereço novo — fluxo próprio, do backend.
  final String email;

  /// CPF **já mascarado pelo backend** (ex.: "529.***.***-25).
  /// NUNCA aplicar lógica de mascaramento no frontend: é regra de segurança
  /// e pertence ao backend (ver CLAUDE.md). Este campo é só apresentação.
  ///
  /// O valor completo nunca mora aqui — ele é obtido sob demanda por
  /// [ProfileService.revealCpf] e vive apenas no State da tela.
  final String maskedCpf;

  /// Apenas dígitos.
  final String phone;

  /// Apenas dígitos (8).
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;

  /// Sigla da UF, ex.: 'SP'.
  final String stateCode;
  final String city;

  const AccountProfile({
    required this.name,
    required this.email,
    required this.maskedCpf,
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
