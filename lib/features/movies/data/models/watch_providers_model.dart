class WatchProviderModel {
  const WatchProviderModel({
    required this.providerId,
    required this.providerName,
    this.logoPath,
  });

  final int providerId;
  final String providerName;
  final String? logoPath;

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) {
    return WatchProviderModel(
      providerId: (json['provider_id'] as num).toInt(),
      providerName: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String?,
    );
  }
}

class WatchProvidersPayloadModel {
  const WatchProvidersPayloadModel({required this.resultsByRegion});

  final Map<String, RegionWatchProvidersModel> resultsByRegion;

  factory WatchProvidersPayloadModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final mapped = <String, RegionWatchProvidersModel>{};

    results.forEach((region, value) {
      if (value is Map<String, dynamic>) {
        mapped[region] = RegionWatchProvidersModel.fromJson(value);
      }
    });

    return WatchProvidersPayloadModel(resultsByRegion: mapped);
  }

  RegionWatchProvidersModel? forRegion(String region) => resultsByRegion[region];
}

class RegionWatchProvidersModel {
  const RegionWatchProvidersModel({
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
  });

  final List<WatchProviderModel> flatrate;
  final List<WatchProviderModel> rent;
  final List<WatchProviderModel> buy;

  factory RegionWatchProvidersModel.fromJson(Map<String, dynamic> json) {
    List<WatchProviderModel> parseList(String key) {
      return (json[key] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WatchProviderModel.fromJson)
          .toList();
    }

    return RegionWatchProvidersModel(
      flatrate: parseList('flatrate'),
      rent: parseList('rent'),
      buy: parseList('buy'),
    );
  }
}
