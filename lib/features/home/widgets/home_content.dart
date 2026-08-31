import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/models/user_model.dart';
import '../../new_process/screens/new_process_screen.dart';
import 'accessibility_bar.dart';
import 'home_header.dart';
import 'new_process_cta_card.dart';
import 'ongoing_processes_section.dart';
import 'summary_section.dart';

/// Conteúdo central da Home — o que desliza horizontalmente quando um
/// painel lateral é aberto pelo [HomeShell].
class HomeContent extends StatelessWidget {
  final UserModel user;

  const HomeContent({super.key, required this.user});

  // TODO: dado mockado — substituir pela listagem real de processos do
  // usuário assim que o backend estiver disponível.
  static final _ongoingProcesses = [
    ProcessModel(
      id: '001',
      type: 'Declaração de Tempo de Serviço',
      status: ProcessStatus.emTramitacao,
      date: DateTime.now().subtract(const Duration(days: 2)),
      protocolNumber: '000123/2026',
      requesterMaskedCpf: '123.***.***-00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        // Espaço extra embaixo para o último card não ficar sob o FAB.
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
        children: [
          const AccessibilityBar(),
          const SizedBox(height: 20),
          HomeHeader(user: user),
          const SizedBox(height: 20),

          // TODO: dados mockados — "Avisos" fica em 0 até definirmos a
          // fonte real (notificações vs. processos pendentes).
          const StatsRow(inProgress: 1, completed: 0, warnings: 0),
          const SizedBox(height: 20),

          // TODO(protocolo): ver o TODO em HomeShell._openNewProcess — este
          // push também precisará consumir o protocolo criado.
          NewProcessCtaCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NewProcessScreen()),
            ),
          ),
          const SizedBox(height: 28),

          OngoingProcessesSection(processes: _ongoingProcesses),
        ],
      ),
    );
  }
}
