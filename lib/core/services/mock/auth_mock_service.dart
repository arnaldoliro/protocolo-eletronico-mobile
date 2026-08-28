import '../../models/user_model.dart';
import '../auth_service.dart';

// TODO: remover ao integrar o backend real
class AuthMockService implements AuthService {
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@email.com' && password == '123456') {
      return const UserModel(name: 'João Silva');
    }

    throw Exception('Credenciais inválidas');
  }
}
