import '../models/register_request.dart';
import '../models/user_model.dart';

abstract class RegisterService {
  /// Cria a conta e devolve o usuário autenticado.
  ///
  /// ATENÇÃO: esta assinatura assume auto-login após o cadastro. Se o backend
  /// exigir confirmação de e-mail (o mais provável num serviço público), o
  /// retorno muda e a tela passa a navegar para "confirme seu e-mail" em vez
  /// de ir direto para a Home.
  Future<UserModel> register(RegisterRequest request);
}
