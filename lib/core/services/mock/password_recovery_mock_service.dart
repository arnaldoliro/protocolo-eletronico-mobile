import '../password_recovery_service.dart';

// TODO: remover ao integrar o backend real
//
// Este mock sempre sucede, de propósito: é o comportamento correto do endpoint
// real, que não pode distinguir e-mail cadastrado de não cadastrado.
class PasswordRecoveryMockService implements PasswordRecoveryService {
  @override
  Future<void> requestReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    // Gatilho para exercitar o caminho de erro. Simula falha de REDE, não
    // "e-mail inexistente" — em produção não existe nenhum ramo condicional
    // sobre o e-mail neste método, e introduzir um seria criar enumeração.
    if (email.trim().endsWith('@falha.test')) {
      throw Exception('Falha de rede simulada');
    }
  }
}
