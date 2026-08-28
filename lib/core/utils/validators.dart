import 'masked_input_formatter.dart';

/// Validações de formulário — TODAS são apenas UX (feedback rápido, evitar
/// requisições inúteis). NENHUMA é proteção real: o app pode ser desmontado e
/// o tráfego forjado.
///
/// O backend é a autoridade e precisa revalidar todos os campos: dígito
/// verificador e unicidade de CPF, formato/unicidade/posse do e-mail, DDD
/// válido, política de senha e hashing.
///
/// Cada função devolve `null` quando o valor passa, ou a mensagem de erro.
class Validators {
  const Validators._();

  static final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  static String? required(String value, {String message = 'Campo obrigatório'}) {
    return value.trim().isEmpty ? message : null;
  }

  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Informe um e-mail válido';
    return _emailPattern.hasMatch(trimmed) ? null : 'Informe um e-mail válido';
  }

  /// Confere a quantidade de dígitos, ignorando a máscara.
  static String? digitsLength(String value, int length, String message) {
    if (value.trim().isEmpty) return 'Campo obrigatório';
    return onlyDigits(value).length == length ? null : message;
  }

  static String? minLength(String value, int min, String message) {
    if (value.isEmpty) return 'Campo obrigatório';
    return value.length >= min ? null : message;
  }

  static String? passwordMatch(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Confirme a senha';
    return password == confirmation ? null : 'As senhas não coincidem';
  }
}
