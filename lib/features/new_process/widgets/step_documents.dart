import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/screen_reader_announcer.dart';
import '../../account/widgets/account_card.dart';

/// Passo 2: documentos exigidos quando a solicitação é feita por terceiro.
class StepDocuments extends StatelessWidget {
  const StepDocuments({super.key});

  static const _requiredDocuments = [
    'Procuração (outorgando poderes específicos para a representação).',
    'Documento oficial com foto do outorgado (RG, CNH ou outro documento '
        'válido).',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final body = TextStyle(
      color: colors.textSecondary,
      fontSize: 13,
      height: 1.45,
    );

    return AccountCard(
      icon: Icons.attach_file,
      title: 'Documentos',
      description:
          'Para solicitações em que você não for o titular, requerente ou '
          'responsável pelo processo, é obrigatória a apresentação dos '
          'seguintes documentos:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final document in _requiredDocuments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Semantics(
                label: document,
                child: ExcludeSemantics(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // O glifo é decorativo — sem ExcludeSemantics o leitor
                      // de tela fala "marcador" antes de cada item.
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Text('•', style: body),
                      ),
                      Expanded(child: Text(document, style: body)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 6),

          Text(
            'A documentação é indispensável para garantir a segurança das '
            'informações e dar andamento ao atendimento.',
            style: body,
          ),
          const SizedBox(height: 20),

          const _UploadDropZone(),
        ],
      ),
    );
  }
}

/// Área de seleção de arquivos — desenhada, mas ainda sem seletor.
class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone();

  void _showComingSoon(BuildContext context) {
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Cores explícitas: o SnackBar puxa do ThemeData, que não muda quando
        // o alto contraste liga.
        backgroundColor: colors.surface,
        content: Text(
          'Envio de arquivos em breve',
          style: TextStyle(color: colors.inputText),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    // O SnackBar sozinho não é anunciado de forma confiável.
    announceToScreenReader(context, 'Envio de arquivos em breve.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: 'Escolher arquivos',
      hint: 'Disponível em breve',
      child: ExcludeSemantics(
        // O AccountCard é um Container opaco, então o Material ancestral mais
        // próximo é o do Scaffold e o splash seria pintado atrás dele — a
        // área ficaria sem nenhum retorno ao toque.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _showComingSoon(context),
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: _DashedBorderPainter(color: colors.inputBorder),
              child: Container(
                // Sem altura fixa: com a fonte no máximo o texto do rodapé
                // quebra em duas linhas.
                constraints: const BoxConstraints(minHeight: 88),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Toque para escolher arquivos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PDF, DOC, JPG ou PNG (até 10 MB cada)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Borda tracejada desenhada à mão — o projeto não leva dependência para isso.
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  static const _radius = 12.0;
  static const _dash = 6.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      // 2dp e não 1: tracejado de 1dp praticamente some no alto contraste.
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Derivado do size, nunca fixo: o card muda de altura com a escala de fonte.
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dash),
          paint,
        );
        distance += _dash + _gap;
      }
    }
  }

  // Comparar a cor é obrigatório: ela muda com o tema e com o alto contraste.
  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
