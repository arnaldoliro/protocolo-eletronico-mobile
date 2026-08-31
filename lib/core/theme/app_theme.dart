import 'package:flutter/material.dart';

import 'app_preferences_scope.dart';

class AppColors {
  // Fundos
  final Color background;
  final Color protocolBg;

  /// Gradiente de fundo das telas de autenticação. Mora na paleta, e não em
  /// [AppGradients], pelo mesmo motivo de [cardShadow]: varia por tema, e uma
  /// constante solta não tem como saber qual tema está ativo.
  final Gradient backgroundGradient;

  // Superfícies
  final Color surface;
  final Color cardBackground;
  final Color cardBorder;
  final List<BoxShadow> cardShadow;

  // Primária
  final Color primary;
  final Color primaryMedium;

  // Texto
  final Color navy;
  final Color inputText;
  final Color textSecondary;
  final Color textMuted;
  final Color textTime;

  // Inputs
  final Color inputFill;
  final Color inputBorder;

  // Ícones
  final Color iconBorder;

  // Nav bar
  final Color navBg;
  final Color navBorder;
  final Color navActive;
  final Color navInactive;
  final List<BoxShadow> navShadow;

  // Status
  final Color statusSuccess;
  final Color statusSuccessBg;
  final Color statusPending;
  final Color statusPendingBg;
  final Color statusError;

  const AppColors._({
    required this.background,
    required this.protocolBg,
    required this.backgroundGradient,
    required this.surface,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardShadow,
    required this.primary,
    required this.primaryMedium,
    required this.navy,
    required this.inputText,
    required this.textSecondary,
    required this.textMuted,
    required this.textTime,
    required this.inputFill,
    required this.inputBorder,
    required this.iconBorder,
    required this.navBg,
    required this.navBorder,
    required this.navActive,
    required this.navInactive,
    required this.navShadow,
    required this.statusSuccess,
    required this.statusSuccessBg,
    required this.statusPending,
    required this.statusPendingBg,
    required this.statusError,
  });

  static const light = AppColors._(
    background: Color(0xFFF5F7FA),
    protocolBg: Color(0xFFF5F7FA),
    backgroundGradient: LinearGradient(
      begin: Alignment(-0.6, -1),
      end: Alignment(0.6, 1),
      colors: [
        Color(0xFFF0F6FF),
        Color(0xFFFFFFFF),
        Color(0xFFF4F9FF),
        Color(0xFFEAF2FF),
      ],
      stops: [0.0, 0.4, 0.7, 1.0],
    ),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFEAF2FF),
    cardBorder: Color(0x143F7DFF),
    cardShadow: [
      BoxShadow(color: Color(0x143F7DFF), blurRadius: 20, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
    primary: Color(0xFF3F7DFF),
    primaryMedium: Color(0xFF1A6CF6),
    navy: Color(0xFF0D1B3E),
    inputText: Color(0xFF0D1B3E),
    textSecondary: Color(0xFF374151),
    textMuted: Color(0xFF6B7280),
    textTime: Color(0xFF9CA3AF),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFDFE1EB),
    iconBorder: Color(0xFFD4E8FF),
    navBg: Color(0xF2FFFFFF),
    navBorder: Color(0x1A3F7DFF),
    navActive: Color(0xFFEAF2FF),
    navInactive: Color(0xFF9CA3AF),
    navShadow: [
      BoxShadow(color: Color(0x143F7DFF), blurRadius: 24, offset: Offset(0, -4)),
    ],
    statusSuccess: Color(0xFF059669),
    statusSuccessBg: Color(0xFFECFDF5),
    statusPending: Color(0xFFD97706),
    statusPendingBg: Color(0xFFFFF7ED),
    statusError: Color(0xFFD4183D),
  );

