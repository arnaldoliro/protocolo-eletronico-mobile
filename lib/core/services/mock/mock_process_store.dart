import '../../models/process_model.dart';

// TODO: remover ao integrar o backend real
//
// Guarda os protocolos em memória para a Home e a listagem serem a mesma
// fonte, e para um protocolo recém-criado aparecer nas duas. É o papel que a
// base de dados cumpre no backend.
//
// ATENÇÃO: por ser compartilhado, sobrevive à troca de usuário. [reset] é
// chamado no logout (`core/widgets/logout_action.dart`) — sem isso, o próximo
// usuário veria os protocolos do anterior. Se algum dia existir outro caminho
// de saída de sessão, ele também precisa chamar o reset.
class MockProcessStore {
  MockProcessStore._();

  static final MockProcessStore instance = MockProcessStore._();

  List<ProcessModel> _processes = _seed();

  List<ProcessModel> get all => List.unmodifiable(_processes);

  void add(ProcessModel process) {
    _processes = [process, ..._processes];
  }

  void reset() {
    _processes = _seed();
  }

  static List<ProcessModel> _seed() {
    final now = DateTime.now();
    ProcessModel make(
      String id,
      String type,
      ProcessStatus status,
      int daysAgo,
      String number,
    ) {
      return ProcessModel(
        id: id,
        type: type,
        status: status,
        date: now.subtract(Duration(days: daysAgo)),
        protocolNumber: number,
        requesterMaskedCpf: '123.***.***-00',
      );
    }

    // Amostra cobrindo os 5 status e datas espalhadas, para exercitar todos
    // os filtros.
    return [
      make('001', 'Declaração de tempo de serviço', ProcessStatus.emTramitacao, 2, '000123/2026'),
      make('002', 'Poda ou remoção de árvore em via pública', ProcessStatus.emAnalise, 5, '000118/2026'),
      make('003', 'Revisão de IPTU', ProcessStatus.pendente, 9, '000117/2026'),
      make('004', 'Manutenção de iluminação pública', ProcessStatus.aprovado, 14, '000112/2026'),
      make('005', 'Tapa-buraco', ProcessStatus.emTramitacao, 21, '000109/2026'),
      make('006', 'Licença ambiental', ProcessStatus.emAnalise, 28, '000104/2026'),
      make('007', 'Poda ou remoção de árvore em via pública', ProcessStatus.cancelado, 45, '000098/2026'),
      make('008', 'Declaração de tempo de serviço', ProcessStatus.aprovado, 63, '000091/2026'),
      make('009', 'Revisão de IPTU', ProcessStatus.aprovado, 90, '000077/2026'),
      make('010', 'Tapa-buraco', ProcessStatus.pendente, 130, '000065/2026'),
      make('011', 'Manutenção de iluminação pública', ProcessStatus.cancelado, 200, '000042/2026'),
      make('012', 'Licença ambiental', ProcessStatus.aprovado, 400, '000015/2025'),
    ];
  }
}
