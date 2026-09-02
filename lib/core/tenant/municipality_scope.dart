import 'package:flutter/material.dart';

import 'municipality_controller.dart';

/// Disponibiliza o [MunicipalityController] para a árvore de widgets, no mesmo
/// molde do `AppPreferencesScope`.
class MunicipalityScope extends InheritedNotifier<MunicipalityController> {
  const MunicipalityScope({
    super.key,
    required MunicipalityController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Uso obrigatório: lança se não houver um [MunicipalityScope] acima.
  static MunicipalityController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MunicipalityScope>();
    assert(scope != null, 'Nenhum MunicipalityScope encontrado na árvore de widgets.');
    return scope!.notifier!;
  }

  /// Uso tolerante: devolve nulo quando o scope não está montado (testes de
  /// widget isolados), permitindo um fallback.
  static MunicipalityController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MunicipalityScope>()?.notifier;
  }
}
