import 'dart:collection';

/// Contrato mínimo das listas do catálogo, para a busca por id ser genérica.
/// Os quatro modelos abaixo já o satisfazem sem mudar nenhum campo.
abstract interface class CatalogEntry {
  String get id;
  String get name;
}

/// Opções que o cidadão escolhe ao abrir um protocolo. Tudo vem do backend —
/// o app não deriva, não ordena e não filtra nada.
class ServiceCategory implements CatalogEntry {
  @override
  final String id;
  @override
  final String name;

  const ServiceCategory({required this.id, required this.name});
}

/// Porte do serviço (simples, intermediário, complexo...). O que cada porte
/// significa em prazo ou taxa é regra de negócio e vive no backend.
class ServiceSize implements CatalogEntry {
  @override
  final String id;
  @override
  final String name;

  const ServiceSize({required this.id, required this.name});
}

/// Secretaria / órgão de destino.
class Department implements CatalogEntry {
  @override
  final String id;
  @override
  final String name;

  const Department({required this.id, required this.name});
}

class ServiceSubject implements CatalogEntry {
  @override
  final String id;
  @override
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

  /// Aviso exibido na revisão antes do envio, quando este serviço tem alguma
  /// particularidade (ex.: gera guia de pagamento).
  ///
  /// O TEXTO vem do backend, nunca do app: quais serviços cobram taxa é
  /// decisão administrativa e muda sem release.
  final String? paymentNotice;

  const ServiceSubject({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.departmentId,
    this.paymentNotice,
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

  String? categoryName(String? id) => _nameOf(categories, id);
  String? sizeName(String? id) => _nameOf(sizes, id);
  String? subjectName(String? id) => _nameOf(subjects, id);
  String? departmentName(String? id) => _nameOf(departments, id);

  ServiceSubject? subjectById(String? id) => _entryOf(subjects, id);

  /// Devolve nulo em vez de lançar: um id que sumiu do catálogo não pode
  /// derrubar a tela de revisão. `firstWhere` sem `orElse` lança.
  static String? _nameOf<T extends CatalogEntry>(List<T> items, String? id) =>
      _entryOf(items, id)?.name;

  static T? _entryOf<T extends CatalogEntry>(List<T> items, String? id) {
    if (id == null) return null;
    return items.where((e) => e.id == id).firstOrNull;
  }
}
