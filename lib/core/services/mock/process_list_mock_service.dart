import '../../models/process_query.dart';
import '../process_list_service.dart';
import 'mock_process_store.dart';

// TODO: remover ao integrar o backend real
//
// Filtra, normaliza e ordena aqui de propósito: é o papel do servidor. A tela
// só manda a consulta e desenha o resultado.
class ProcessListMockService implements ProcessListService {
  @override
  Future<ProcessListResult> load(ProcessQuery query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Gatilho para exercitar o caminho de erro da tela.
    if (_normalize(query.text) == 'falha') {
      throw Exception('Falha de rede simulada');
    }

    final text = _normalize(query.text);
    final cutoff = _cutoffFor(query.period);

    final items =
        MockProcessStore.instance.all.where((p) {
          if (query.statuses.isNotEmpty && !query.statuses.contains(p.status)) {
            return false;
          }
          if (cutoff != null && p.date.isBefore(cutoff)) return false;
          if (text.isEmpty) return true;
          return _normalize(p.type).contains(text) ||
              _normalize(p.protocolNumber).contains(text);
        }).toList()
        // Mais recentes primeiro. A ordenação é decisão do servidor; está
        // aqui porque este mock faz o papel dele.
        ..sort((a, b) => b.date.compareTo(a.date));

    return ProcessListResult(items: items, total: items.length);
  }

  DateTime? _cutoffFor(ProcessPeriod period) {
    final now = DateTime.now();
    return switch (period) {
      ProcessPeriod.any => null,
      ProcessPeriod.last7Days => now.subtract(const Duration(days: 7)),
      ProcessPeriod.last30Days => now.subtract(const Duration(days: 30)),
      ProcessPeriod.thisYear => DateTime(now.year),
    };
  }

  /// Caixa baixa e sem acento, para "arvore" encontrar "árvore".
  ///
  /// `toLowerCase` resolve a caixa, mas não dobra acento — e o app não tem
  /// `intl`. A tabela vive aqui, no mock, porque normalizar a busca é o que o
  /// backend faria.
  static String _normalize(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(_accentFolding[char] ?? char);
    }
    return buffer.toString();
  }

  static const _accentFolding = <String, String>{
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };
}
