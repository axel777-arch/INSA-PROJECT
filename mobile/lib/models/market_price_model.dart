class MarketPriceModel {
  final String id;
  final String commodity;
  final String market;
  final String region;
  final double pricePerKg;
  final double pricePerQuintal;
  final String currency;
  final DateTime observationDate;
  final String dataSource;
  final String freshnessStatus;
  final double priceTrendPercentage;
  final bool isSampleData;

  const MarketPriceModel({
    required this.id,
    required this.commodity,
    required this.market,
    required this.region,
    required this.pricePerKg,
    required this.pricePerQuintal,
    this.currency = 'ETB',
    required this.observationDate,
    required this.dataSource,
    required this.freshnessStatus,
    this.priceTrendPercentage = 0.0,
    this.isSampleData = true,
  });

  String get marketName => market;
  bool get isVerified => freshnessStatus.toLowerCase().contains('verified');

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    final perKg = (json['pricePerKg'] as num?)?.toDouble() ?? 0.0;
    final perQuintal = (json['pricePerQuintal'] as num?)?.toDouble() ?? (perKg * 100);
    return MarketPriceModel(
      id: json['id'] as String? ?? 'mkt-${DateTime.now().millisecondsSinceEpoch}',
      commodity: json['commodity'] as String? ?? 'General Grain',
      market: json['market'] as String? ?? 'Local Market',
      region: json['region'] as String? ?? 'Ethiopia',
      pricePerKg: perKg,
      pricePerQuintal: perQuintal,
      currency: json['currency'] as String? ?? 'ETB',
      observationDate: json['observationDate'] != null
          ? DateTime.tryParse(json['observationDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dataSource: json['dataSource'] as String? ?? 'Regional Market Bureau / ECX',
      freshnessStatus: json['freshnessStatus'] as String? ?? 'Verified Today',
      priceTrendPercentage: (json['priceTrendPercentage'] as num?)?.toDouble() ?? 0.0,
      isSampleData: json['isSampleData'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'commodity': commodity,
    'market': market,
    'region': region,
    'pricePerKg': pricePerKg,
    'pricePerQuintal': pricePerQuintal,
    'currency': currency,
    'observationDate': observationDate.toIso8601String(),
    'dataSource': dataSource,
    'freshnessStatus': freshnessStatus,
    'priceTrendPercentage': priceTrendPercentage,
    'isSampleData': isSampleData,
  };
}
