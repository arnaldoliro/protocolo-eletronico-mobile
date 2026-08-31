import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

/// Confirma e encerra a sessão.
///
/// Confirma **e navega**, de propósito: o menu lateral e a tela de conta
/// chamam os dois esta função. Se cada tela navegasse por conta própria, o
/// TODO(auth) abaixo passaria a existir em dois lugares e um deles seria
/// esquecido quando a sessão existir de verdade.
Future<void> confirmAndLogout(BuildContext context) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Sair da conta',
    message: 'Deseja realmente sair?',
    confirmLabel: 'Sair',
    isDestructive: true,
  );

  if (!confirmed || !context.mounted) return;

  // TODO(auth): quando existir sessão/token, invalidar no backend e limpar o
  // storage local ANTES de navegar. Hoje AuthService só expõe login(), então
  // isto é apenas navegação — não é logout de verdade.
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
}
