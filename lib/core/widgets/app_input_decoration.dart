import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'field_help_sheet.dart';

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
  /// Cor do [helperText]. Nulo usa textMuted. Existe para o contador de
  /// caracteres poder ficar âmbar sem virar um Text irmão — helper e error são
  /// mutuamente exclusivos no InputDecorator, então o contador sai de cena
  /// sozinho quando um erro de verdade aparece.
  Color? helperColor,
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
    helperStyle: TextStyle(color: helperColor ?? colors.textMuted, fontSize: 11),
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

  /// Explicação do campo. Quando presente, o rótulo inteiro vira botão e abre
  /// a folha de ajuda.
  final String? helpMessage;

  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.helpMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final text = ExcludeSemantics(
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

    if (helpMessage == null) return text;

    // O rótulo inteiro é o alvo, não um ícone de 16px: um IconButton teria
    // mínimo de 48x48 e, com um por campo, encheria a tela de espaço morto —
    // e encolhê-lo reprovaria a diretriz de alvo de toque.
    return Semantics(
      button: true,
      label: 'Ajuda sobre $label',
      child: InkWell(
        onTap: () => showFieldHelpSheet(
          context,
          title: label,
          message: helpMessage!,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flexible e não Expanded: Expanded jogaria o ícone para a borda
              // direita em rótulos curtos. Sem nenhum dos dois, o rótulo longo
              // com a fonte no máximo estoura a linha.
              Flexible(child: text),
              const SizedBox(width: 6),
              Icon(Icons.help_outline, size: 16, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
