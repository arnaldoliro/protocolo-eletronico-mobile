import '../models/process_model.dart';
import '../models/process_query.dart';

/// Uma página de resultados.
///
/// [total] existe separado de `items.length` porque, quando o backend
/// paginar, o contador da tela precisa do total real e não do tamanho da
/// página. Hoje os dois coincidem.
class ProcessListResult {
  final List<ProcessModel> items;
  final int total;

  const ProcessListResult({required this.items, required this.total});
}

/// Listagem dos protocolos do usuário autenticado.
///
/// A busca e os filtros vão para o serviço, e não são aplicados na tela: com
/// o backend real, filtrar milhares de protocolos no cliente exigiria baixar
/// todos eles. A tela não muda quando a filtragem migrar para o servidor.
///
/// SEGURANÇA: os protocolos retornados são os do usuário da sessão. A consulta
/// nunca carrega identificação do requerente — aceitar um id vindo do cliente
/// permitiria listar processos alheios.
abstract class ProcessListService {
  Future<ProcessListResult> load(ProcessQuery query);
}
