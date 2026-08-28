import 'package:flutter/material.dart';

import 'app_preferences_controller.dart';

/// Disponibiliza o [AppPreferencesController] para a árvore de widgets.
/// Usa [InheritedNotifier], que já escuta o [ChangeNotifier] e reconstrói
/// automaticamente qualquer widget que dependa dele via [of]/[maybeOf].
class AppPreferencesScope extends InheritedNotifier<AppPreferencesController> {
  const AppPreferencesScope({
    super.key,
    required AppPreferencesController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Uso obrigatório: lança se não houver um [AppPreferencesScope] acima na árvore.
  static AppPreferencesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppPreferencesScope>();
    assert(scope != null, 'Nenhum AppPreferencesScope encontrado na árvore de widgets.');
    return scope!.notifier!;
  }

  /// Uso tolerante: retorna null se não houver o scope montado (ex.: testes
  /// de widget isolados), permitindo que consumidores caiam num fallback.
  static AppPreferencesController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppPreferencesScope>()?.notifier;
  }
}
