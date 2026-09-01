import '../../models/service_catalog.dart';
import '../process_catalog_service.dart';

// TODO: remover ao integrar o backend real
//
// Amostra pequena, só para exercitar a UI. A lista real é administrada pelo
// órgão e não deve ser versionada no cliente.
class ProcessCatalogMockService implements ProcessCatalogService {
  @override
  Future<ServiceCatalog> loadCatalog() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return const ServiceCatalog(
      categories: [
        ServiceCategory(id: 'amb', name: 'Meio ambiente'),
        ServiceCategory(id: 'obr', name: 'Obras e infraestrutura'),
        ServiceCategory(id: 'sau', name: 'Saúde'),
        ServiceCategory(id: 'edu', name: 'Educação'),
        ServiceCategory(id: 'trib', name: 'Tributos e arrecadação'),
      ],
      sizes: [
        ServiceSize(id: 'simples', name: 'Simples'),
        ServiceSize(id: 'inter', name: 'Intermediário'),
        ServiceSize(id: 'complexo', name: 'Complexo'),
      ],
      subjects: [
        // Nome longo de propósito: é o caso que estoura a altura fixa de item
        // do dropdown com a fonte no máximo.
        ServiceSubject(
          id: 'poda',
          name: 'Poda ou remoção de árvore em via pública',
          categoryId: 'amb',
          departmentId: 'sema',
        ),
        ServiceSubject(
          id: 'licenca-amb',
          name: 'Licença ambiental',
          categoryId: 'amb',
          departmentId: 'sema',
          paymentNotice:
              'Este assunto gera uma guia de pagamento (DAM). A emissão pode '
              'levar até um minuto — não feche a tela.',
        ),
        ServiceSubject(
          id: 'ilum',
          name: 'Manutenção de iluminação pública',
          categoryId: 'obr',
          departmentId: 'seinfra',
        ),
        ServiceSubject(
          id: 'buraco',
          name: 'Tapa-buraco',
          categoryId: 'obr',
          departmentId: 'seinfra',
        ),
        ServiceSubject(
          id: 'tempo-servico',
          name: 'Declaração de tempo de serviço',
          categoryId: 'edu',
          departmentId: 'semed',
        ),
        ServiceSubject(
          id: 'iptu',
          name: 'Revisão de IPTU',
          categoryId: 'trib',
          departmentId: 'sefaz',
          paymentNotice:
              'Este assunto gera uma guia de pagamento (DAM). A emissão pode '
              'levar até um minuto — não feche a tela.',
        ),
      ],
      departments: [
        Department(id: 'sema', name: 'Secretaria de Meio Ambiente'),
        Department(id: 'seinfra', name: 'Secretaria de Infraestrutura'),
        Department(id: 'semed', name: 'Secretaria de Educação'),
        Department(id: 'sesau', name: 'Secretaria de Saúde'),
        Department(id: 'sefaz', name: 'Secretaria da Fazenda'),
      ],
    );
  }
}
