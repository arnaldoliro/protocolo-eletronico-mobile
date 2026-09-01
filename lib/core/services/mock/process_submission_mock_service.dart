import '../../models/new_process_request.dart';
import '../../models/process_model.dart';
import '../process_submission_service.dart';

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

    return ProcessModel(
      id: 'mock-$_sequence',
      type: request.subjectId,
      status: ProcessStatus.emAnalise,
      date: DateTime.now(),
      protocolNumber: '$number/${DateTime.now().year}',
      // Valor enlatado: NÃO derivar do CPF do usuário logado.
      requesterMaskedCpf: '529.***.***-25',
    );
  }
}
