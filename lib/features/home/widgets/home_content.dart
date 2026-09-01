import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/models/user_model.dart';
import 'accessibility_bar.dart';
import 'home_header.dart';
import 'new_process_cta_card.dart';
import 'ongoing_processes_section.dart';
import 'summary_section.dart';

/// Conteúdo central da Home — o que desliza horizontalmente quando um
/// painel lateral é aberto pelo [HomeShell].
class HomeContent extends StatelessWidget {
  final UserModel user;

  /// Protocolos em andamento. A lista vive no [HomeShell] — aqui ela era um
  /// campo `static final`, que sobreviveria ao logout e mostraria os dados do
  /// usuário anterior para o próximo quando o login for de verdade.
  final List<ProcessModel> processes;

  /// A navegação sai daqui para o shell: agora que abrir um protocolo devolve
  /// um resultado, quem precisa consumi-lo é quem tem o estado da lista.
  final VoidCallback onNewProcessTap;

  const HomeContent({
    super.key,
    required this.user,
    required this.processes,
    required this.onNewProcessTap,
  });

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

          // "Em andamento" é o tamanho da lista — contar é apresentação.
          // Já classificar status em "concluído" e "aviso" seria regra de
          // negócio: o resumo tem que vir pronto do backend, senão o app
          // diverge dele na primeira integração sem ninguém perceber.
          // TODO: substituir pelos contadores que o backend devolver.
          StatsRow(inProgress: processes.length, completed: 0, warnings: 0),
          const SizedBox(height: 20),

          NewProcessCtaCard(onTap: onNewProcessTap),
          const SizedBox(height: 28),

          OngoingProcessesSection(processes: processes),
        ],
      ),
    );
  }
}
