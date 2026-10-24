import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/api_client.dart';

class FarmMapWidget extends StatefulWidget {
  final double height;
  final bool interactive;

  const FarmMapWidget({
    super.key,
    this.height = 240,
    this.interactive = true,
  });

  @override
  State<FarmMapWidget> createState() => _FarmMapWidgetState();
}

class _FarmMapWidgetState extends State<FarmMapWidget> {
  final ApiClient _apiClient = ApiClient();
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;
  String _lastUpdatedText = 'Just now';
  Timer? _pollingTimer;

  // Center on Ethiopia (approx 9.145, 40.489)
  final LatLng _initialCenter = const LatLng(9.145, 39.5);

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    // Periodic polling every 30 seconds for live marker updates without full page reload
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchLocations(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocations({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get('/farmers/locations');
      if (!mounted) return;

      if (response is List) {
        setState(() {
          _locations = response.cast<Map<String, dynamic>>();
          _isLoading = false;
          final now = DateTime.now();
          _lastUpdatedText =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showMarkerDetails(Map<String, dynamic> loc) {
    final name = loc['fullName'] ?? 'Farmer';
    final crop = loc['primaryCrop'] ?? 'Teff';
    final region = loc['region'] ?? 'Oromia';
    final woreda = loc['woreda'] ?? 'District';
    final kebele = loc['kebele'] ?? 'Kebele';
    final phone = loc['phone'] ?? 'N/A';

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.agriculture_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$region • $woreda ($kebele)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(crop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  backgroundColor: AppColors.success.withValues(alpha: 0.15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(phone, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('GPS: ${loc['latitude']}, ${loc['longitude']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.satellite_alt_rounded, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text('Live Agricultural GIS Map', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live • $_lastUpdatedText',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Refresh Markers',
                      onPressed: () => _fetchLocations(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 6.2,
                    interactionOptions: InteractionOptions(
                      flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'et.gov.insa.agri_insight',
                    ),
                    MarkerLayer(
                      markers: _locations.map((loc) {
                        final lat = (loc['latitude'] as num?)?.toDouble() ?? 9.145;
                        final lng = (loc['longitude'] as num?)?.toDouble() ?? 39.5;
                        final crop = (loc['primaryCrop'] as String?) ?? 'Crop';

                        return Marker(
                          point: LatLng(lat, lng),
                          width: 80,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => _showMarkerDetails(loc),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: Text(
                                    crop,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_pin,
                                  color: AppColors.error,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_locations.length} registered farms plotted across Ethiopian regions',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Text(
                  'Tap markers for details',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
