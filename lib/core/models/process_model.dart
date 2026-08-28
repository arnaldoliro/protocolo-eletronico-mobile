enum ProcessStatus { emAnalise, aprovado, pendente, cancelado, emTramitacao }

enum StepStatus { completed, current, pending }

class ProcessStep {
  final String label;
  final StepStatus status;
  final DateTime? completedAt;

  const ProcessStep({
    required this.label,
    required this.status,
    this.completedAt,
  });
}

extension ProcessStatusExtension on ProcessStatus {
  String get label => switch (this) {
    ProcessStatus.emAnalise => 'Em análise',
    ProcessStatus.aprovado => 'Aprovado',
    ProcessStatus.pendente => 'Pendente',
    ProcessStatus.cancelado => 'Cancelado',
    ProcessStatus.emTramitacao => 'Em Tramitação',
  };
}

class ProcessModel {
  final String id;
  final String type;
  final ProcessStatus status;
  final DateTime date;

  /// Número de protocolo já formatado pelo backend (ex.: "000123/2026").
  /// Exibido tal como recebido — nenhuma formatação/lógica adicional aqui.
  final String protocolNumber;

  /// CPF do requerente já mascarado pelo backend (ex.: "123.***.***-00").
  /// NUNCA aplicar lógica de mascaramento no frontend: é regra de segurança
  /// e pertence ao backend (ver CLAUDE.md). Este campo é só apresentação.
  final String requesterMaskedCpf;

  const ProcessModel({
    required this.id,
    required this.type,
    required this.status,
    required this.date,
    required this.protocolNumber,
    required this.requesterMaskedCpf,
  });
}

/// Formatação puramente apresentacional (não é regra de negócio).
extension ProcessModelPresentation on ProcessModel {
  String get openedRelativeLabel {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Aberto hoje';
    if (days == 1) return 'Aberto há 1 dia';
    return 'Aberto há $days dias';
  }
}
