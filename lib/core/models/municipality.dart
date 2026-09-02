/// Um município atendido pelo sistema.
///
/// Cada município é um tenant: banco próprio, alcançado por um subdomínio
/// próprio. Escolher o município é, na prática, escolher contra qual servidor
/// o app vai falar.
class Municipality {
  final String id;
  final String name;

  /// Sigla da UF, ex.: 'BA'. Existe para desambiguar cidades homônimas.
  final String stateCode;

  /// Subdomínio do tenant. É daqui que sai o `baseUrl` quando a camada HTTP
  /// existir — ainda não é lido por ninguém, mas está no contrato desde já
  /// para o dado persistido não precisar de migração depois.
  final String subdomain;

  const Municipality({
    required this.id,
    required this.name,
    required this.stateCode,
    required this.subdomain,
  });

  /// Como o município aparece para o usuário.
  String get label => '$name - $stateCode';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stateCode': stateCode,
    'subdomain': subdomain,
  };

  /// Devolve nulo quando o dado gravado está incompleto ou corrompido — o app
  /// cai no seletor em vez de subir com um tenant meio preenchido.
  static Municipality? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final stateCode = json['stateCode'];
    final subdomain = json['subdomain'];

    if (id is! String || name is! String || stateCode is! String || subdomain is! String) {
      return null;
    }
    return Municipality(
      id: id,
      name: name,
      stateCode: stateCode,
      subdomain: subdomain,
    );
  }
}
