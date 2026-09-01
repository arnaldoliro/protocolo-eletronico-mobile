import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_input_decoration.dart';

/// Barra de busca da listagem.
///
/// Não usa o `LabeledTextField`: o slot de sufixo dele já está ocupado pelo
/// olho de senha, o `trailing` fica fora da caixa, e o rótulo acima é
/// obrigatório — nenhum dos três serve para uma barra de busca. Consome a
/// mesma `appInputDecoration`, então o visual continua igual ao dos formulários.
class ProcessSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const ProcessSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      textField: true,
      label: 'Buscar protocolos',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        // Sem autofocus: abrir o teclado ao entrar esconderia a lista, que é
        // o conteúdo principal da tela.
        style: TextStyle(color: colors.inputText),
        decoration: appInputDecoration(
          colors,
          hint: 'Buscar por número ou assunto',
          prefixIcon: Icons.search,
          // Só o botão reconstrói quando o texto muda — não a tela inteira.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.close, color: colors.textMuted, size: 20),
                tooltip: 'Limpar busca',
                onPressed: onClear,
              );
            },
          ),
        ),
      ),
    );
  }
}
