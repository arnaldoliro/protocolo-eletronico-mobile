import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla as preferências de exibição do usuário: tema (claro/escuro),
/// alto contraste e escala de fonte. Persiste cada mudança localmente via
/// [SharedPreferences] para que a escolha sobreviva entre sessões do app.
///
/// Isto é puramente uma preferência de UI/acessibilidade — não contém
/// nenhuma regra de negócio.
class AppPreferencesController extends ChangeNotifier {
  static const _keyThemeMode = 'pref_theme_mode';
  static const _keyHighContrast = 'pref_high_contrast';
  static const _keyFontScale = 'pref_font_scale';

  static const double minFontScale = 0.85;
  static const double maxFontScale = 1.30;
  static const double defaultFontScale = 1.0;
  static const double _fontScaleStep = 0.15;

  AppPreferencesController._({
    required ThemeMode themeMode,
    required bool highContrast,
    required double fontScale,
    required this._prefs,
  }) : _themeMode = themeMode,
       _highContrast = highContrast,
       _fontScale = fontScale;

  final SharedPreferences _prefs;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool _highContrast;
  bool get highContrast => _highContrast;

  double _fontScale;
  double get fontScale => _fontScale;

  /// Carrega as preferências salvas antes do primeiro frame, evitando o
  /// "flash" de tema/tamanho errado no boot do app.
  static Future<AppPreferencesController> load() async {
    final prefs = await SharedPreferences.getInstance();

    final storedMode = prefs.getString(_keyThemeMode);
    final themeMode = switch (storedMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };

    return AppPreferencesController._(
      themeMode: themeMode,
      highContrast: prefs.getBool(_keyHighContrast) ?? false,
      fontScale: prefs.getDouble(_keyFontScale) ?? defaultFontScale,
      prefs: prefs,
    );
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    unawaited(_prefs.setString(_keyThemeMode, _themeMode == ThemeMode.dark ? 'dark' : 'light'));
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    unawaited(_prefs.setBool(_keyHighContrast, _highContrast));
    notifyListeners();
  }

  void increaseFontScale() => _setFontScale(_fontScale + _fontScaleStep);

  void decreaseFontScale() => _setFontScale(_fontScale - _fontScaleStep);

  void resetFontScale() => _setFontScale(defaultFontScale);

  void _setFontScale(double value) {
    // Arredondar para 2 casas antes de comparar: o passo 0.15 em IEEE-754 faz
    // 1.15 + 0.15 == 1.2999999999999998, que passa pelo clamp intacto e não é
    // igual a maxFontScale. Sem isto, subir de 0.85 até o teto exige 4 toques
    // em vez de 3, e o penúltimo já exibe "130%" com o botão ainda habilitado.
    final clamped =
        (value.clamp(minFontScale, maxFontScale) * 100).roundToDouble() / 100;
    if (clamped == _fontScale) return;
    _fontScale = clamped;
    unawaited(_prefs.setDouble(_keyFontScale, _fontScale));
    notifyListeners();
  }
}
