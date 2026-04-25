class RestaurantDetail {
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
  final String supportEmail;
  final String supportPhone;
  final RestaurantAddress? address;
  final List<WorkingDay> workingDays;
  final List<ItemCategory> itemCategories;
  final List<MenuItem> itemList;

  RestaurantDetail({
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
    required this.supportEmail,
    required this.supportPhone,
    required this.address,
    required this.workingDays,
    required this.itemCategories,
    required this.itemList,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    // parse working days
    List<WorkingDay> days = [];
    if (json['workingDays'] is List) {
      days = (json['workingDays'] as List)
          .map((d) => WorkingDay.fromJson(d))
          .toList();
    }

    List<ItemCategory> categories = [];
    if (json['itemCategories'] is List) {
      categories = (json['itemCategories'] as List)
          .map((c) => ItemCategory.fromJson(c))
          .toList();
    }

    List<MenuItem> items = [];
    if (json['itemList'] is List) {
      items = (json['itemList'] as List)
          .map((i) => MenuItem.fromJson(i))
          .toList();
    }

    return RestaurantDetail(
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
      supportEmail: json['supportEmail'] ?? '',
      supportPhone: json['supportPhone'] ?? '',
      address: json['address'] != null
          ? RestaurantAddress.fromJson(json['address'])
          : null,
      workingDays: days,
      itemCategories: categories,
      itemList: items,
    );
  }
}

class RestaurantAddress {
  final String block;
  final String street;
  final String areaName;
  final String stateName;

  RestaurantAddress({
    required this.block,
    required this.street,
    required this.areaName,
    required this.stateName,
  });

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) {
    return RestaurantAddress(
      block: json['block'] ?? '',
      street: json['street'] ?? '',
      areaName: json['areaName'] ?? '',
      stateName: json['stateName'] ?? '',
    );
  }

  String get fullAddress {
    final parts = [block, street, areaName, stateName]
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

class WorkingDay {
  final String day;
  final String startTime;
  final String endTime;

  WorkingDay({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}

class ItemCategory {
  final int id;
  final String name;

  ItemCategory({required this.id, required this.name});

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String shortDescription;
  final String description;
  final double regularPrice;
  final double finalPrice;
  final String preparationTime;
  final String defaultImage;
  final List<String> images;
  final bool isAvailable;
  final String categoryName;
  final String calories;
  final String carbs;
  final String fats;
  final String proteins;

  MenuItem({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.regularPrice,
    required this.finalPrice,
    required this.preparationTime,
    required this.defaultImage,
    required this.images,
    required this.isAvailable,
    required this.categoryName,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.proteins,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];
    if (json['images'] is List) {
      imgs = (json['images'] as List).map((e) => e.toString()).toList();
    }

    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      description: json['description'] ?? '',
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      preparationTime: json['preparationTime'] ?? '',
      defaultImage: json['defaultImage'] ?? '',
      images: imgs,
      isAvailable: json['isAvailable'] == 1,
      categoryName: json['categoryName'] ?? '',
      calories: json['calories'] ?? '0',
      carbs: json['carbs'] ?? '0',
      fats: json['fats'] ?? '0',
      proteins: json['proteins'] ?? '0',
    );
  }
}
