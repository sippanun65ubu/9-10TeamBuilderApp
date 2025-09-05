class Pokemon {
  final String name;
  final String url;
  final String imageUrl;

  Pokemon({required this.name, required this.url, required this.imageUrl});

  // Factory constructor to create a Pokemon instance from a map (JSON)
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    final id = url.split('/')[6];
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return Pokemon(name: name, url: url, imageUrl: imageUrl);
  }

  // Method to convert a Pokemon instance to a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}