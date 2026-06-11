import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_access_row.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/summary_section.dart';
import '../widgets/recent_processes_section.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  static final _activitySteps = [
    ProcessStep(
      label: 'Protocolo recebido',
      status: StepStatus.completed,
      completedAt: DateTime(2026, 6, 1, 8, 30),
    ),
    ProcessStep(
      label: 'Em análise',
      status: StepStatus.current,
    ),
    ProcessStep(label: 'Documentação aprovada', status: StepStatus.pending),
    ProcessStep(label: 'Em tramitação', status: StepStatus.pending),
    ProcessStep(label: 'Concluído', status: StepStatus.pending),
  ];

  static final _recentProcesses = [
    ProcessModel(
      id: '001',
      type: 'Licença Ambiental',
      status: ProcessStatus.emAnalise,
      date: DateTime(2026, 6, 1),
    ),
    ProcessModel(
      id: '002',
      type: 'Declaração de Tempo de Serviço',
      status: ProcessStatus.aprovado,
      date: DateTime(2026, 5, 20),
    ),
    ProcessModel(
      id: '003',
      type: 'Alvará de Funcionamento',
      status: ProcessStatus.pendente,
      date: DateTime(2026, 5, 10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          children: [
            _Padded(child: HomeHeader(user: user)),
            const SizedBox(height: 28),

            // Seção Processos
            _Padded(
              child: Text(
                'Processos',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _Padded(child: ProcessActionsRow()),
            const SizedBox(height: 16),
            RecentProcessesSection(processes: _recentProcesses),
            const SizedBox(height: 28),

            // Seção Resumo
            const _Padded(
              child: SummarySection(
                inProgress: 5,
                completed: 7,
                pending: 3,
              ),
            ),
            const SizedBox(height: 28),

            // Seção Atividades Recentes
            _Padded(
              child: RecentActivitySection(
                process: _recentProcesses.first,
                steps: _activitySteps,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Padded extends StatelessWidget {
  final Widget child;
  const _Padded({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}
