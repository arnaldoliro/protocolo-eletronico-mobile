import '../../models/new_process_request.dart';
import '../../models/process_model.dart';
import '../process_submission_service.dart';
import 'mock_process_store.dart';
import 'process_catalog_mock_service.dart';

// TODO: remover ao integrar o backend real
//
// A geração do número de protocolo e o mascaramento do CPF vivem aqui, dentro
// do mock, porque é o mock fingindo ser o backend. Nada disso pode escapar
// para um model, uma extension ou um widget: formatar e mascarar são
// responsabilidade do servidor (ver o comentário em ProcessModel).
class ProcessSubmissionMockService implements ProcessSubmissionService {
  int _sequence = 123;

  @override
  Future<ProcessModel> submit(NewProcessRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Gatilho para exercitar o caminho de erro da tela.
    if (request.location.trim().toLowerCase() == 'falha') {
      throw Exception('Falha de rede simulada');
    }

    _sequence++;
    final number = _sequence.toString().padLeft(6, '0');

    final process = ProcessModel(
      id: 'mock-$_sequence',
      // Nome legível, não o id cru: `type` é rótulo de exibição, e o backend
      // real devolveria o nome do assunto. Sem isto a busca por nome não
      // encontraria os protocolos recém-criados.
      type:
          kMockServiceCatalog.subjectName(request.subjectId) ??
          request.subjectId,
      status: ProcessStatus.emAnalise,
      date: DateTime.now(),
      protocolNumber: '$number/${DateTime.now().year}',
      // Valor enlatado: NÃO derivar do CPF do usuário logado.
      requesterMaskedCpf: '529.***.***-25',
    );

    // Persiste, como o backend faria: é o que mantém a Home e a listagem
    // mostrando o mesmo conjunto.
    MockProcessStore.instance.add(process);
    return process;
  }
}
