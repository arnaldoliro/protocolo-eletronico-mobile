import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Três pontinhos enquanto o assistente prepara a resposta.
///
/// Fica FORA da lista de mensagens de propósito: dentro, viraria
/// `itemCount: n + (isTyping ? 1 : 0)` com índice invertido — o lugar clássico
/// de erro de deslocamento, e ainda embaralharia as chaves dos itens. Aqui
/// embaixo da lista invertida ele cai visualmente no lugar certo, e a última
/// mensagem sobe sozinha quando ele aparece.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Com "reduzir movimento" ligado no sistema, os pontos ficam estáticos.
    // Além da diretriz de acessibilidade, uma animação infinita nesse caso é
    // quadro contínuo e bateria à toa.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      liveRegion: true,
      label: 'Assistente está digitando',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: colors.cardShadow,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 5),
                        _Dot(color: colors.textMuted, opacity: _opacityFor(i)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opacidade, não deslocamento vertical: mover os pontos desalinharia a
  /// linha de base com a fonte grande.
  double _opacityFor(int index) {
    if (!_controller.isAnimating) return 0.6;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.2, index * 0.2 + 0.6, curve: Curves.easeInOut),
    );
    return 0.35 + (1 - (curve.value - 0.5).abs() * 2) * 0.65;
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double opacity;

  const _Dot({required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
      ),
    );
  }
}
