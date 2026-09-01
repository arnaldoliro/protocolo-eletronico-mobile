import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/models/process_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/logout_action.dart';
import '../../account/screens/account_screen.dart';
import '../../new_process/screens/new_process_screen.dart';
import '../models/home_panel.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/menu_panel.dart';
import '../widgets/notices_panel.dart';
import 'accessibility_screen.dart';
import 'support_screen.dart';

/// Casca da Home: mantém o conteúdo principal sempre montado e revela
/// painéis laterais deslizando-o horizontalmente, sem abrir novas rotas.
///
/// A posição é um único escalar contínuo no [AnimationController]:
/// `0` = centro, `+1` = menu aberto (conteúdo à direita), `-1` = avisos
/// aberto (conteúdo à esquerda). Um só valor cobre todo o espaço de
/// estados, então arrastar de um painel ao outro atravessando o centro
/// funciona sem lógica extra.
class HomeShell extends StatefulWidget {
  final UserModel user;

  const HomeShell({super.key, required this.user});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  static const _fullTravel = Duration(milliseconds: 280);
  static const _minDuration = Duration(milliseconds: 120);
  // Teto maior que _fullTravel só para a travessia de painel a painel
  // (distância 2.0). Nenhum gesto alcança distância > 1.0 — _onDragEnd sempre
  // mira a parada mais próxima na direção do dedo —, então isto não altera o
  // comportamento de arrasto nenhum.
  static const _maxDuration = Duration(milliseconds: 420);
  static const _minFlingVelocity = 400.0; // px/s
  static const _panelFraction = 0.80;
  static const _maxPanelWidth = 340.0;
  static const _maxScrimOpacity = 0.35;

