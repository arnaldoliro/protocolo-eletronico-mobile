import '../../models/municipality.dart';
import '../municipality_service.dart';

/// Vire para `true` para exercitar o caminho de erro da tela.
///
/// Os outros mocks escondem o gatilho num texto digitado (`falha`); aqui não
/// há campo de entrada nenhum, então a alavanca é esta constante.
const _kSimulateFailure = false;

// TODO: remover ao integrar o backend real
//
// A lista vive no app só porque a rota pública de municípios ainda não existe
// no Laravel. É a mesma crítica que o AddressMockService já faz sobre embutir
// municípios no cliente: enquanto isto estiver aqui, cada prefeitura nova
// exige um release na loja.
class MunicipalityMockService implements MunicipalityService {
  @override
  Future<List<Municipality>> loadAvailable() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (_kSimulateFailure) throw Exception('Falha de rede simulada');

    return const [
      Municipality(id: 'ilheus', name: 'Ilhéus', stateCode: 'BA', subdomain: 'ilheus'),
      Municipality(id: 'itabuna', name: 'Itabuna', stateCode: 'BA', subdomain: 'itabuna'),
      Municipality(id: 'itacare', name: 'Itacaré', stateCode: 'BA', subdomain: 'itacare'),
      Municipality(id: 'una', name: 'Una', stateCode: 'BA', subdomain: 'una'),
      Municipality(id: 'canavieiras', name: 'Canavieiras', stateCode: 'BA', subdomain: 'canavieiras'),
      // Nome longo de propósito: é o caso que estoura a linha do login e o
      // item da lista com a fonte no máximo.
      Municipality(id: 'sjrp', name: 'São José do Rio Preto', stateCode: 'SP', subdomain: 'sjriopreto'),
      Municipality(id: 'santos', name: 'Santos', stateCode: 'SP', subdomain: 'santos'),
      Municipality(id: 'petropolis', name: 'Petrópolis', stateCode: 'RJ', subdomain: 'petropolis'),
      Municipality(id: 'juiz-de-fora', name: 'Juiz de Fora', stateCode: 'MG', subdomain: 'juizdefora'),
      Municipality(id: 'uberlandia', name: 'Uberlândia', stateCode: 'MG', subdomain: 'uberlandia'),
    ];
  }
}
