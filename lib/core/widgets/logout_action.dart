import 'package:flutter/material.dart';
import '../services/mock/mock_process_store.dart';
import '../state/support_chat_store.dart';
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

  // TODO: remover junto com os mocks. O store é compartilhado e em memória:
  // sem o reset, o próximo usuário a entrar veria os protocolos deste.
  MockProcessStore.instance.reset();
  // A conversa de suporte é de memória e compartilhada: sem o reset, o próximo
  // usuário abriria o Suporte e leria o que este digitou.
  SupportChatStore.instance.reset();

  // TODO(auth): quando existir sessão/token, invalidar no backend e limpar o
  // storage local ANTES de navegar. Hoje AuthService só expõe login(), então
  // isto é apenas navegação — não é logout de verdade.
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
}
