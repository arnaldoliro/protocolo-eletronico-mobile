/// Mínimo de caracteres na descrição para o formulário poder avançar.
///
/// É só UX — evita mandar ao setor uma solicitação vazia demais para ser
/// analisada. O backend é a autoridade sobre o que aceita.
const int kMinDescriptionLength = 10;

/// O que o usuário preencheu no assistente, até agora.
///
/// Imutável de propósito: [missingRequirements] e [isEmpty] viram funções
/// puras sobre ele, sem estado paralelo para manter em sincronia. Os
/// TextEditingController ficam no State da tela, não aqui.
class NewProcessDraft {
  final String? categoryId;
  final String? sizeId;
  final String? subjectId;
  final String? departmentId;
  final String description;
  final String observations;

  const NewProcessDraft({
    this.categoryId,
    this.sizeId,
    this.subjectId,
    this.departmentId,
    this.description = '',
    this.observations = '',
  });

  NewProcessDraft copyWith({
    String? categoryId,
    String? sizeId,
    String? subjectId,
    String? departmentId,
    String? description,
    String? observations,
  }) {
    return NewProcessDraft(
      categoryId: categoryId ?? this.categoryId,
      sizeId: sizeId ?? this.sizeId,
      subjectId: subjectId ?? this.subjectId,
      departmentId: departmentId ?? this.departmentId,
      description: description ?? this.description,
      observations: observations ?? this.observations,
    );
  }

  /// Nada preenchido. É o que decide se sair da tela precisa de confirmação —
  /// derivar disto, em vez de marcar uma flag em cada onChanged, faz apagar um
  /// campo de volta ao vazio "des-sujar" o formulário corretamente.
  bool get isEmpty =>
      categoryId == null &&
      sizeId == null &&
      subjectId == null &&
      departmentId == null &&
      description.trim().isEmpty &&
      observations.trim().isEmpty;

  int get descriptionLength => description.trim().length;

  bool get hasEnoughDescription => descriptionLength >= kMinDescriptionLength;
}

/// O que ainda falta para o passo 1 poder avançar, na ordem visual dos campos.
///
/// Fonte única da validação: o build a chama uma vez e usa o resultado para
/// habilitar o botão, montar o resumo "Para continuar, falta: ..." e alimentar
/// a dica do leitor de tela. Sem isso, as três coisas divergem.
///
/// Validação apenas de UX — o backend revalida tudo.
List<String> missingRequirements(NewProcessDraft draft) {
  return [
    if (draft.categoryId == null) 'escolher a categoria do serviço',
    if (draft.sizeId == null) 'escolher o porte do serviço',
    if (draft.subjectId == null) 'escolher o assunto',
    if (draft.departmentId == null) 'escolher a secretaria de destino',
    if (!draft.hasEnoughDescription)
      'descrever a solicitação com pelo menos $kMinDescriptionLength caracteres',
  ];
}
