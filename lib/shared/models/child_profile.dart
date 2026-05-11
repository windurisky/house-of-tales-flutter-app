class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.avatarId,
  });

  final String id;
  final String name;
  final String ageLabel;
  final String avatarId;

  ChildProfile copyWith({String? name, String? ageLabel, String? avatarId}) {
    return ChildProfile(
      id: id,
      name: name ?? this.name,
      ageLabel: ageLabel ?? this.ageLabel,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}
