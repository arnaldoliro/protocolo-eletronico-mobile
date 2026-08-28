import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_panel.dart';

/// Barra inferior fixa com 3 itens: Menu (esquerda), Home (centro) e
/// Avisos (direita). Nenhum deles navega — o [HomeShell] traduz a seleção
/// em deslizamento dos painéis laterais.
///
/// Widget controlado: o estado de qual painel está ativo vive no shell.
class BottomNavBar extends StatelessWidget {
  final HomePanel active;
  final ValueChanged<HomePanel> onSelect;

  const BottomNavBar({super.key, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.navBg,
        boxShadow: colors.navShadow,
      ),
      child: SafeArea(
        top: false,
        // minHeight (e não altura fixa) para a barra crescer junto com a
        // escala de fonte, em vez de estourar em RenderFlex overflow.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          // Expanded em cada item garante 1/3 exato da largura para cada um,
          // então o Home fica no centro matemático da barra independente do
          // tamanho dos textos ou da escala de fonte.
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.menu_rounded,
                  label: 'Menu',
                  isSelected: active == HomePanel.menu,
                  colors: colors,
                  onTap: () => onSelect(HomePanel.menu),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: active == HomePanel.home,
                  colors: colors,
                  onTap: () => onSelect(HomePanel.home),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.notifications_none_outlined,
                  label: 'Avisos',
                  isSelected: active == HomePanel.notices,
                  colors: colors,
                  onTap: () => onSelect(HomePanel.notices),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? colors.primary : colors.navInactive;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
