import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Aceite dos termos de uso e política de privacidade.
///
// TODO(termos): hoje o usuário aceita documentos que não consegue ler no app.
// Antes de produção, os termos precisam estar acessíveis (tela própria ou
// link externo) — é requisito de conformidade, não polimento.
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: value,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: value,
                      onChanged: (v) => onChanged(v ?? false),
                      activeColor: colors.primary,
                      checkColor: Colors.white,
                      // A borda usa a cor do texto (clara no tema escuro,
                      // escura no tema claro). Com colors.inputBorder a caixa
                      // desmarcada some contra a superfície no tema escuro.
                      side: BorderSide(color: colors.inputText, width: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aceito os termos de uso e a política de privacidade '
                      'da prefeitura.',
                      style: TextStyle(color: colors.inputText, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(color: colors.statusError, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
