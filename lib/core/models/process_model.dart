enum ProcessStatus { emAnalise, aprovado, pendente, cancelado }

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
  };
}

class ProcessModel {
  final String id;
  final String type;
  final ProcessStatus status;
  final DateTime date;

  const ProcessModel({
    required this.id,
    required this.type,
    required this.status,
    required this.date,
  });
}
