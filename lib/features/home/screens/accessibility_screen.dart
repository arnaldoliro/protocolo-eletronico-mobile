import 'package:flutter/material.dart';
import '../../../core/theme/app_preferences_controller.dart';
import '../../../core/theme/app_preferences_scope.dart';
import '../../../core/theme/app_theme.dart';

/// Preferências de acessibilidade com rótulos em texto.
///
/// A [AccessibilityBar] do topo da Home continua existindo como atalho — ela
/// é só de ícones, e quem mais depende desses controles é justamente quem tem
/// menos como adivinhar o que cada ícone faz.
class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final preferences = AppPreferencesScope.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Acessibilidade'),
        backgroundColor: colors.surface,
        foregroundColor: colors.inputText,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _FontScaleSection(colors: colors, preferences: preferences),
          const SizedBox(height: 8),
          Divider(color: colors.inputBorder, height: 24),

          _SwitchRow(
            colors: colors,
            icon: Icons.dark_mode_outlined,
            label: 'Tema escuro',
            description: 'Fundo escuro, mais confortável com pouca luz.',
            value: preferences.themeMode == ThemeMode.dark,
            onChanged: (_) => preferences.toggleTheme(),
          ),
          Divider(color: colors.inputBorder, height: 24),

          _SwitchRow(
            colors: colors,
            icon: Icons.contrast,
            label: 'Alto contraste',
            description:
                'Cores mais fortes e bordas mais marcadas, para leitura '
                'com baixa visão.',
            value: preferences.highContrast,
            onChanged: (_) => preferences.toggleHighContrast(),
          ),
        ],
      ),
    );
  }
}

class _FontScaleSection extends StatelessWidget {
  final AppColors colors;
  final AppPreferencesController preferences;

  const _FontScaleSection({required this.colors, required this.preferences});

  @override
  Widget build(BuildContext context) {
    final percent = (preferences.fontScale * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_size, color: colors.textMuted, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Tamanho da fonte',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          // Sem prometer o que o app não faz: isto ajusta a fonte DENTRO do
          // app, e não a configuração de fonte do sistema.
          'Ajusta o texto de todas as telas do aplicativo.',
          style: TextStyle(color: colors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Wrap e não Row: com a fonte no máximo, três botões de 48dp mais o
        // rótulo de porcentagem podem não caber numa linha só.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FontScaleButton(
              label: 'A-',
              semanticsLabel: 'Diminuir tamanho da fonte',
              colors: colors,
              onTap: preferences.fontScale > AppPreferencesController.minFontScale
                  ? preferences.decreaseFontScale
                  : null,
            ),
            _FontScaleButton(
              label: 'A',
              semanticsLabel: 'Restaurar tamanho padrão da fonte',
              colors: colors,
              onTap:
                  preferences.fontScale !=
                      AppPreferencesController.defaultFontScale
                  ? preferences.resetFontScale
                  : null,
            ),
            _FontScaleButton(
              label: 'A+',
              semanticsLabel: 'Aumentar tamanho da fonte',
              colors: colors,
              onTap: preferences.fontScale < AppPreferencesController.maxFontScale
                  ? preferences.increaseFontScale
                  : null,
            ),
            Text(
              'Atual: $percent%',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FontScaleButton extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final AppColors colors;
  final VoidCallback? onTap;

  const _FontScaleButton({
    required this.label,
    required this.semanticsLabel,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              // 48x48 é o alvo mínimo de toque. Os botões da AccessibilityBar
              // têm ~30dp — a tela de acessibilidade não vai repetir o erro.
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? colors.inputText : colors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha de preferência com interruptor.
///
/// Não é [SwitchListTile] de propósito: o título dele herda estilo do
/// [ListTileTheme]/[TextTheme], que não conhece as paletas de alto contraste
/// (o [ThemeData] do app nunca muda quando o alto contraste liga — só o
/// [AppColors] muda). Mesmo motivo já documentado em `app_input_decoration`.
class _SwitchRow extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.colors,
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mesma derivação usada no AuthCardHeader: branco fixo sobre primary
    // reprova o contraste em highContrastDark, onde primary é claro.
    final onPrimary =
        ThemeData.estimateBrightnessForColor(colors.primary) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: colors.textMuted, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                onChanged: onChanged,
                // Todas as cores explícitas: os defaults do Material 3 saem do
                // ColorScheme (onPrimary, outline, surfaceContainerHighest), que
                // não acompanha as paletas de alto contraste. activeColor está
                // deprecado no Flutter 3.44 — daí o WidgetStateProperty.
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? onPrimary
                      : colors.textSecondary,
                ),
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary
                      : colors.inputFill,
                ),
                trackOutlineColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary
                      : colors.inputBorder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
