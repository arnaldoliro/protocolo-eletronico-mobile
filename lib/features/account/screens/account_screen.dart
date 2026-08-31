import 'package:flutter/material.dart';

import '../../../core/models/account_profile.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/mock/profile_mock_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/logout_action.dart';
import '../../home/screens/help_screen.dart';
import '../widgets/account_card.dart';
import '../widgets/change_password_card.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/profile_card.dart';

enum _LoadState { loading, error, ready }

/// Perfil do usuário: dados pessoais, troca de senha, ajuda e encerrar sessão.
class AccountScreen extends StatefulWidget {
  final UserModel user;

  /// Avisa a Home que o perfil mudou.
  ///
  /// Callback e não `Navigator.pop(resultado)`: a tela pode ser fechada pelo
  /// botão do AppBar, pelo gesto do sistema ou pelo PopScope, e bastaria um
  /// desses caminhos popar sem resultado para o nome ficar desatualizado.
  /// Além disso cobre o caso "salva, continua na tela trocando a senha, e só
  /// depois volta".
  final ValueChanged<UserModel> onUserUpdated;

  const AccountScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ProfileService _service = ProfileMockService();

  _LoadState _state = _LoadState.loading;
  AccountProfile? _profile;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final profile = await _service.load();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _state = _LoadState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _LoadState.error);
    }
  }

  void _onSaved(AccountProfile profile) {
    setState(() => _profile = profile);
    // copyWith para não descartar a photoUrl ao trocar só o nome.
    widget.onUserUpdated(widget.user.copyWith(name: profile.name));
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: 'Descartar alterações?',
      message: 'Você editou seus dados e ainda não salvou.',
      confirmLabel: 'Descartar',
      cancelLabel: 'Continuar editando',
      isDestructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      // Também intercepta o gesto de voltar do sistema, não só o botão.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Minha conta'),
          backgroundColor: colors.surface,
          foregroundColor: colors.inputText,
          elevation: 0,
        ),
        body: switch (_state) {
          _LoadState.loading => Center(
            child: CircularProgressIndicator(color: colors.primary),
          ),
          _LoadState.error => _buildError(colors),
          _LoadState.ready => _buildContent(colors),
        },
      ),
    );
  }

  Widget _buildError(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar seus dados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.inputBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    final profile = _profile!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ProfileCard(
          // O nome vem do perfil salvo, para refletir a edição na hora.
          user: widget.user.copyWith(name: profile.name),
          profile: profile,
        ),
        const SizedBox(height: 16),

        PersonalDataCard(
          profile: profile,
          onSaved: _onSaved,
          onDirtyChanged: (dirty) =>
              setState(() => _hasUnsavedChanges = dirty),
        ),
        const SizedBox(height: 16),

        const ChangePasswordCard(),
        const SizedBox(height: 16),

        AccountCard(
          icon: Icons.menu_book_outlined,
          title: 'Ajuda',
          description:
              'Passo a passo com as telas do portal, do cadastro ao '
              'acompanhamento.',
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.inputBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Como usar o portal'),
          ),
        ),
        const SizedBox(height: 16),

        AccountCard(
          icon: Icons.logout_rounded,
          title: 'Encerrar sessão',
          description: 'Você poderá entrar de novo a qualquer momento.',
          accent: colors.statusError,
          child: OutlinedButton.icon(
            // Mesmo caminho do item "Sair" no menu lateral.
            onPressed: () => confirmAndLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.statusError,
              side: BorderSide(color: colors.statusError),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sair da conta'),
          ),
        ),
      ],
    );
  }
}
