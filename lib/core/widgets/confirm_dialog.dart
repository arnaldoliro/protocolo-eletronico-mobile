import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Diálogo de confirmação com as cores vindas de [AppColors].
///
/// O [AlertDialog] sem estilo explícito puxa cor do `ThemeData`, que **nunca**
/// muda quando o alto contraste liga — só o [AppColors] muda. Sem isto o
/// diálogo fica ilegível nas paletas de alto contraste.
///
/// Devolve `true` só quando o usuário confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  bool isDestructive = false,
}) async {
  final colors = AppColors.of(context);
  final confirmColor = isDestructive ? colors.statusError : colors.primary;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(title, style: TextStyle(color: colors.inputText)),
      content: Text(message, style: TextStyle(color: colors.textSecondary)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(foregroundColor: colors.textMuted),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
