import '../../models/account_profile.dart';
import '../../models/update_profile_request.dart';
import '../profile_service.dart';

// TODO: remover ao integrar o backend real
//
// Guarda o perfil em memória para o save parecer real dentro da sessão. Isso
// é deliberadamente NÃO estático: estado estático sobreviveria ao logout e,
// quando o login for de verdade, mostraria os dados do usuário anterior para
// o próximo.
class ProfileMockService implements ProfileService {
  AccountProfile _profile = const AccountProfile(
    name: 'Maria Souza Lima',
    email: 'teste@requerente.local',
    // Já mascarado, como o backend real deve devolver.
    maskedCpf: '529.***.***-25',
    phone: '77999998888',
    // CEP e cidade que existem no AddressMockService, para o botão "Buscar"
    // demonstrar o caminho feliz.
    cep: '01001000',
    street: 'Praça da Sé',
    number: '100',
    complement: null,
    neighborhood: 'Sé',
    stateCode: 'SP',
    city: 'São Paulo',
  );

  @override
  Future<AccountProfile> load() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _profile;
  }

  @override
  Future<AccountProfile> update(UpdateProfileRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simula a normalização que o backend faria.
    _profile = AccountProfile(
      name: request.name.trim(),
      email: _profile.email,
      maskedCpf: _profile.maskedCpf,
      phone: request.phone,
      cep: request.cep,
      street: request.street.trim(),
      number: request.number.trim(),
      complement: request.complement?.trim(),
      neighborhood: request.neighborhood.trim(),
      stateCode: request.stateCode,
      city: request.city,
    );
    return _profile;
  }

  @override
  Future<String> revealCpf() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return '52998224725';
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));

    // A senha do AuthMockService, para o caminho feliz ser reproduzível.
    if (currentPassword != '123456') throw const WrongPasswordException();

    // Exercita o caminho em que a política é do servidor: o app não checa
    // classes de caractere, então é aqui que a recusa aparece.
    if (newPassword.toLowerCase() == newPassword) {
      throw const PasswordPolicyException(
        'A senha precisa ter ao menos uma letra maiúscula.',
      );
    }
  }
}
