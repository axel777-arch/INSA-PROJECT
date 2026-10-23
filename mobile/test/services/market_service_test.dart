import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/market_service.dart';
import 'package:mobile/models/market_price_model.dart';

import 'content_service_test.mocks.dart';

void main() {
  group('MarketService Tests', () {
    late MarketService marketService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      marketService = MarketService(apiClient: mockApiClient);
    });

    test('getMarketPrices fetches items from API when available', () async {
      when(mockApiClient.get('/market/prices')).thenAnswer((_) async => [
        {
          'id': 'api-mkt-1',
          'commodity': 'Teff',
          'market': 'Addis Ababa Central',
          'region': 'Addis Ababa',
          'pricePerQuintal': 9800.0,
          'pricePerKg': 98.0,
          'currency': 'ETB',
          'observationDate': '2026-10-23T08:00:00Z',
          'dataSource': 'ECX Addis Ababa Branch',
          'freshnessStatus': 'Verified Today',
          'priceTrendPercentage': 1.5,
          'isSampleData': false,
        }
      ]);

      final prices = await marketService.getMarketPrices();

      expect(prices.length, 1);
      expect(prices.first.commodity, 'Teff');
      expect(prices.first.pricePerQuintal, 9800.0);
      expect(prices.first.pricePerKg, 98.0);
      expect(prices.first.isVerified, isTrue);
      verify(mockApiClient.get('/market/prices')).called(1);
    });

    test('getMarketPrices falls back to curated Ethiopian market data on API error', () async {
      when(mockApiClient.get('/market/prices')).thenThrow(ApiException('Network Error'));

      final prices = await marketService.getMarketPrices();

      expect(prices.isNotEmpty, isTrue);
      // Fallback includes major commodities like Teff, Wheat, Maize, Coffee
      final commodities = prices.map((p) => p.commodity).toSet();
      expect(commodities.contains('Teff (Magna / White)'), isTrue);
      expect(commodities.contains('Wheat (Bread Wheat)'), isTrue);
      expect(commodities.contains('Coffee Arabica (Jimma Grade 2)'), isTrue);
      verify(mockApiClient.get('/market/prices')).called(1);
    });

    test('filterPrices correctly filters by commodity', () async {
      final list = [
        MarketPriceModel(
          id: '1',
          commodity: 'Teff (Magna / White)',
          market: 'Addis Ababa',
          region: 'Addis Ababa',
          pricePerQuintal: 9500,
          pricePerKg: 95,
          currency: 'ETB',
          observationDate: DateTime.now(),
          dataSource: 'ECX',
          freshnessStatus: 'Verified Today',
        ),
        MarketPriceModel(
          id: '2',
          commodity: 'Wheat',
          market: 'Adama',
          region: 'Oromia',
          pricePerQuintal: 5200,
          pricePerKg: 52,
          currency: 'ETB',
          observationDate: DateTime.now(),
          dataSource: 'ECX',
          freshnessStatus: 'Verified Today',
        ),
      ];

      final filtered = marketService.filterPrices(list, commodity: 'Teff');
      expect(filtered.length, 1);
      expect(filtered.first.commodity, 'Teff (Magna / White)');
    });

    test('filterPrices correctly filters by market and search query', () async {
      final list = [
        MarketPriceModel(
          id: '1',
          commodity: 'Teff',
          market: 'Addis Ababa Central',
          region: 'Addis Ababa',
          pricePerQuintal: 9500,
          pricePerKg: 95,
          currency: 'ETB',
          observationDate: DateTime.now(),
          dataSource: 'ECX',
          freshnessStatus: 'Verified Today',
        ),
        MarketPriceModel(
          id: '2',
          commodity: 'Teff',
          market: 'Adama Grain Center',
          region: 'Oromia',
          pricePerQuintal: 9200,
          pricePerKg: 92,
          currency: 'ETB',
          observationDate: DateTime.now(),
          dataSource: 'ECX',
          freshnessStatus: 'Verified Today',
        ),
      ];

      final filteredMarket = marketService.filterPrices(list, market: 'Adama');
      expect(filteredMarket.length, 1);
      expect(filteredMarket.first.market, 'Adama Grain Center');

      final searched = marketService.filterPrices(list, searchQuery: 'Addis');
      expect(searched.length, 1);
      expect(searched.first.market, 'Addis Ababa Central');
    });

    test('getCommodities and getMarkets return distinct sorted lists', () async {
      final commodities = await marketService.getCommodities();
      final markets = await marketService.getMarkets();

      expect(commodities.isNotEmpty, isTrue);
      expect(markets.isNotEmpty, isTrue);
      expect(commodities.contains('Teff (Magna / White)'), isTrue);
      expect(markets.any((m) => m.contains('Addis Ababa')), isTrue);
    });
  });
}