  // value: 0.0 é obrigatório — o controller inicia em lowerBound por
  // padrão, o que abriria o app com o painel de avisos escancarado.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 0.0,
    lowerBound: -1.0,
    upperBound: 1.0,
    duration: _fullTravel,
  );

  /// O usuário pode ser editado na tela de conta, então não dá para ler
  /// `widget.user` direto.
  late UserModel _user = widget.user;

  /// Protocolos em andamento. Estava como `static final` dentro do
  /// HomeContent — estado estático sobrevive ao logout e, quando o login for
  /// de verdade, mostraria os dados do usuário anterior para o próximo.
  // TODO: dado mockado — substituir pela listagem real do backend.
  late List<ProcessModel> _processes = [
    ProcessModel(
      id: '001',
      type: 'Declaração de Tempo de Serviço',
      status: ProcessStatus.emTramitacao,
      date: DateTime.now().subtract(const Duration(days: 2)),
      protocolNumber: '000123/2026',
      requesterMaskedCpf: '123.***.***-00',
    ),
  ];

  /// Instância memoizada para a subárvore não reconstruir a cada setState do
  /// shell. Trocada deliberadamente quando o usuário ou a lista mudam —
  /// reconstruir HomeContent NÃO perde o scroll: quem preserva o
  /// ScrollPosition é o Element do Scrollable permanecer na mesma posição da
  /// árvore.
  late Widget _content = _buildHomeContent();

  /// Um ponto só de construção. Com dois call sites montando o widget na mão,
  /// esquecer um parâmetro daria bug silencioso: a subárvore memoizada
  /// seguiria com a lista velha sem nada avisar.
  Widget _buildHomeContent() => HomeContent(
    user: _user,
    processes: _processes,
    onNewProcessTap: _openNewProcess,
  );

  double _panelWidth = 0;
  bool _panelOpen = false;

  /// Verdadeiro durante uma travessia direta de um painel ao outro. Sem isto o
  /// FAB e o scrim, cuja opacidade depende de `1 - |t|`, atravessam o zero e
  /// piscam por inteiro no meio do caminho.
  bool _crossing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- estado

  /// `canPop` é lido no build, então precisa de setState — mas só quando
  /// cruza o zero, nunca a cada frame da animação.
  void _syncPanelOpenFlag() {
    // whenComplete dispara também quando a animação é cancelada — inclusive
    // pelo dispose do controller.
    if (!mounted) return;
    final open = _controller.value.abs() > 0.001;
    if (open != _panelOpen) setState(() => _panelOpen = open);
  }

  HomePanel _activePanel(double t) {
    if (t > 0.5) return HomePanel.menu;
    if (t < -0.5) return HomePanel.notices;
    return HomePanel.home;
  }

  /// Sempre animateTo: forward/reverse iriam para os extremos e nunca
  /// parariam no centro. A curva vai aqui, não num CurvedAnimation —
  /// Curve.transform tem assert(t >= 0) e quebra com valores negativos.
  void _animateTo(double target) {
    final distance = (target - _controller.value).abs();
    if (distance < 0.0001) {
      _controller.value = target;
      _syncPanelOpenFlag();
      return;
    }

    // Duração proporcional à distância: fechar os últimos 5% não deve
    // levar o mesmo tempo que o percurso completo.
    final ms = (_fullTravel.inMilliseconds * distance)
        .clamp(
          _minDuration.inMilliseconds.toDouble(),
          _maxDuration.inMilliseconds.toDouble(),
        )
        .round();

    // Distância > 1 só acontece indo de um painel direto ao outro.
    final crossing = distance > 1.0;
    if (crossing) setState(() => _crossing = true);

    _controller
        .animateTo(
          target,
          duration: Duration(milliseconds: ms),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (crossing && mounted) setState(() => _crossing = false);
          _syncPanelOpenFlag();
        });
    _syncPanelOpenFlag();
  }

  void _onNavSelect(HomePanel panel) {
    switch (panel) {
      case HomePanel.menu:
        _animateTo(1.0);
      case HomePanel.home:
        _animateTo(0.0);
      case HomePanel.notices:
        _animateTo(-1.0);
    }
  }

  // ---------------------------------------------------------------- gestos

  void _onDragStart(DragStartDetails _) => _controller.stop();

  void _onDragUpdate(DragUpdateDetails details) {
    if (_panelWidth <= 0) return;
    _controller.value =
        (_controller.value + details.primaryDelta! / _panelWidth)
            .clamp(-1.0, 1.0);
    _syncPanelOpenFlag();
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final t = _controller.value;
    final double target;

    if (velocity.abs() >= _minFlingVelocity) {
      // Fling: a direção do dedo manda, independente de onde ele parou.
      if (velocity > 0) {
        target = t >= 0 ? 1.0 : 0.0; // direita: abre menu ou fecha avisos
      } else {
        target = t <= 0 ? -1.0 : 0.0; // esquerda: abre avisos ou fecha menu
      }
    } else {
      // Sem fling: decide por distância percorrida.
      target = t.abs() < 0.5 ? 0.0 : (t > 0 ? 1.0 : -1.0);
    }

    _animateTo(target);
  }

  // ------------------------------------------------------------ navegação

  Future<void> _openAccount() async {
    // Fecha antes de navegar: senão, ao voltar, o usuário reencontra o
    // painel aberto numa tela que já não estava olhando.
    _animateTo(0.0);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountScreen(
          user: _user,
          onUserUpdated: _onUserUpdated,
        ),
      ),
    );
  }

  void _onUserUpdated(UserModel user) {
    setState(() {
      _user = user;
      // Nova instância: a subárvore reconstrói com o nome novo e o scroll
      // permanece, porque o Element do Scrollable não sai do lugar.
      _content = _buildHomeContent();
    });
  }

  void _onProcessCreated(ProcessModel process) {
    setState(() {
      _processes = [process, ..._processes];
      _content = _buildHomeContent();
    });
  }

  Future<void> _openAccessibility() async {
    _animateTo(0.0);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccessibilityScreen()),
    );
  }

  Future<void> _openSupport() async {
    _animateTo(0.0);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportScreen()),
    );
  }

  /// Único caminho para o assistente — FAB, item do menu e card da Home. É
  /// aqui que o protocolo recém-criado entra na lista.
  Future<void> _openNewProcess() async {
    _animateTo(0.0);
    final created = await Navigator.of(context).push<ProcessModel>(
      MaterialPageRoute(builder: (_) => const NewProcessScreen()),
    );
    if (created != null && mounted) _onProcessCreated(created);
  }

  /// Delegado a confirmAndLogout: a tela de conta tem o mesmo botão, e o
  /// TODO(auth) sobre invalidar sessão precisa viver num lugar só.
  Future<void> _logout() => confirmAndLogout(context);

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: !_panelOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _animateTo(0.0);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => BottomNavBar(
            active: _activePanel(_controller.value),
            onSelect: _onNavSelect,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _buildFab(colors),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _panelWidth = math.min(
                constraints.maxWidth * _panelFraction,
                _maxPanelWidth,
              );

              return Stack(
                children: [
                  _buildPanel(
                    isLeft: true,
                    child: MenuPanel(
                      user: _user,
                      onAccountTap: _openAccount,
                      onAccessibilityTap: _openAccessibility,
                      onNewProcessTap: _openNewProcess,
                      onSupportTap: _openSupport,
                      // Reusa o painel que já existe, em vez de duplicar a
                      // lista de avisos numa rota nova.
                      onNoticesTap: () => _onNavSelect(HomePanel.notices),
                      onLogoutTap: _logout,
                    ),
                  ),
                  _buildPanel(isLeft: false, child: const NoticesPanel()),

                  // O conteúdo vai por último para pintar por cima dos
                  // painéis. Só o Transform reconstrói por frame — o child
                  // é memoizado, então a árvore permanece montada.
                  AnimatedBuilder(
                    animation: _controller,
                    child: _buildTranslatedContent(colors),
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_controller.value * _panelWidth, 0),
                      child: child,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// O conteúdo precisa de fundo opaco próprio — o do Scaffold fica atrás
  /// dos painéis, então sem isto o painel apareceria através dele.
  Widget _buildTranslatedContent(AppColors colors) {
    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          ExcludeSemantics(excluding: _panelOpen, child: _content),
          _buildScrim(),
        ],
      ),
    );
  }

  /// Escurece o conteúdo, fecha o painel ao toque e bloqueia os InkWell
  /// de trás — três problemas resolvidos por uma camada só.
  Widget _buildScrim() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Na travessia o scrim fica no máximo em vez de sumir e voltar.
        final t = _crossing ? 1.0 : _controller.value.abs();
        if (t == 0) return const SizedBox.shrink();

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _animateTo(0.0),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: _maxScrimOpacity * t),
            ),
          ),
        );
      },
    );
  }

  /// Painéis ficam sempre construídos (evita jank no primeiro toque), mas
  /// só o painel do lado ativo é pintado.
  ///
  /// Cada painel ocupa [_panelFraction] da largura, então os dois se
  /// sobrepõem no meio da tela. Sem esconder o inativo, o painel da
  /// direita (mais acima na Stack, e opaco) pintaria por cima do da
  /// esquerda — Menu e Avisos apareceriam juntos.
  ///
  /// [Visibility] com `maintainState` preserva o estado da subárvore sem
  /// pintar nem receber toques; `IgnorePointer`/`ExcludeSemantics`
  /// sozinhos não bastam, pois não impedem a pintura.
  Widget _buildPanel({required bool isLeft, required Widget child}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: _panelWidth,
      child: AnimatedBuilder(
        animation: _controller,
        child: child,
        builder: (context, child) {
          final t = _controller.value;
          final visible = isLeft ? t > 0.001 : t < -0.001;
          return Visibility(
            visible: visible,
            maintainState: true,
            child: child!,
          );
        },
      ),
    );
  }

  Widget _buildFab(AppColors colors) {
    return AnimatedBuilder(
      animation: _controller,
      child: FloatingActionButton(
        onPressed: _openNewProcess,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: 'Abrir novo protocolo',
        child: const Icon(Icons.add, size: 28),
      ),
      builder: (context, child) {
        final v = _crossing
            ? 0.0
            : (1.0 - _controller.value.abs()).clamp(0.0, 1.0);
        if (v == 0) return const SizedBox.shrink();

        // IgnorePointer é obrigatório: Opacity(0) continua recebendo toques.
        return IgnorePointer(
          ignoring: v < 0.5,
          child: Opacity(
            opacity: v,
            child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
          ),
        );
      },
    );
  }
}
