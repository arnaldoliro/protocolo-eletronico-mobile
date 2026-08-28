import 'package:flutter/material.dart';
import 'core/theme/app_preferences_controller.dart';
import 'core/theme/app_preferences_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/login/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferencesController.load();
  runApp(AppPreferencesScope(controller: preferences, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppPreferencesScope.of registra a dependência: este widget reconstrói
    // sozinho a cada notifyListeners() do controller, sem builder extra.
    final preferences = AppPreferencesScope.of(context);

    return MaterialApp(
      title: 'Protocolo Eletrônico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: preferences.themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(preferences.fontScale),
          ),
          child: child!,
        );
      },
      home: const LoginScreen(),
      // Rota nomeada para o logout voltar ao login sem que a feature
      // "home" precise importar a feature "login" (evita ciclo).
      routes: {'/login': (_) => const LoginScreen()},
    );
  }
}
