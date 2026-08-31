import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scaffold das telas de autenticação: gradiente de fundo do tema ativo,
/// área segura e expansão para a tela inteira.
///
/// Existe para as três telas de auth não divergirem, mas principalmente por
/// causa do [SizedBox.expand]: o Scaffold entrega ao `body` constraints
/// frouxas (minHeight 0) e um SingleChildScrollView encolhe até a altura do
/// conteúdo — sem forçar a expansão, o gradiente pinta só atrás do card e o
/// resto da tela fica na cor lisa do Scaffold.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      // Fallback: evita um flash da cor errada durante o push da rota.
      backgroundColor: colors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        // Fora do SafeArea de propósito, para o gradiente sangrar sob a barra
        // de status e a barra de gestos.
        child: SizedBox.expand(child: SafeArea(child: child)),
      ),
    );
  }
}
