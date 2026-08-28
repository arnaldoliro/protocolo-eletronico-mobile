import 'package:flutter/material.dart';
import '../../../core/theme/app_preferences_controller.dart';
import '../../../core/theme/app_preferences_scope.dart';
import '../../../core/theme/app_theme.dart';

/// Barra fixa de acessibilidade: assistente (placeholder), zoom de fonte
/// (A-/A/A+), alternância de tema claro/escuro e alto contraste.
class AccessibilityBar extends StatelessWidget {
  const AccessibilityBar({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final preferences = AppPreferencesScope.of(context);
    final isDark = preferences.themeMode == ThemeMode.dark;

    return Row(
      children: [
        _IconButton(
          icon: Icons.auto_awesome_outlined,
          colors: colors,
          onTap: () => _showComingSoon(context),
        ),
        const SizedBox(width: 8),
        _FontScaleGroup(colors: colors, preferences: preferences),
        const Spacer(),
        _IconButton(
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          colors: colors,
          highlighted: true,
          onTap: preferences.toggleTheme,
        ),
        const SizedBox(width: 8),
        _IconButton(
          icon: Icons.contrast,
          colors: colors,
          highlighted: preferences.highContrast,
          onTap: preferences.toggleHighContrast,
        ),
      ],
    );
  }
}

class _FontScaleGroup extends StatelessWidget {
  final AppColors colors;
  final AppPreferencesController preferences;

  const _FontScaleGroup({required this.colors, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FontScaleButton(
            label: 'A-',
            colors: colors,
            onTap: preferences.fontScale > AppPreferencesController.minFontScale
                ? preferences.decreaseFontScale
                : null,
          ),
          _FontScaleButton(
            label: 'A',
            colors: colors,
            onTap: preferences.fontScale != AppPreferencesController.defaultFontScale
                ? preferences.resetFontScale
                : null,
          ),
          _FontScaleButton(
            label: 'A+',
            colors: colors,
            onTap: preferences.fontScale < AppPreferencesController.maxFontScale
                ? preferences.increaseFontScale
                : null,
          ),
        ],
      ),
    );
  }
}

class _FontScaleButton extends StatelessWidget {
  final String label;
  final AppColors colors;
  final VoidCallback? onTap;

  const _FontScaleButton({required this.label, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? colors.inputText : colors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;
  final bool highlighted;

  const _IconButton({
    required this.icon,
    required this.colors,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: highlighted ? colors.primary : colors.surface,
          shape: BoxShape.circle,
          boxShadow: colors.cardShadow,
        ),
        child: Icon(
          icon,
          size: 18,
          color: highlighted ? Colors.white : colors.inputText,
        ),
      ),
    );
  }
}
