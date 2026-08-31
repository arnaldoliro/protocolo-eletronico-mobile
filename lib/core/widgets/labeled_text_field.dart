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
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
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
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
    this.suggestionsEnabled = true,
    this.autofillHints,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final field = Semantics(
      textField: true,
      label: widget.label,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        textInputAction: widget.textInputAction,
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
        FieldLabel(label: widget.label, isRequired: widget.isRequired),
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
