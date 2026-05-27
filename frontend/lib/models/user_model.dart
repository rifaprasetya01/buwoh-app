class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? birthDate;
  final AddressModel? address;
  final UserStats? stats;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.birthDate,
    this.address,
    this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      birthDate: json['birthDate'],
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'birthDate': birthDate,
      'address': address?.toJson(),
      'stats': stats?.toJson(),
    };
  }
}

class AddressModel {
  final String? id;
  final String? street;
  final String? rtRw;
  final String? village;
  final String? district;
  final String? city;
  final String? province;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.id,
    this.street,
    this.rtRw,
    this.village,
    this.district,
    this.city,
    this.province,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      street: json['street'],
      rtRw: json['rtRw'],
      village: json['village'],
      district: json['district'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postalCode'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'rtRw': rtRw,
      'village': village,
      'district': district,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UserStats {
  final int totalBuwoh;
  final int totalEventsHosted;

  UserStats({required this.totalBuwoh, required this.totalEventsHosted});

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalBuwoh: json['totalBuwoh'] ?? 0,
      totalEventsHosted: json['totalEventsHosted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBuwoh': totalBuwoh,
      'totalEventsHosted': totalEventsHosted,
    };
  }
}
