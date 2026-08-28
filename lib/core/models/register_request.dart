enum RegistrationType { individual, company }

extension RegistrationTypeLabel on RegistrationType {
  String get label => switch (this) {
    RegistrationType.individual => 'Pessoa Física',
    RegistrationType.company => 'Pessoa Jurídica',
  };
}

/// Dados enviados ao backend para criar uma conta.
///
/// ATENÇÃO — LGPD: carrega dado pessoal (CPF, e-mail, celular, endereço) e a
/// senha em claro. Nunca logar (`print`/`debugPrint`), nunca persistir
/// localmente e nunca enviar a analytics ou crash reporting. Por isso
/// `toString()` NÃO é sobrescrito.
///
/// CPF, celular e CEP chegam aqui apenas com dígitos — a tela remove a
/// máscara antes de montar o request.
class RegisterRequest {
  final RegistrationType type;

  /// Pessoa Física: nome do titular. Pessoa Jurídica: nome do responsável legal.
  final String fullName;

  /// Pessoa Física: CPF do titular. Pessoa Jurídica: CPF do responsável legal.
  /// Apenas dígitos.
  final String cpf;

  /// Apenas dígitos. Preenchido somente quando [type] é
  /// [RegistrationType.company].
  final String? cnpj;

  /// Razão social. Preenchida somente quando [type] é
  /// [RegistrationType.company].
  final String? companyName;

  final String email;
  final String phone;
  final String password;
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String stateCode;
  final String city;
  final bool acceptedTerms;

  const RegisterRequest({
    required this.type,
    required this.fullName,
    required this.cpf,
    this.cnpj,
    this.companyName,
    required this.email,
    required this.phone,
    required this.password,
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.stateCode,
    required this.city,
    required this.acceptedTerms,
  });
}
