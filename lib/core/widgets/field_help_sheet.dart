import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Explica um campo do formulário numa folha inferior.
///
/// Não é [Tooltip]: aquele puxa cor do [ThemeData], que nunca muda quando o
/// alto contraste liga (mesma armadilha já documentada em `confirm_dialog`),
/// exige toque longo e some sozinho por temporizador — ruim para quem lê
/// devagar. A folha toma o foco, o leitor de tela anuncia, e o texto rola.
Future<void> showFieldHelpSheet(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final colors = AppColors.of(context);

  return showModalBottomSheet<void>(
    context: context,
    // Sem isto a folha trava em 9/16 da tela e corta o texto com a fonte
    // no máximo.
    isScrollControlled: true,
    useSafeArea: true,
    // Cores e formato explícitos: o default vem do BottomSheetThemeData.
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: colors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.inputBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Entendi'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
