import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;

  const HomeHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.primary.withValues(alpha: 0.15),
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Icon(Icons.person, color: colors.primary)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          user.name,
          style: TextStyle(
            color: colors.inputText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
