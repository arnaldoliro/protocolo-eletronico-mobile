import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

/// Painel lateral esquerdo, revelado ao deslizar o conteúdo para a direita.
/// Puramente apresentacional — quem navega é o [HomeShell], via callbacks.
class MenuPanel extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAccountTap;
  final VoidCallback onLogoutTap;

  const MenuPanel({
    super.key,
    required this.user,
    required this.onAccountTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: avatar + nome. UserModel só tem nome e foto,
            // então não há subtítulo aqui.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primary,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.inputText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colors.inputBorder, height: 1),
            const SizedBox(height: 8),

            _MenuTile(
              icon: Icons.person_outline,
              label: 'Conta',
              colors: colors,
              onTap: onAccountTap,
            ),

            const Spacer(),

            Divider(color: colors.inputBorder, height: 1),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: 'Sair',
              colors: colors,
              color: colors.statusError,
              onTap: onLogoutTap,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? colors.inputText;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tint,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
