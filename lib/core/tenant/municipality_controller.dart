import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/municipality.dart';

/// Município escolhido pelo usuário — o tenant contra o qual o app fala.
///
/// Deliberadamente **fora** do [AppPreferencesController]: aquele declara no
/// próprio doc que guarda "puramente preferência de UI/acessibilidade, sem
/// regra de negócio". O município determina quais dados o app enxerga, o que é
/// outra natureza de estado. O padrão de persistência é o mesmo; o lugar, não.
///
/// A escolha é do **aparelho**, não da conta: sair da conta não a limpa. Só o
/// "trocar município" limpa, e isso obriga novo login porque o token é amarrado
/// ao tenant.
class MunicipalityController extends ChangeNotifier {
  static const _key = 'tenant_municipality';

  // Posicional porque parâmetro nomeado não pode começar com underscore, e
  // sem o formal de inicialização o analyzer reclama.
  MunicipalityController._(this._selected, this._prefs);

  final SharedPreferences _prefs;

  Municipality? _selected;
  Municipality? get selected => _selected;

  bool get hasSelection => _selected != null;

  /// Carregado antes do primeiro quadro, junto das preferências: é o que
  /// permite decidir entre seletor e login sem piscar uma tela na outra.
  static Future<MunicipalityController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return MunicipalityController._(_read(prefs), prefs);
  }

  static Municipality? _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return Municipality.fromJson(decoded);
    } catch (_) {
      // Dado corrompido cai no seletor, em vez de derrubar o boot.
      return null;
    }
  }

  void select(Municipality municipality) {
    if (_selected?.id == municipality.id) return;
    _selected = municipality;
    unawaited(_prefs.setString(_key, jsonEncode(municipality.toJson())));
    notifyListeners();
  }

  /// Some com a escolha. Quem chama é o fluxo de troca de município, que
  /// depois navega para o seletor — trocar o `home:` do MaterialApp não
  /// navega sozinho.
  void clear() {
    if (_selected == null) return;
    _selected = null;
    unawaited(_prefs.remove(_key));
    notifyListeners();
  }
}
