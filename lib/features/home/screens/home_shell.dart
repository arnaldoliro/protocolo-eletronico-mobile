import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_panel.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/menu_panel.dart';
import '../widgets/notices_panel.dart';
import 'account_screen.dart';
import 'new_process_screen.dart';

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

  /// Construído uma única vez: é o que garante que o conteúdo permaneça
  /// montado (scroll preservado) durante todo o deslizamento.
  late final Widget _content = HomeContent(user: widget.user);

  double _panelWidth = 0;
  bool _panelOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- estado

  /// `canPop` é lido no build, então precisa de setState — mas só quando
  /// cruza o zero, nunca a cada frame da animação.
  void _syncPanelOpenFlag() {
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
          _fullTravel.inMilliseconds.toDouble(),
        )
        .round();

    _controller
        .animateTo(
          target,
          duration: Duration(milliseconds: ms),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(_syncPanelOpenFlag);
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
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
  }

  Future<void> _logout() async {
    final colors = AppColors.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Sair', style: TextStyle(color: colors.statusError)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // TODO(auth): quando existir sessão/token, invalidar no backend e
    // limpar o storage local ANTES de navegar. Hoje AuthService só expõe
    // login(), então isto é apenas navegação — não é logout de verdade.
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

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
                      user: widget.user,
                      onAccountTap: _openAccount,
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
        final t = _controller.value.abs();
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewProcessScreen()),
        ),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: 'Abrir novo protocolo',
        child: const Icon(Icons.add, size: 28),
      ),
      builder: (context, child) {
        final v = (1.0 - _controller.value.abs()).clamp(0.0, 1.0);
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
