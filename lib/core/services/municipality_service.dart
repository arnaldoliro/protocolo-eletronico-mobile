import '../models/municipality.dart';

/// Municípios atendidos pelo sistema.
///
/// É a única chamada do app que acontece **antes** de haver tenant resolvido e
/// **antes** de qualquer login — o usuário ainda vai escolher contra qual
/// servidor falar.
///
/// PENDÊNCIA DO BACKEND: a rota correspondente precisa ser pública e ficar
/// **fora do middleware de resolução de tenant**. Toda a API de hoje pressupõe
/// um subdomínio já resolvido, e esta é justamente a chamada feita quando não
/// há nenhum. O endpoint `catalogo/municipios` que já existe não serve: ele é
/// catálogo de endereço do requerente, dentro de um tenant.
///
/// A lista traz só os municípios com contrato, não os 5.570 do país.
abstract class MunicipalityService {
  Future<List<Municipality>> loadAvailable();
}
