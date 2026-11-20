class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String origin;
  final String location;
  final String url;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.url,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Sem nome',
      status: json['status']?.toString() ?? 'Desconhecido',
      species: json['species']?.toString() ?? 'Desconhecida',
      type: json['type']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Desconhecido',
      image: json['image']?.toString() ?? '',
      origin: (json['origin'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Desconhecida',
      location: (json['location'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Desconhecida',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'status': status, 'species': species,
    'type': type, 'gender': gender, 'image': image, 'origin': {'name': origin},
    'location': {'name': location}, 'url': url,
  };
}
