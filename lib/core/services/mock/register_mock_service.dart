import '../../models/register_request.dart';
import '../../models/user_model.dart';
import '../register_service.dart';

// TODO: remover ao integrar o backend real
//
// Este mock aceita QUALQUER cadastro. Jamais pode chegar a um build de
// produção: não há verificação de e-mail, unicidade de CPF nem política de
// senha — tudo isso é responsabilidade do backend.
class RegisterMockService implements RegisterService {
  @override
  Future<UserModel> register(RegisterRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // Exercita o caminho de erro geral da tela.
    if (request.email == 'test@email.com') {
      throw Exception('E-mail já cadastrado');
    }

    return UserModel(name: request.fullName);
  }
}
