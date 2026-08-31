import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Anuncia [message] ao leitor de tela.
///
/// Um `errorText` aparecendo não gera anúncio nenhum, então sem isto o
/// usuário de leitor de tela só percebe que o botão parou de girar.
/// Guardado por supportsAnnounceOf porque o Android depreciou os eventos de
/// anúncio (forçam o TalkBack a limpar a fila de fala) e nem toda plataforma
/// os suporta.
void announceToScreenReader(BuildContext context, String message) {
  if (!MediaQuery.supportsAnnounceOf(context)) return;
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}
