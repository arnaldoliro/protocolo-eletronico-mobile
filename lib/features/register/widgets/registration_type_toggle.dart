import 'package:flutter/material.dart';
import '../../../core/models/register_request.dart';
import '../../../core/theme/app_theme.dart';

/// Alterna entre Pessoa Física e Pessoa Jurídica.
///
/// Widget burro: sempre notifica [onChanged]. A regra de qual tipo está
/// disponível é da tela.
class RegistrationTypeToggle extends StatelessWidget {
  final RegistrationType selected;
  final ValueChanged<RegistrationType> onChanged;

  const RegistrationTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            icon: Icons.person_outline,
            type: RegistrationType.individual,
            isSelected: selected == RegistrationType.individual,
            onTap: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TypeOption(
            icon: Icons.apartment,
            type: RegistrationType.company,
            isSelected: selected == RegistrationType.company,
            onTap: onChanged,
          ),
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final RegistrationType type;
  final bool isSelected;
  final ValueChanged<RegistrationType> onTap;

  const _TypeOption({
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = isSelected ? Colors.white : colors.inputText;

    return Semantics(
      button: true,
      selected: isSelected,
      label: type.label,
      child: InkWell(
        onTap: () => onTap(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          // Altura mínima, não fixa: "Pessoa Jurídica" precisa poder quebrar
          // em duas linhas com a fonte ampliada.
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.inputBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  type.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
