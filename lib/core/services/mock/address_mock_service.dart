import '../../models/address_model.dart';
import '../address_service.dart';

// TODO: remover ao integrar o backend real
//
// A lista real de municípios (~5.570) NÃO deve ser embutida no app: incharia
// o bundle e viraria dado desatualizado versionado no cliente. Este mock traz
// só amostra suficiente para exercitar a UI.
class AddressMockService implements AddressService {
  static const _byCep = <String, AddressModel>{
    '01001000': AddressModel(
      cep: '01001000',
      street: 'Praça da Sé',
      neighborhood: 'Sé',
      city: 'São Paulo',
      stateCode: 'SP',
    ),
    '20040020': AddressModel(
      cep: '20040020',
      street: 'Avenida Rio Branco',
      neighborhood: 'Centro',
      city: 'Rio de Janeiro',
      stateCode: 'RJ',
    ),
    '45650000': AddressModel(
      cep: '45650000',
      street: 'Rua Marquês de Paranaguá',
      neighborhood: 'Centro',
      city: 'Ilhéus',
      stateCode: 'BA',
    ),
  };

  static const _citiesByState = <String, List<String>>{
    'SP': ['Campinas', 'Santos', 'São José do Rio Preto', 'São Paulo'],
    'RJ': ['Niterói', 'Petrópolis', 'Rio de Janeiro'],
    'BA': ['Ilhéus', 'Itabuna', 'Salvador', 'Vitória da Conquista'],
    'MG': ['Belo Horizonte', 'Juiz de Fora', 'Uberlândia'],
  };

  @override
  Future<AddressModel> findByCep(String cep) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final address = _byCep[cep];
    if (address == null) throw const CepNotFoundException();
    return address;
  }

  @override
  Future<List<String>> citiesByState(String stateCode) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _citiesByState[stateCode] ?? const ['Capital', 'Interior'];
  }
}
