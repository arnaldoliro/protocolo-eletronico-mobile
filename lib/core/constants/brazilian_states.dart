/// Unidade federativa do Brasil. Dado geográfico estático — não é regra de
/// negócio. A coerência do par UF/cidade é validada pelo backend.
class BrazilianState {
  final String code;
  final String name;

  const BrazilianState(this.code, this.name);
}

const brazilianStates = <BrazilianState>[
  BrazilianState('AC', 'Acre'),
  BrazilianState('AL', 'Alagoas'),
  BrazilianState('AP', 'Amapá'),
  BrazilianState('AM', 'Amazonas'),
  BrazilianState('BA', 'Bahia'),
  BrazilianState('CE', 'Ceará'),
  BrazilianState('DF', 'Distrito Federal'),
  BrazilianState('ES', 'Espírito Santo'),
  BrazilianState('GO', 'Goiás'),
  BrazilianState('MA', 'Maranhão'),
  BrazilianState('MT', 'Mato Grosso'),
  BrazilianState('MS', 'Mato Grosso do Sul'),
  BrazilianState('MG', 'Minas Gerais'),
  BrazilianState('PA', 'Pará'),
  BrazilianState('PB', 'Paraíba'),
  BrazilianState('PR', 'Paraná'),
  BrazilianState('PE', 'Pernambuco'),
  BrazilianState('PI', 'Piauí'),
  BrazilianState('RJ', 'Rio de Janeiro'),
  BrazilianState('RN', 'Rio Grande do Norte'),
  BrazilianState('RS', 'Rio Grande do Sul'),
  BrazilianState('RO', 'Rondônia'),
  BrazilianState('RR', 'Roraima'),
  BrazilianState('SC', 'Santa Catarina'),
  BrazilianState('SP', 'São Paulo'),
  BrazilianState('SE', 'Sergipe'),
  BrazilianState('TO', 'Tocantins'),
];
