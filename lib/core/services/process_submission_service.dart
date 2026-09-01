import '../models/new_process_request.dart';
import '../models/process_model.dart';

/// Abertura de protocolo.
///
/// Separado do [ProcessCatalogService] de propósito: ler o catálogo e criar um
/// protocolo são responsabilidades distintas, com permissões distintas quando
/// o backend existir.
abstract class ProcessSubmissionService {
  /// Devolve o protocolo criado, com número e demais campos **já formatados
  /// pelo backend**. O app não gera nem formata nenhum deles.
  ///
  /// SEGURANÇA: o requerente sai da sessão, nunca de um campo do request.
  Future<ProcessModel> submit(NewProcessRequest request);
}
