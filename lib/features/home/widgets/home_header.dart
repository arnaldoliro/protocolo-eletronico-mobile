import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;

  const HomeHeader({super.key, required this.user});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: colors.primary,
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, ${user.name} 👋',
                style: TextStyle(
                  color: colors.inputText,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Acompanhe seus processos',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_none_outlined,
            color: colors.inputText,
            size: 22,
          ),
        ),
      ],
    );
  }
}
