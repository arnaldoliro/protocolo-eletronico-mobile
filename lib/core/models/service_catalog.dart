/// Opções que o cidadão escolhe ao abrir um protocolo. Tudo vem do backend —
/// o app não deriva, não ordena e não filtra nada.
class ServiceCategory {
  final String id;
  final String name;

  const ServiceCategory({required this.id, required this.name});
}

/// Porte do serviço (simples, intermediário, complexo...). O que cada porte
/// significa em prazo ou taxa é regra de negócio e vive no backend.
class ServiceSize {
  final String id;
  final String name;

  const ServiceSize({required this.id, required this.name});
}

/// Secretaria / órgão de destino.
class Department {
  final String id;
  final String name;

  const Department({required this.id, required this.name});
}

class ServiceSubject {
  final String id;
  final String name;

  /// Categoria e secretaria às quais este assunto pertence.
  ///
  /// Os dois campos existem no contrato desde já, mas a tela ainda NÃO os
  /// usa para filtrar: o vínculo entre categoria, assunto e secretaria é
  /// decisão do backend.
  // TODO(catalogo): quando o backend expuser o vínculo, ligar a cascata —
  // escolher a categoria filtra os assuntos, e o assunto define a secretaria.
  // Ao fazer isso: zerar valor E lista no MESMO setState (o
  // DropdownButtonFormField dispara assert se o valor selecionado não estiver
  // entre os items), guardar o async com um request id como o
  // `_citiesRequestId` de personal_data_card.dart, e deduplicar ids repetidos
  // entre grupos — dois items com o mesmo valor também estouram o assert.
  final String categoryId;
  final String departmentId;

  const ServiceSubject({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.departmentId,
  });
}

/// Todas as listas do formulário, numa única resposta.
class ServiceCatalog {
  final List<ServiceCategory> categories;
  final List<ServiceSize> sizes;
  final List<ServiceSubject> subjects;
  final List<Department> departments;

  const ServiceCatalog({
    required this.categories,
    required this.sizes,
    required this.subjects,
    required this.departments,
  });
}
