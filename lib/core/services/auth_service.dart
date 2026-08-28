import '../models/user_model.dart';

abstract class AuthService {
  Future<UserModel> login(String email, String password);
}
