import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_input_decoration.dart';

/// Dropdown com rótulo acima, no mesmo visual do [LabeledTextField].
///
/// Passar `onChanged: null` desabilita o campo (padrão do Material).
class LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isLoading;
  final String? errorText;
  final IconData? prefixIcon;

  /// Como o valor selecionado é exibido com o menu fechado. Útil quando o
  /// texto da lista é longo demais para a largura do campo.
  final List<Widget> Function(BuildContext)? selectedItemBuilder;

  /// Explicação do campo, exibida ao tocar no rótulo.
  final String? helpMessage;

  const LabeledDropdown({
    super.key,
    required this.label,
    this.isRequired = false,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.errorText,
    this.prefixIcon,
    this.selectedItemBuilder,
    this.helpMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enabled = onChanged != null && !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: label,
          isRequired: isRequired,
          helpMessage: helpMessage,
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            // Sem isto, nomes longos ("São José do Rio Preto") estouram o
            // dropdown de meia largura.
            isExpanded: true,
            // O default é 48dp FIXO, e cada item vai num SizedBox dessa
            // altura: um nome que quebre em duas linhas com a fonte grande
            // estoura. Nulo faz o item se dimensionar pelo conteúdo.
            itemHeight: null,
            items: items,
            onChanged: enabled ? onChanged : null,
            selectedItemBuilder: selectedItemBuilder,
            hint: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textMuted, fontSize: 14),
            ),
            style: TextStyle(color: colors.inputText, fontSize: 14),
            dropdownColor: colors.surface,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : Icon(Icons.keyboard_arrow_down, color: colors.textMuted),
            decoration: appInputDecoration(
              colors,
              errorText: errorText,
              prefixIcon: prefixIcon,
              enabled: enabled,
            ),
          ),
        ),
      ],
    );
  }
}
