class UserModel {
  final String name;
  final String? photoUrl;

  const UserModel({required this.name, this.photoUrl});

  /// Iniciais derivadas do nome para exibição no avatar (ex.: "Maria Lopes" → "ML").
  /// Puramente apresentacional, não é dado sensível.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words[1][0]).toUpperCase();
  }
}
