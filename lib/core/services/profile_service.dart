import '../models/account_profile.dart';
import '../models/update_profile_request.dart';

/// A senha atual informada não confere.
///
/// Diferente do [PasswordRecoveryService], aqui um erro tipado é seguro: o
/// usuário já está autenticado, e "senha atual incorreta" é informação sobre
/// ele mesmo — não há enumeração de contas a proteger. Não "corrija" isto
/// para uma mensagem genérica.
class WrongPasswordException implements Exception {
  const WrongPasswordException();
}

/// A senha nova foi recusada pela política do servidor.
///
/// A [message] vem do backend e é exibida no campo "Nova senha". O app
/// deliberadamente NÃO valida classes de caractere: a política é regra de
/// negócio, e replicá-la aqui faria o app bloquear senhas válidas até um novo
/// release sempre que o servidor mudasse a regra.
class PasswordPolicyException implements Exception {
  final String message;
  const PasswordPolicyException(this.message);
}

/// Perfil do usuário autenticado.
///
/// SEGURANÇA — todos os métodos operam sobre a sessão em curso:
///  - a identidade sai do token da requisição, NUNCA de um parâmetro. Não
///    adicionar `userId` a nenhum destes métodos "por conveniência": seria
///    IDOR direto — qualquer um trocaria o id e leria o perfil alheio.
///  - [revealCpf] devolve dado pessoal sob demanda. O backend precisa de
///    sessão válida, rate limit e **log de auditoria de cada acesso**
///    (LGPD art. 37, registro das operações de tratamento).
///  - [changePassword] deve invalidar as sessões dos demais dispositivos e
///    rotacionar o token deste. É trabalho do servidor, não do app.
abstract class ProfileService {
  Future<AccountProfile> load();

  /// Devolve o perfil já normalizado pelo backend (trim, capitalização), para
  /// a tela repopular os campos com o que foi realmente gravado.
  Future<AccountProfile> update(UpdateProfileRequest request);

  /// CPF completo, apenas dígitos. O valor nunca deve ser persistido nem
  /// guardado no [AccountProfile] — só no State da tela, morrendo com ela.
  Future<String> revealCpf();

  /// Lança [WrongPasswordException] ou [PasswordPolicyException].
  Future<void> changePassword(String currentPassword, String newPassword);
}