  static const dark = AppColors._(
    background: Color(0xFF080E1C),
    protocolBg: Color(0xFF0B1525),
    backgroundGradient: LinearGradient(
      begin: Alignment(-0.6, -1),
      end: Alignment(0.6, 1),
      // Mais escuro embaixo de propósito: o card (surface 0xFF131E33) e a
      // cardBorder (azul a 14% de alpha) precisam continuar visíveis no rodapé.
      colors: [Color(0xFF080E1C), Color(0xFF0B1525), Color(0xFF060B16)],
      stops: [0.0, 0.45, 1.0],
    ),
    surface: Color(0xFF131E33),
    cardBackground: Color(0xFF0F1A2E),
    cardBorder: Color(0x243F7DFF),
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x4D000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
    primary: Color(0xFF3F7DFF),
    primaryMedium: Color(0xFF1A6CF6),
    navy: Color(0xFFE8F0FF),
    inputText: Color(0xFFE8F0FF),
    textSecondary: Color(0xFF4A6A9E),
    textMuted: Color(0xFF3D5578),
    textTime: Color(0xFF2D4060),
    inputFill: Color(0xFF0F1A2E),
    // Igual ao inputFill, o campo ficava sem borda nenhuma e só aparecia por
    // ser mais claro que o fundo. Sobre o gradiente escuro ele sumiria.
    inputBorder: Color(0x403F7DFF),
    iconBorder: Color(0x403F7DFF),
    navBg: Color(0xF7080E1C),
    navBorder: Color(0x1F3F7DFF),
    navActive: Color(0x2E3F7DFF),
    navInactive: Color(0xFF1E3050),
    navShadow: [
      BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, -4)),
    ],
    statusSuccess: Color(0xFF059669),
    statusSuccessBg: Color(0xFF064E3B),
    statusPending: Color(0xFFD97706),
    statusPendingBg: Color(0xFF78350F),
    statusError: Color(0xFFD4183D),
  );

  // Variante de alto contraste (acessibilidade). Mesmo shape/tokens das
  // paletas padrão, com pares texto/fundo em preto e branco puros e cores
  // de status mais saturadas para atender uma taxa de contraste maior.
  static const highContrastLight = AppColors._(
    background: Color(0xFFFFFFFF),
    protocolBg: Color(0xFFFFFFFF),
    // Alto contraste não leva gradiente de verdade: decoração de baixo
    // contraste é exatamente o que esta paleta existe para eliminar. Chapado,
    // acompanhando background. LinearGradient exige colors.length >= 2.
    backgroundGradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFF000000),
    cardShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 2)),
    ],
    primary: Color(0xFF0B4DE0),
    primaryMedium: Color(0xFF063C9E),
    navy: Color(0xFF000000),
    inputText: Color(0xFF000000),
    textSecondary: Color(0xFF111111),
    textMuted: Color(0xFF333333),
    textTime: Color(0xFF333333),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFF000000),
    iconBorder: Color(0xFF0B4DE0),
    navBg: Color(0xFFFFFFFF),
    navBorder: Color(0xFF000000),
    navActive: Color(0xFFD6E4FF),
    navInactive: Color(0xFF333333),
    navShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, -2)),
    ],
    statusSuccess: Color(0xFF046C4E),
    statusSuccessBg: Color(0xFFFFFFFF),
    statusPending: Color(0xFF92400E),
    statusPendingBg: Color(0xFFFFFFFF),
    statusError: Color(0xFFB91C1C),
  );

  static const highContrastDark = AppColors._(
    background: Color(0xFF000000),
    protocolBg: Color(0xFF000000),
    // Chapado, acompanhando background. Ver comentário em highContrastLight.
    backgroundGradient: LinearGradient(colors: [Color(0xFF000000), Color(0xFF000000)]),
    surface: Color(0xFF000000),
    cardBackground: Color(0xFF000000),
    cardBorder: Color(0xFFFFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x99000000), blurRadius: 12, offset: Offset(0, 2)),
    ],
    primary: Color(0xFF6FA8FF),
    primaryMedium: Color(0xFF8FBBFF),
    navy: Color(0xFFFFFFFF),
    inputText: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFEEEEEE),
    textMuted: Color(0xFFCCCCCC),
    textTime: Color(0xFFCCCCCC),
    inputFill: Color(0xFF000000),
    inputBorder: Color(0xFFFFFFFF),
    iconBorder: Color(0xFF6FA8FF),
    navBg: Color(0xFF000000),
    navBorder: Color(0xFFFFFFFF),
    navActive: Color(0xFF13284D),
    navInactive: Color(0xFFCCCCCC),
    navShadow: [
      BoxShadow(color: Color(0xCC000000), blurRadius: 16, offset: Offset(0, -2)),
    ],
    statusSuccess: Color(0xFF34D399),
    statusSuccessBg: Color(0xFF000000),
    statusPending: Color(0xFFFBBF24),
    statusPendingBg: Color(0xFF000000),
    statusError: Color(0xFFF87171),
  );

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highContrast = AppPreferencesScope.maybeOf(context)?.highContrast ?? false;

    if (highContrast) return isDark ? highContrastDark : highContrastLight;
    return isDark ? dark : light;
  }
}

class AppGradients {
  // Botão primário
  static const primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6CF6), Color(0xFF2979FF)],
  );

  // Header / banner do usuário
  static const headerBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3F7DFF), Color(0xFF2563EB)],
  );

  // Avatar
  static const avatar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3F7DFF), Color(0xFF1A56DB)],
  );

  // Timeline
  static const timelineLine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFBFDBFE), Colors.transparent],
  );

  // Glassmorphism (splash)
  static const iconCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEBFFFFFF), Color(0xD9EBF7FF)],
  );
}

class AppShadows {
  static const primaryButton = [
    BoxShadow(color: Color(0x521A6CF6), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const primaryButtonDark = [
    BoxShadow(color: Color(0x801A6CF6), blurRadius: 32, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    colorScheme: ColorScheme.light(
      surface: AppColors.light.surface,
      primary: AppColors.light.primary,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    colorScheme: ColorScheme.dark(
      surface: AppColors.dark.surface,
      primary: AppColors.dark.primary,
    ),
  );
}
