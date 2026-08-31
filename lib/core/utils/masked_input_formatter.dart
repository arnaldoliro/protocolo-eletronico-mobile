import 'package:flutter/services.dart';

/// Máscaras de dígitos usadas nos formulários.
/// Em cada padrão, `#` representa um dígito e qualquer outro caractere é um
/// separador literal.
class InputMasks {
  const InputMasks._();

  static const cpf = '###.###.###-##';
  static const cnpj = '##.###.###/####-##';
  static const phone = '(##) #####-####';
  static const cep = '#####-###';
}

/// Aplica [mask] a uma string que já contém só dígitos, para EXIBIR um valor
/// vindo do backend.
///
/// Existe porque `inputFormatters` não roda quando se atribui
/// `controller.text` — eles só interceptam digitação. Não usa
/// [MaskedInputFormatter.formatEditUpdate] de propósito: aquele carrega o
/// cálculo de cursor, que é a parte sutil deste arquivo e não deve ser
/// exercitada por um caminho que não tem cursor nenhum.
///
/// Devolve [digits] intacto quando a contagem não bate com a capacidade da
/// máscara. Sem isso, um telefone fixo (10 dígitos) ou com DDI (13) seria
/// truncado silenciosamente e o usuário salvaria o lixo de volta.
///
/// Mantenha em sincronia com [MaskedInputFormatter.formatEditUpdate]: as duas
/// precisam produzir o mesmo resultado para a mesma entrada.
String formatWithMask(String mask, String digits) {
  final capacity = '#'.allMatches(mask).length;
  if (digits.length != capacity) return digits;

  final buffer = StringBuffer();
  var index = 0;
  for (final char in mask.split('')) {
    if (char == '#') {
      buffer.write(digits[index]);
      index++;
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Remove tudo que não for dígito. Use antes de enviar o valor ao backend —
/// ele não deve precisar desparsear "(11) 98888-7777".
String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Aplica uma máscara de dígitos enquanto o usuário digita.
///
/// Estratégia: nunca editar o texto formatado no lugar. A cada mudança o
/// valor é reduzido a dígitos, a máscara é reconstruída do zero e o cursor é
/// recalculado pela contagem de dígitos à sua esquerda. É o que evita o
/// cursor pular para o fim ao editar no meio do texto.
class MaskedInputFormatter extends TextInputFormatter {
  final String mask;

  const MaskedInputFormatter(this.mask);

  /// Quantos dígitos a máscara comporta.
  int get digitCapacity => '#'.allMatches(mask).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = onlyDigits(newValue.text);
    final oldDigits = onlyDigits(oldValue.text);
    final deleting = newValue.text.length < oldValue.text.length;

    final cursorRaw = newValue.selection.end.clamp(0, newValue.text.length);
    var digitsBeforeCursor = onlyDigits(
      newValue.text.substring(0, cursorRaw),
    ).length;

    // Backspace sobre um separador não muda os dígitos, então o texto seria
    // reconstruído idêntico e a tecla pareceria travada. Removemos o dígito
    // imediatamente anterior no lugar.
    if (deleting && digits.length == oldDigits.length && digitsBeforeCursor > 0) {
      digits = digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    // Colagem maior que a máscara.
    if (digits.length > digitCapacity) {
      digits = digits.substring(0, digitCapacity);
    }
    if (digitsBeforeCursor > digits.length) digitsBeforeCursor = digits.length;

    final buffer = StringBuffer();
    var consumed = 0;
    var cursorOffset = 0;

    for (final char in mask.split('')) {
      if (consumed >= digits.length) break;
      if (char == '#') {
        buffer.write(digits[consumed]);
        consumed++;
        if (consumed == digitsBeforeCursor) cursorOffset = buffer.length;
      } else {
        buffer.write(char);
      }
    }

    final text = buffer.toString();
    if (digitsBeforeCursor == 0) cursorOffset = 0;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, text.length),
      ),
      // Sem isto, alguns IMEs Android com predição deixam texto sublinhado
      // ou duplicado.
      composing: TextRange.empty,
    );
  }
}
