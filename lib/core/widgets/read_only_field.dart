import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_input_decoration.dart';

/// Dado que o usuário vê mas não edita, com aparência de campo.
///
/// Não é um [TextField] com `enabled: false`, por dois motivos concretos:
/// o TextField envolve a decoração inteira — sufixo incluído — num
/// `IgnorePointer(ignoring: !enabled)`, então um botão de ação ali dentro
/// nunca receberia toque; e o leitor de tela anuncia "caixa de edição
/// desativada" e, em várias configurações, **pula** controles desabilitados
/// na navegação por swipe — o usuário poderia nunca ouvir o próprio CPF.
///
/// Mesmo raciocínio do `_SearchPlaceholder` em `features/home/widgets/
/// menu_panel.dart`: não fingir ser um campo aquilo que não é um campo.
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? prefixIcon;
  final String? helperText;

  /// Ação à direita, dentro do campo (ex.: revelar o CPF). Diferente de um
  /// TextField desabilitado, aqui ela funciona de verdade.
  final Widget? action;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.prefixIcon,
    this.helperText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: label),
          const SizedBox(height: 6),
          Semantics(
            label: label,
            value: value,
            readOnly: true,
            child: Container(
              // Tokens espelhados de appInputDecoration, com fillColor no
              // estado desabilitado — o campo precisa parecer não editável.
              padding: EdgeInsets.only(
                left: 14,
                right: action == null ? 14 : 4,
                top: action == null ? 16 : 4,
                bottom: action == null ? 16 : 4,
              ),
              constraints: const BoxConstraints(minHeight: 52),
              decoration: BoxDecoration(
                color: colors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: colors.textMuted, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                helperText!,
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
