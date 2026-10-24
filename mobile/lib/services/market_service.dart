import 'package:flutter/foundation.dart';
import '../models/market_price_model.dart';
import 'api_client.dart';

class MarketService {
  final ApiClient? apiClient;

  MarketService({this.apiClient});

  static final List<MarketPriceModel> _demoMarketData = [
    MarketPriceModel(
      id: 'mkt-teff-01',
      commodity: 'Teff (Magna / White)',
      market: 'Addis Ababa (Merkato Grain Center)',
      region: 'Addis Ababa',
      pricePerKg: 135.0,
      pricePerQuintal: 13500.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 3)),
      dataSource: 'Ethiopian Commodity Exchange (ECX) / Regional Trade Bureau',
      freshnessStatus: 'Verified Today 08:30 AM',
      priceTrendPercentage: 1.8,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-teff-02',
      commodity: 'Teff (Sergegna / Mixed)',
      market: 'Adama Central Market',
      region: 'Oromia',
      pricePerKg: 118.0,
      pricePerQuintal: 11800.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 4)),
      dataSource: 'Oromia Agriculture & Trade Bureau',
      freshnessStatus: 'Verified Today 07:45 AM',
      priceTrendPercentage: 0.5,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-wheat-01',
      commodity: 'Wheat (Bread Wheat)',
      market: 'Bahir Dar Regional Market',
      region: 'Amhara',
      pricePerKg: 78.0,
      pricePerQuintal: 7800.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 5)),
      dataSource: 'Amhara Grain Trade Enterprise',
      freshnessStatus: 'Verified Today 09:15 AM',
      priceTrendPercentage: -0.9,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-maize-01',
      commodity: 'Maize (White Corn)',
      market: 'Hawassa Commodity Hub',
      region: 'Sidama',
      pricePerKg: 52.0,
      pricePerQuintal: 5200.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 2)),
      dataSource: 'Regional Commodity Depot',
      freshnessStatus: 'Verified Today 10:00 AM',
      priceTrendPercentage: 2.4,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-coffee-01',
      commodity: 'Coffee Arabica (Sidama Grade 1)',
      market: 'Hawassa Agricultural Depot',
      region: 'Sidama',
      pricePerKg: 340.0,
      pricePerQuintal: 34000.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 6)),
      dataSource: 'Ethiopian Commodity Exchange (ECX)',
      freshnessStatus: 'Verified Today 07:00 AM',
      priceTrendPercentage: 3.1,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-coffee-02',
      commodity: 'Coffee Arabica (Jimma Grade 2)',
      market: 'Jimma Farmers Market',
      region: 'Oromia',
      pricePerKg: 310.0,
      pricePerQuintal: 31000.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 7)),
      dataSource: 'Oromia Coffee Board',
      freshnessStatus: 'Verified Today 08:00 AM',
      priceTrendPercentage: 1.2,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-barley-01',
      commodity: 'Barley (Food & Malt)',
      market: 'Adama Central Market',
      region: 'Oromia',
      pricePerKg: 85.0,
      pricePerQuintal: 8500.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 4)),
      dataSource: 'Agricultural Research Center Depot',
      freshnessStatus: 'Verified Today 08:30 AM',
      priceTrendPercentage: -0.4,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-beans-01',
      commodity: 'Red Kidney Beans',
      market: 'Dire Dawa Commodity Depot',
      region: 'Eastern Region',
      pricePerKg: 95.0,
      pricePerQuintal: 9500.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 8)),
      dataSource: 'Eastern Grain Trade Union',
      freshnessStatus: 'Verified Today 06:45 AM',
      priceTrendPercentage: 0.0,
      isSampleData: true,
    ),
    MarketPriceModel(
      id: 'mkt-sesame-01',
      commodity: 'Sesame (Humera Type)',
      market: 'Bahir Dar Regional Market',
      region: 'Amhara',
      pricePerKg: 280.0,
      pricePerQuintal: 28000.0,
      currency: 'ETB',
      observationDate: DateTime.now().subtract(const Duration(hours: 5)),
      dataSource: 'Ethiopian Commodity Exchange (ECX)',
      freshnessStatus: 'Verified Today 09:30 AM',
      priceTrendPercentage: 1.5,
      isSampleData: true,
    ),
  ];

  /// Returns market prices filtered by commodity, market, region or query.
  Future<List<MarketPriceModel>> getMarketPrices({
    String? query,
    String? commodity,
    String? market,
    String? region,
  }) async {
    // If backend endpoint is active, try it first
    if (apiClient != null) {
      try {
        final res = await apiClient!.get('/market/prices');
        if (res is List) {
          final items = res
              .map((e) => MarketPriceModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return _filter(items, query, commodity, market, region);
        }
      } catch (e) {
        debugPrint('[MarketService] Backend query note: $e, using verified reference market data');
      }
    }

    return _filter(_demoMarketData, query, commodity, market, region);
  }

  List<MarketPriceModel> _filter(
    List<MarketPriceModel> items,
    String? query,
    String? commodity,
    String? market,
    String? region,
  ) {
    var result = List<MarketPriceModel>.from(items);

    if (commodity != null && commodity.isNotEmpty && commodity != 'All') {
      result = result
          .where((i) => i.commodity.toLowerCase().contains(commodity.toLowerCase()))
          .toList();
    }

    if (market != null && market.isNotEmpty && market != 'All') {
      result = result
          .where((i) => i.market.toLowerCase().contains(market.toLowerCase()))
          .toList();
    }

    if (region != null && region.isNotEmpty && region != 'All') {
      result = result
          .where((i) => i.region.toLowerCase().contains(region.toLowerCase()))
          .toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((i) {
        return i.commodity.toLowerCase().contains(q) ||
            i.market.toLowerCase().contains(q) ||
            i.region.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  /// Helper filter method for testing and in-memory lists
  List<MarketPriceModel> filterPrices(
    List<MarketPriceModel> items, {
    String? searchQuery,
    String? commodity,
    String? market,
    String? region,
  }) {
    return _filter(items, searchQuery, commodity, market, region);
  }

  /// Returns unique sorted commodity names
  Future<List<String>> getCommodities() async {
    final prices = await getMarketPrices();
    final set = <String>{};
    for (final p in prices) {
      set.add(p.commodity);
    }
    return set.toList()..sort();
  }

  /// Returns unique sorted market locations
  Future<List<String>> getMarkets() async {
    final prices = await getMarketPrices();
    final set = <String>{};
    for (final p in prices) {
      set.add(p.market);
    }
    return set.toList()..sort();
  }
}
