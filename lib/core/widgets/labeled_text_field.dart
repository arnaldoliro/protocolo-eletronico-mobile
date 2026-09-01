import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'app_input_decoration.dart';

/// Campo de formulário com rótulo ACIMA do input, placeholder dentro, ícone
/// de prefixo e texto auxiliar abaixo.
///
/// Diferente do `CustomTextField` (usado no login), que mantém o rótulo
/// dentro do campo. Os dois coexistem de propósito — unificar exigiria um
/// widget com dois modos de layout, fonte fácil de regressão.
class LabeledTextField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;

  /// Nulos de propósito: o widget deriva o valor certo a partir de [maxLines].
  /// Fixá-los faz o Flutter disparar assert em campo multilinha —
  /// `TextInputAction.newline` é proibido enquanto o keyboardType for
  /// `TextInputType.text`.
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Acima de 1 (ou nulo) o campo vira área de texto.
  final int? maxLines;
  final int? minLines;

  /// Explicação do campo, exibida ao tocar no rótulo.
  final String? helpMessage;

  /// Cor do [helperText] — use para contador/aviso que não é erro.
  final Color? helperColor;
  final ValueChanged<String>? onChanged;

  /// Submete pelo botão de ação do teclado. `textInputAction` sozinho apenas
  /// fecha o teclado — em formulário de um campo só, é este callback que faz
  /// o Enter valer alguma coisa.
  final ValueChanged<String>? onSubmitted;

  /// Widget colocado à direita do input (ex.: o botão "Buscar" do CEP).
  /// Fica dentro deste widget, e não como irmão externo, para o alinhamento
  /// vertical acompanhar o rótulo em qualquer escala de fonte.
  final Widget? trailing;

  /// Desliga correção/sugestão do teclado. Use em senha e CPF.
  final bool suggestionsEnabled;

  final Iterable<String>? autofillHints;

  const LabeledTextField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.helpMessage,
    this.helperColor,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
    this.suggestionsEnabled = true,
    this.autofillHints,
  }) : // O widget converte obscureText no estado _obscure, então sem este
       // assert o campo passa com o olho aberto e explode lá dentro no
       // instante em que o usuário toca no olho.
       assert(
         !obscureText || maxLines == 1,
         'Campo de senha não pode ser multilinha.',
       ),
       // O InputDecorator centraliza o prefixIcon na altura TOTAL do campo, e
       // InputDecoration não tem prefixIconAlignment: numa caixa alta o ícone
       // flutuaria no meio.
       assert(
         prefixIcon == null || maxLines == 1,
         'prefixIcon não alinha em campo multilinha — use o rótulo.',
       );

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscure = widget.obscureText;

  bool get _isMultiline => widget.maxLines != 1;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final field = Semantics(
      textField: true,
      label: widget.label,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType:
            widget.keyboardType ??
            (_isMultiline ? TextInputType.multiline : TextInputType.text),
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        textInputAction:
            widget.textInputAction ??
            (_isMultiline ? TextInputAction.newline : TextInputAction.next),
        textCapitalization: widget.textCapitalization,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autocorrect: widget.suggestionsEnabled,
        enableSuggestions: widget.suggestionsEnabled,
        autofillHints: widget.autofillHints,
        style: TextStyle(color: colors.inputText),
        decoration: appInputDecoration(
          colors,
          hint: widget.hint,
          helperText: widget.helperText,
          helperColor: widget.helperColor,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          enabled: widget.enabled,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: colors.textMuted,
                    size: 20,
                  ),
                  tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: widget.label,
          isRequired: widget.isRequired,
          helpMessage: widget.helpMessage,
        ),
        const SizedBox(height: 6),
        if (widget.trailing == null)
          field
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ),
      ],
    );
  }
}
