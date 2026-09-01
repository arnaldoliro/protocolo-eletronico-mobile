import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Indicador de progresso do assistente: círculos numerados, conectores e um
/// rótulo único abaixo ("Passo 1 de 3 · Solicitação").
///
/// Indicador puro, não navega — quem muda de passo são os botões Continuar e
/// Voltar.
///
/// Os três rótulos lado a lado do mockup web não cabem em 320dp: "SOLICITAÇÃO"
/// a 11px com a fonte no máximo já passa de 105dp, e cada coluna tem ~90dp.
/// Um rótulo só resolve, e ainda absorve o "Passo 1 de 3" que no AppBar
/// estouraria o toolbarHeight.
class WizardStepper extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const WizardStepper({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final total = labels.length;
    final upcoming = labels.skip(currentStep + 1).join(', ');

    return Semantics(
      container: true,
      // Um nó só para a trilha inteira: um por círculo seria ruído. E em caixa
      // normal — leitor de tela costuma soletrar texto todo-maiúsculo.
      label:
          'Passo ${currentStep + 1} de $total: ${labels[currentStep]}.'
          '${upcoming.isEmpty ? '' : ' Próximos: $upcoming.'}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < total; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        // O conector de índice i vem antes do círculo i, então
                        // se está preenchido o círculo anterior foi concluído.
                        color: i <= currentStep
                            ? colors.statusSuccess
                            : colors.inputBorder,
                      ),
                    ),
                  _StepCircle(
                    number: i + 1,
                    done: i < currentStep,
                    active: i == currentStep,
                    colors: colors,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Passo ${currentStep + 1} de $total · ${labels[currentStep]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inputText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool done;
  final bool active;
  final AppColors colors;

  const _StepCircle({
    required this.number,
    required this.done,
    required this.active,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Concluído é verde, ativo é azul, pendente é vazado.
    final fill = done
        ? colors.statusSuccess
        : active
        ? colors.primary
        : colors.inputFill;
    final filled = done || active;
    // Branco fixo reprova o contraste em alto contraste escuro, onde tanto o
    // primary quanto o statusSuccess são cores claras.
    final foreground = filled ? onBrandColor(fill) : colors.textMuted;

    // Acompanha a escala de fonte em vez de fixar 28dp: travar o tamanho com
    // TextScaler.noScaling faria o número vazar do círculo.
    final size = MediaQuery.textScalerOf(context).scale(28);

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(
            color: filled ? fill : colors.inputBorder,
            width: 2,
          ),
        ),
        child: Center(
          child: done
              ? Icon(Icons.check, size: size * 0.5, color: foreground)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
