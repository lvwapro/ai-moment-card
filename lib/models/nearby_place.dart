/// 附近地点模型
class NearbyPlace {
  final String id;
  final String name;
  final String address;
  final String location;
  final String distance;
  final String type;
  final String? tel;
  final List<String> photos;
  final String? rating;
  final String? cost;
  final String pname;
  final String cityname;
  final String adname;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.distance,
    required this.type,
    this.tel,
    required this.photos,
    this.rating,
    this.cost,
    required this.pname,
    required this.cityname,
    required this.adname,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    final bizExt = json['biz_ext'] as Map<String, dynamic>?;
    final photosList = json['photos'] as List?;

    // 安全提取值的辅助函数
    String? extractValue(dynamic data) {
      if (data == null) return null;
      if (data is String && data.isNotEmpty) return data;
      if (data is num) return data.toString();
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is String && first.isNotEmpty) return first;
        if (first is num) return first.toString();
      }
      return null;
    }

    return NearbyPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '0',
      type: json['type']?.toString() ?? '',
      tel: extractValue(json['tel']),
      photos: photosList
              ?.map((p) => (p is Map ? p['url']?.toString() : null))
              .where((url) => url != null && url.isNotEmpty)
              .cast<String>()
              .toList() ??
          [],
      rating: extractValue(bizExt?['rating']),
      cost: extractValue(bizExt?['cost']),
      pname: json['pname']?.toString() ?? '',
      cityname: json['cityname']?.toString() ?? '',
      adname: json['adname']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'location': location,
        'distance': distance,
        'type': type,
        'tel': tel,
        'photos': photos.map((url) => {'url': url}).toList(),
        'biz_ext': {
          'rating': rating,
          'cost': cost,
        },
        'pname': pname,
        'cityname': cityname,
        'adname': adname,
      };

  String get distanceText {
    final dist = int.tryParse(distance) ?? 0;
    if (dist < 1000) {
      return '${dist}m';
    } else {
      return '${(dist / 1000).toStringAsFixed(1)}km';
    }
  }

  String get typeShort {
    final parts = type.split(';');
    return parts.length > 1 ? parts[1] : type;
  }
}

/// 附近地点响应数据
class NearbyPlacesResponse {
  final int count;
  final List<NearbyPlace> places;
  final double longitude;
  final double latitude;

  NearbyPlacesResponse({
    required this.count,
    required this.places,
    required this.longitude,
    required this.latitude,
  });

  factory NearbyPlacesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final poisList = data['pois'] as List?;
    final location = data['location'] as Map<String, dynamic>?;

    return NearbyPlacesResponse(
      count: data['count'] ?? 0,
      places: poisList
              ?.map((poi) => NearbyPlace.fromJson(poi as Map<String, dynamic>))
              .toList() ??
          [],
      longitude: location?['longitude'] ?? 0.0,
      latitude: location?['latitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'pois': places.map((p) => p.toJson()).toList(),
        'location': {
          'longitude': longitude,
          'latitude': latitude,
        },
      };
}
