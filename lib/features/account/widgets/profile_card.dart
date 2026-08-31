import 'package:flutter/material.dart';
import '../../../core/models/account_profile.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

/// Cartão de identificação: avatar, nome e e-mail.
///
/// Recebe o [user] que a Home já tem, para nome e iniciais aparecerem na
/// hora, e o [profile] quando ele chega — só o e-mail depende do carregamento.
class ProfileCard extends StatelessWidget {
  final UserModel user;
  final AccountProfile? profile;

  const ProfileCard({super.key, required this.user, this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: colors.primary,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              // Sem isto, falha de rede vira exceção no console e avatar vazio.
              onBackgroundImageError: user.photoUrl != null
                  ? (_, _) {}
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.inputText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.email ?? '',
            textAlign: TextAlign.center,
            // E-mail institucional longo estoura numa largura de 320dp com a
            // fonte no máximo.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
