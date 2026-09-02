import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

/// Painel lateral esquerdo, revelado ao deslizar o conteúdo para a direita.
/// Puramente apresentacional — quem navega é o [HomeShell], via callbacks.
class MenuPanel extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAccountTap;
  final VoidCallback onAccessibilityTap;
  final VoidCallback onNewProcessTap;
  final VoidCallback onTrackProcessesTap;
  final VoidCallback onSupportTap;
  final VoidCallback onNoticesTap;
  final VoidCallback onChangeMunicipalityTap;
  final VoidCallback onLogoutTap;

  const MenuPanel({
    super.key,
    required this.user,
    required this.onAccountTap,
    required this.onAccessibilityTap,
    required this.onNewProcessTap,
    required this.onTrackProcessesTap,
    required this.onSupportTap,
    required this.onNoticesTap,
    required this.onChangeMunicipalityTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Material, e não Container: o splash do InkWell é pintado pelo Material
    // ancestral mais próximo, que sem isto seria o do Scaffold — atrás deste
    // painel opaco. Ou seja, nenhum item do menu teria retorno ao toque.
    // animationDuration zero para a cor não fazer lerp na troca de tema
    // enquanto o resto do app, que usa AppColors, troca de golpe.
    return Material(
      color: colors.surface,
      animationDuration: Duration.zero,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                // primary: false é obrigatório. Visibility(maintainState) usa
                // Offstage, e RenderOffstage continua fazendo layout do filho:
                // sem isto esta lista se registra no PrimaryScrollController da
                // rota mesmo com o menu fechado, junto com a lista do
                // HomeContent — e dois ScrollPosition no mesmo controller
                // derrubam qualquer ScrollIntent num assert do framework.
                primary: false,
                // Sem padding explícito, BoxScrollView consome o
                // MediaQuery.padding do eixo principal.
                padding: EdgeInsets.zero,
                children: [
                  // Cabeçalho: avatar + nome. UserModel só tem nome e foto,
                  // então não há subtítulo aqui.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colors.primary,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.inputText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colors.inputBorder, height: 1),

                  const _SearchPlaceholder(),

                  _MenuTile(
                    icon: Icons.person_outline,
                    label: 'Conta',
                    colors: colors,
                    onTap: onAccountTap,
                  ),
                  _MenuTile(
                    icon: Icons.accessibility_new,
                    label: 'Acessibilidade',
                    colors: colors,
                    onTap: onAccessibilityTap,
                  ),
                  _MenuTile(
                    icon: Icons.add_circle_outline,
                    label: 'Novo protocolo',
                    colors: colors,
                    onTap: onNewProcessTap,
                  ),
                  _MenuTile(
                    icon: Icons.fact_check_outlined,
                    label: 'Meus protocolos',
                    colors: colors,
                    onTap: onTrackProcessesTap,
                  ),
                  _MenuTile(
                    icon: Icons.support_agent_outlined,
                    label: 'Suporte',
                    colors: colors,
                    onTap: onSupportTap,
                  ),
                  _MenuTile(
                    icon: Icons.notifications_none_outlined,
                    label: 'Avisos',
                    colors: colors,
                    onTap: onNoticesTap,
                  ),
                  // Último da lista: é ação rara, de escopo do app e não do
                  // protocolo. Fica perto do rodapé sem ser pintada de
                  // destrutiva como o "Sair".
                  _MenuTile(
                    icon: Icons.place_outlined,
                    label: 'Trocar município',
                    colors: colors,
                    onTap: onChangeMunicipalityTap,
                  ),
                ],
              ),
            ),

            Divider(color: colors.inputBorder, height: 1),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: 'Sair',
              colors: colors,
              color: colors.statusError,
              onTap: onLogoutTap,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Campo de busca que ainda não busca nada.
///
/// Não é um TextField com `readOnly`: aquele ainda recebe foco, mostra cursor
/// e é anunciado como campo de texto, prometendo o que não entrega. Isto é um
/// botão que se parece com um campo — e diz que está por vir.
class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Semantics(
        button: true,
        label: 'Pesquisar protocolos. Em breve.',
        child: ExcludeSemantics(
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Em breve'),
                duration: Duration(seconds: 1),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                // Tokens espelhados de appInputDecoration (core/widgets/
                // app_input_decoration.dart) — se o visual do input mudar lá,
                // este campo falso precisa acompanhar.
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pesquisar (em breve)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? colors.inputText;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                // 2 linhas: com a fonte no máximo, "Novo protocolo" e
                // "Acessibilidade" ficam no limite da largura do painel. A
                // lista rola, então não há motivo para truncar.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tint,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
