class Restaurant {
  final int id;
  final String name;
  final String description;
  final String image;
  final String logo;
  final double rating;
  final double distance;
  final int deliveryTime;
  final bool isOpen;
  final bool isBusy;
  final double minimumOrderValue;
  final bool livelongVerified;
  final List<String> categoryNames;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.logo,
    required this.rating,
    required this.distance,
    required this.deliveryTime,
    required this.isOpen,
    required this.isBusy,
    required this.minimumOrderValue,
    required this.livelongVerified,
    required this.categoryNames,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    List<String> cats = [];
    if (json['categoryName'] is List) {
      cats = (json['categoryName'] as List).map((e) => e.toString()).toList();
    }

    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      logo: json['logo'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? 0,
      isOpen: json['isOpen'] == 1,
      isBusy: json['isBusy'] == 1,
      minimumOrderValue: (json['minimumOrderValue'] ?? 0).toDouble(),
      livelongVerified: json['livelongVerified'] == 1,
      categoryNames: cats,
    );
  }
}
