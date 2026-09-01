import '../models/service_catalog.dart';

/// Catálogo de serviços oferecido pelo órgão.
///
/// Um método só, de propósito: a tela tem uma entrada, um estado de carga, um
/// spinner e um retry. Um método por lista daria três de cada, sem ganho.
///
/// O conteúdo é do backend — categorias, portes, assuntos e secretarias mudam
/// por decisão administrativa, e fixá-los no app faria cada mudança exigir um
/// release na loja.
abstract class ProcessCatalogService {
  Future<ServiceCatalog> loadCatalog();
}
