import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Decoração compartilhada entre [LabeledTextField] e [LabeledDropdown], para
/// campo e dropdown nunca divergirem visualmente.
InputDecoration appInputDecoration(
  AppColors colors, {
  String? hint,
  String? helperText,
  String? errorText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool enabled = true,
}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: BorderRadius.circular(12),
  );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
    // helper e error ocupam o mesmo espaço: o Material troca um pelo outro
    // sem "pulo" de altura quando o erro aparece.
    helperText: helperText,
    helperStyle: TextStyle(color: colors.textMuted, fontSize: 11),
    errorText: errorText,
    // Sem estilo explícito, o vermelho viria do ColorScheme.error e ficaria
    // errado nas paletas de alto contraste.
    errorStyle: TextStyle(color: colors.statusError, fontSize: 11),
    filled: true,
    fillColor: enabled ? colors.inputFill : colors.inputFill.withValues(alpha: 0.5),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: colors.textMuted, size: 20)
        : null,
    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    suffixIcon: suffixIcon,
    border: border(colors.inputBorder),
    enabledBorder: border(colors.inputBorder),
    focusedBorder: border(colors.primary),
    disabledBorder: border(colors.inputBorder),
    errorBorder: border(colors.statusError),
    focusedErrorBorder: border(colors.statusError),
  );
}

/// Rótulo acima do campo, com asterisco quando obrigatório.
///
/// Fica em [ExcludeSemantics] porque o leitor de tela recebe o rótulo pelo
/// [Semantics] que envolve o próprio input — anunciar duas vezes atrapalha.
class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FieldLabel({super.key, required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ExcludeSemantics(
      child: Text.rich(
        TextSpan(
          text: label,
          style: TextStyle(
            color: colors.inputText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: colors.statusError),
              ),
          ],
        ),
      ),
    );
  }
}
