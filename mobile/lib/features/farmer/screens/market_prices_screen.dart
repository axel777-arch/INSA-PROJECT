import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/market_price_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/market_service.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketService _marketService = MarketService(apiClient: ApiClient());
  final TextEditingController _searchController = TextEditingController();

  List<MarketPriceModel> _prices = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isQuintal = true; // Toggle between Quintal (100kg) and Kg

  String _selectedCommodity = 'All';
  String _selectedMarket = 'All';

  final List<String> _commodities = [
    'All',
    'Teff',
    'Wheat',
    'Maize',
    'Coffee',
    'Barley',
    'Beans',
    'Sesame',
  ];

  final List<String> _markets = [
    'All',
    'Addis Ababa',
    'Adama',
    'Hawassa',
    'Bahir Dar',
    'Jimma',
    'Dire Dawa',
  ];

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _marketService.getMarketPrices(
        query: _searchController.text.trim(),
        commodity: _selectedCommodity == 'All' ? null : _selectedCommodity,
        market: _selectedMarket == 'All' ? null : _selectedMarket,
      );

      if (!mounted) return;
      setState(() {
        _prices = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.marketPricesTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: loc.refresh,
              onPressed: _loadPrices,
            ),
          ],
        ),
        body: Column(
          children: [
            // Sample data notice banner per Part 2 Rule 2
            Container(
              width: double.infinity,
              color: Colors.amber.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p8,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.amber),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      loc.sampleDataNotice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Unit Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.p16,
                AppSizes.p12,
                AppSizes.p16,
                AppSizes.p8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '${loc.search} (Teff, Adama, ECX...)',
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p12,
                          vertical: AppSizes.p10,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadPrices();
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _loadPrices(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  // Unit Toggle: Quintal vs Kg
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildUnitButton('Quintal', _isQuintal),
                        _buildUnitButton('Kg', !_isQuintal),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Commodity Filters
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _commodities.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                itemBuilder: (context, index) {
                  final item = _commodities[index];
                  final isSelected = _selectedCommodity == item;
                  return ChoiceChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCommodity = item);
                      _loadPrices();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),

            // Market Hub Filters
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _markets.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                itemBuilder: (context, index) {
                  final mkt = _markets[index];
                  final isSelected = _selectedMarket == mkt;
                  return ChoiceChip(
                    label: Text(mkt == 'All' ? 'All Markets' : mkt),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedMarket = mkt);
                      _loadPrices();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),

            // Content body
            Expanded(child: _buildContent(theme, loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String label, bool isSelected) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      onTap: () => setState(() => _isQuintal = label == 'Quintal'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.p12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),
              ElevatedButton.icon(
                onPressed: _loadPrices,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(appText('No market price records found for this filter.')),
            const SizedBox(height: AppSizes.p16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCommodity = 'All';
                  _selectedMarket = 'All';
                });
                _loadPrices();
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: Text(appText('Reset Filters')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrices,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _prices.length,
        itemBuilder: (context, index) {
          final item = _prices[index];
          final displayPrice = _isQuintal
              ? item.pricePerQuintal
              : item.pricePerKg;
          final unitLabel = _isQuintal ? loc.perQuintal : loc.perKg;

          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Commodity Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.commodity,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.market,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${displayPrice.toStringAsFixed(0)} ${item.currency}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            unitLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: AppSizes.p20),

                  // Row 2: Verification, Date & Trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.freshnessStatus,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (item.priceTrendPercentage != 0.0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (item.priceTrendPercentage > 0
                                        ? Colors.green
                                        : Colors.red)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.priceTrendPercentage > 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: item.priceTrendPercentage > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${item.priceTrendPercentage > 0 ? '+' : ''}${item.priceTrendPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.priceTrendPercentage > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${loc.dataSource}: ${item.dataSource}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
