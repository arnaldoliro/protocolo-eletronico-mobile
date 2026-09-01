import 'process_model.dart';

/// Recortes de data oferecidos no filtro.
///
/// É um enum, e não um intervalo calculado: o que "últimos 30 dias" significa
/// — inclusivo ou não, em que fuso, dias corridos ou úteis — é decisão do
/// backend. Mandar o intervalo pronto seria mover essa regra para o app.
enum ProcessPeriod { any, last7Days, last30Days, thisYear }

extension ProcessPeriodLabel on ProcessPeriod {
  String get label => switch (this) {
    ProcessPeriod.any => 'Qualquer data',
    ProcessPeriod.last7Days => 'Últimos 7 dias',
    ProcessPeriod.last30Days => 'Últimos 30 dias',
    ProcessPeriod.thisYear => 'Este ano',
  };
}

/// O que a tela pede ao serviço de listagem.
///
/// Imutável e com igualdade por valor, para a tela poder comparar a consulta
/// nova com a atual sem disparar carga à toa.
class ProcessQuery {
  /// Casa número do protocolo e assunto. A normalização (caixa, acento) é do
  /// serviço, não daqui.
  final String text;

  final Set<ProcessStatus> statuses;
  final ProcessPeriod period;

  ProcessQuery({
    this.text = '',
    Set<ProcessStatus> statuses = const {},
    this.period = ProcessPeriod.any,
    // Cópia imutável: sem ela a folha de filtros mutaria por referência o
    // conjunto da tela, e cancelar a folha já teria alterado o estado.
  }) : statuses = Set.unmodifiable(statuses);

  /// Quantos filtros o botão deve anunciar.
  ///
  /// O texto NÃO entra: a busca tem campo próprio e visível, e contá-la
  /// deixaria o badge em 1 durante a digitação, sem nenhum filtro escolhido.
  int get activeFilterCount =>
      (statuses.isEmpty ? 0 : 1) + (period == ProcessPeriod.any ? 0 : 1);

  /// Inclui o texto — é o que distingue "não tenho protocolos" de "nada
  /// casou com a busca".
  bool get hasAnyFilter => text.trim().isNotEmpty || activeFilterCount > 0;

  ProcessQuery copyWith({
    String? text,
    Set<ProcessStatus>? statuses,
    ProcessPeriod? period,
  }) {
    return ProcessQuery(
      text: text ?? this.text,
      statuses: statuses ?? this.statuses,
      period: period ?? this.period,
    );
  }

  /// Zera filtros e busca.
  ProcessQuery cleared() => ProcessQuery();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcessQuery &&
        other.text == text &&
        other.period == period &&
        // Set não tem igualdade estrutural em Dart — comparar por referência
        // faria duas consultas iguais parecerem diferentes.
        other.statuses.length == statuses.length &&
        other.statuses.containsAll(statuses);
  }

  @override
  int get hashCode => Object.hash(
    text,
    period,
    // XOR é comutativo: a ordem do conjunto não altera o hash.
    statuses.fold<int>(0, (acc, s) => acc ^ s.hashCode),
  );
}
