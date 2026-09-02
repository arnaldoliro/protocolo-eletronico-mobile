import 'package:flutter/material.dart';

import '../services/mock/mock_process_store.dart';
import '../state/support_chat_store.dart';
import '../widgets/confirm_dialog.dart';
import 'municipality_scope.dart';

/// Troca de município com o usuário já autenticado.
///
/// Confirma antes porque o acesso é amarrado ao município: trocar derruba a
/// sessão e obriga novo login.
///
/// Existe separada do caminho da tela de login de propósito. Lá ninguém está
/// autenticado, não há nada a descartar, e perguntar "deseja encerrar a
/// sessão?" seria mentira — aquele caminho vai direto ao seletor.
Future<void> confirmAndChangeMunicipality(BuildContext context) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Trocar município?',
    message:
        'Você será desconectado e precisará entrar de novo, porque o acesso é '
        'vinculado ao município.',
    confirmLabel: 'Trocar',
    isDestructive: true,
  );

  if (!confirmed || !context.mounted) return;

  MunicipalityScope.of(context).clear();

  // TODO: remover junto com os mocks. Os stores são compartilhados e em
  // memória — sem o reset, os protocolos e a conversa do município anterior
  // apareceriam no novo.
  MockProcessStore.instance.reset();
  SupportChatStore.instance.reset();

  // TODO(auth): quando existir sessão/token, invalidar no backend ANTES de
  // navegar — o token do tenant antigo não vale no novo.

  // Navegação explícita: trocar o `home:` do MaterialApp reconstrói o widget
  // mas NÃO mexe na pilha, porque a página da rota fica em cache.
  Navigator.of(context).pushNamedAndRemoveUntil('/municipality', (_) => false);
}
