import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Painel lateral direito, revelado ao deslizar o conteúdo para a esquerda.
///
// TODO(avisos): a fonte de dados de avisos ainda não foi definida. Ao
// integrar, criar um NoticeModel em core/models e consumi-lo por um
// service — nenhuma regra de negócio deve viver neste widget.
class NoticesPanel extends StatelessWidget {
  const NoticesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Avisos',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Divider(color: colors.inputBorder, height: 1),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: colors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum aviso',
                        style: TextStyle(
                          color: colors.inputText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quando houver novidades sobre seus protocolos, '
                        'elas aparecerão aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
