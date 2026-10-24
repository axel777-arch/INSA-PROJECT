import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class EthiopianLocation {
  final String region;
  final String zone;
  final String woreda;
  final String kebele;

  const EthiopianLocation({
    required this.region,
    required this.zone,
    required this.woreda,
    required this.kebele,
  });

  bool get isValid =>
      region.trim().isNotEmpty &&
      zone.trim().isNotEmpty &&
      woreda.trim().isNotEmpty &&
      kebele.trim().isNotEmpty;

  @override
  String toString() => '$region, $zone, $woreda, $kebele';
}

/// Comprehensive Ethiopian Administrative Location Hierarchy Data
const Map<String, Map<String, Map<String, List<String>>>>
kEthiopianAdministrativeHierarchy = {
  'Oromia': {
    'East Shewa': {
      'Ada\'a': ['Ude', 'Denkaka', 'Dukem Rural', 'Hidi', '01'],
      'Boset': ['Bofa', 'Doni', 'Sara Webe', '01'],
      'Dugda': ['Meki 01', 'Meki 02', 'Tepho Choroke', 'Shubi Gamo'],
      'Lome': ['Mojo 01', 'Koka Negwo', 'Ejersa'],
      'Fantale': ['Metehara 01', 'Gara Dima', 'Gelcha'],
    },
    'Jimma': {
      'Gomma': ['Agaro 01', 'Choche', 'Gembe', 'Beshasha'],
      'Mana': ['Yebu', 'Doyo Bikila', 'Gudeta'],
      'Kersa': ['Serbo', 'Tikur Balto', 'Babia'],
      'Seka Chekorsa': ['Seka 01', 'Allo', 'Buyo Kebele'],
    },
    'West Arsi': {
      'Shashemene': ['Kuyera', 'Alelu', 'Fajji Sole', '01'],
      'Arsi Negele': ['Mudi Arsi', 'Golle', 'Ali Wayo', '01'],
      'Kofele': ['Kofele 01', 'Worena', 'Guramba'],
    },
    'Arsi': {
      'Tiyo': ['Asella 01', 'Dosha', 'Chilalo'],
      'Hetosa': ['Iteya', 'Boru Jawi', 'Gonde'],
      'Digelu and Tijo': ['Sagure', 'Digelu', 'Shirka'],
    },
  },
  'Amhara': {
    'South Gondar': {
      'Fogera': ['Woreta 01', 'Woreta 02', 'Kuhar Michael', 'Alember'],
      'Dera': ['Anbesame', 'Hamusit', 'Korata'],
      'Libo Kemkem': ['Addis Zemen', 'Bura', 'Estie'],
    },
    'West Gojjam': {
      'Bahir Dar Zuria': ['Tis Abay', 'Zenzelma', 'Robit', 'Sebatamit'],
      'Mecha': ['Merawi', 'Kudmi', 'Kurt Bahir'],
      'Yilmana Densa': ['Adet', 'Goshye', 'Debre Mewi'],
    },
    'East Gojjam': {
      'Dejen': ['Dejen 01', 'Tik', 'Kurar'],
      'Enemay': ['Bichena', 'Dima', 'Debre Work'],
      'Machakel': ['Amanuel', 'Debre Kelem'],
    },
    'North Shewa': {
      'Basona Werana': ['Debre Birhan Zuria', 'Goshe Bado', 'Bakello'],
      'Ankober': ['Gorebela', 'Aliyu Amba', 'Haramba'],
      'Moretna Jiru': ['Enewari', 'Jiru Central'],
    },
  },
  'Sidama': {
    'Central Sidama': {
      'Hawassa Zuria': ['Dore Bafeno', 'Galanba', 'Chebi', 'Shamena'],
      'Dale': ['Yirgalem', 'Wara', 'Soyama'],
      'Wonsho': ['Bokasso', 'Hantate', 'Chiricho'],
    },
    'South Sidama': {
      'Aleta Wondo': ['Wondo 01', 'Dama', 'Bulle'],
      'Dara': ['Kebado', 'Teferikela', 'Garanba'],
      'Chuko': ['Chuko 01', 'Raro', 'Wotera'],
    },
  },
  'Central Ethiopia / SNNPR': {
    'Gurage': {
      'Cheha': ['Emdibir', 'Yebessan', 'Dakuna'],
      'Meskan': ['Butajira', 'Enseno', 'Dobena'],
      'Enemorina Ener': ['Gunchire', 'Ener Central'],
    },
    'Wolayita': {
      'Sodo Zuria': ['Sodo 01', 'Dalbo', 'Waja'],
      'Boloso Sore': ['Areka', 'Achura', 'Yukara'],
      'Damot Gale': ['Boditi', 'Fate', 'Abeche'],
    },
    'Silte': {
      'Worabe': ['Worabe 01', 'Alicho', 'Dalocha'],
      'Sankurra': ['Alem Gebeya', 'Toga'],
    },
  },
  'Tigray': {
    'Central Tigray': {
      'Axum': ['Axum 01', 'Hawelti', 'Yeha'],
      'Adwa': ['Adwa 01', 'Abba Gerima', 'Soloda'],
      'Kola Tembien': ['Abi Addi', 'Werkamba'],
    },
    'Southern Tigray': {
      'Raya Azebo': ['Mehoni', 'Chercher', 'Bala'],
      'Endamehoni': ['Maychew', 'Mekhan'],
      'Ofla': ['Korem', 'Hashenge'],
    },
  },
  'Somali': {
    'Fafan': {
      'Jijiga': ['Jijiga 01', 'Dudumad', 'Harawo'],
      'Kebribeyah': ['Kebribeyah 01', 'Hartsheikh'],
      'Awbare': ['Awbare 01', 'Cammod'],
    },
  },
  'Benishangul-Gumuz': {
    'Assosa': {
      'Assosa': ['Assosa 01', 'Amba 02', 'Ura'],
      'Bambasi': ['Bambasi 01', 'Keshmando'],
      'Homosha': ['Homosha 01', 'Dabus'],
    },
  },
};

const String kCustomOption = 'Other / Unlisted...';

class EthiopianLocationSelector extends StatefulWidget {
  final String? initialRegion;
  final String? initialZone;
  final String? initialWoreda;
  final String? initialKebele;
  final ValueChanged<EthiopianLocation> onChanged;
  final bool showHeader;

  const EthiopianLocationSelector({
    super.key,
    this.initialRegion,
    this.initialZone,
    this.initialWoreda,
    this.initialKebele,
    required this.onChanged,
    this.showHeader = true,
  });

  @override
  State<EthiopianLocationSelector> createState() =>
      _EthiopianLocationSelectorState();
}

class _EthiopianLocationSelectorState extends State<EthiopianLocationSelector> {
  late String? _selectedRegion;
  late String? _selectedZone;
  late String? _selectedWoreda;
  late String? _selectedKebele;

  bool _isManualCustom = false;
  final _customRegionCtrl = TextEditingController();
  final _customZoneCtrl = TextEditingController();
  final _customWoredaCtrl = TextEditingController();
  final _customKebeleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialRegion;
    _selectedZone = widget.initialZone;
    _selectedWoreda = widget.initialWoreda;
    _selectedKebele = widget.initialKebele;

    // Check if initial values match preset
    if (_selectedRegion != null &&
        !kEthiopianAdministrativeHierarchy.containsKey(_selectedRegion)) {
      _isManualCustom = true;
      _customRegionCtrl.text = _selectedRegion!;
      _customZoneCtrl.text = _selectedZone ?? '';
      _customWoredaCtrl.text = _selectedWoreda ?? '';
      _customKebeleCtrl.text = _selectedKebele ?? '';
    }
  }

  @override
  void dispose() {
    _customRegionCtrl.dispose();
    _customZoneCtrl.dispose();
    _customWoredaCtrl.dispose();
    _customKebeleCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    if (_isManualCustom) {
      widget.onChanged(
        EthiopianLocation(
          region: _customRegionCtrl.text.trim(),
          zone: _customZoneCtrl.text.trim(),
          woreda: _customWoredaCtrl.text.trim(),
          kebele: _customKebeleCtrl.text.trim(),
        ),
      );
    } else {
      final region = _selectedRegion == kCustomOption
          ? _customRegionCtrl.text.trim()
          : (_selectedRegion ?? '');
      final zone = _selectedZone == kCustomOption
          ? _customZoneCtrl.text.trim()
          : (_selectedZone ?? '');
      final woreda = _selectedWoreda == kCustomOption
          ? _customWoredaCtrl.text.trim()
          : (_selectedWoreda ?? '');
      final kebele = _selectedKebele == kCustomOption
          ? _customKebeleCtrl.text.trim()
          : (_selectedKebele ?? '');

      widget.onChanged(
        EthiopianLocation(
          region: region,
          zone: zone,
          woreda: woreda,
          kebele: kebele,
        ),
      );
    }
  }

  List<String> get _regionList => [
    ...kEthiopianAdministrativeHierarchy.keys,
    kCustomOption,
  ];

  List<String> get _zoneList {
    if (_selectedRegion == null || _selectedRegion == kCustomOption)
      return [kCustomOption];
    final zones =
        kEthiopianAdministrativeHierarchy[_selectedRegion]?.keys.toList() ?? [];
    return [...zones, kCustomOption];
  }

  List<String> get _woredaList {
    if (_selectedRegion == null ||
        _selectedZone == null ||
        _selectedRegion == kCustomOption ||
        _selectedZone == kCustomOption) {
      return [kCustomOption];
    }
    final woredas =
        kEthiopianAdministrativeHierarchy[_selectedRegion]?[_selectedZone]?.keys
            .toList() ??
        [];
    return [...woredas, kCustomOption];
  }

  List<String> get _kebeleList {
    if (_selectedRegion == null ||
        _selectedZone == null ||
        _selectedWoreda == null ||
        _selectedRegion == kCustomOption ||
        _selectedZone == kCustomOption ||
        _selectedWoreda == kCustomOption) {
      return [kCustomOption];
    }
    final kebeles =
        kEthiopianAdministrativeHierarchy[_selectedRegion]?[_selectedZone]?[_selectedWoreda] ??
        [];
    return [...kebeles, kCustomOption];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ethiopian Administrative Location',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isManualCustom = !_isManualCustom;
                    if (_isManualCustom) {
                      _customRegionCtrl.text = _selectedRegion ?? '';
                      _customZoneCtrl.text = _selectedZone ?? '';
                      _customWoredaCtrl.text = _selectedWoreda ?? '';
                      _customKebeleCtrl.text = _selectedKebele ?? '';
                    }
                  });
                  _notifyChange();
                },
                icon: Icon(
                  _isManualCustom
                      ? Icons.account_tree_outlined
                      : Icons.edit_note_rounded,
                  size: 16,
                ),
                label: Text(
                  _isManualCustom ? 'Use Cascade Selector' : 'Manual Entry',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
        ],

        if (_isManualCustom) ...[
          TextFormField(
            controller: _customRegionCtrl,
            decoration: const InputDecoration(
              labelText: 'Region *',
              prefixIcon: Icon(Icons.public_outlined),
              hintText: 'e.g., Oromia, Amhara, Sidama',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Region is required' : null,
            onChanged: (_) => _notifyChange(),
          ),
          const SizedBox(height: AppSizes.p12),
          TextFormField(
            controller: _customZoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Zone *',
              prefixIcon: Icon(Icons.explore_outlined),
              hintText: 'e.g., East Shewa, South Gondar',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Zone is required' : null,
            onChanged: (_) => _notifyChange(),
          ),
          const SizedBox(height: AppSizes.p12),
          TextFormField(
            controller: _customWoredaCtrl,
            decoration: const InputDecoration(
              labelText: 'Woreda *',
              prefixIcon: Icon(Icons.location_city_outlined),
              hintText: 'e.g., Ada\'a, Fogera, Hawassa Zuria',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Woreda is required' : null,
            onChanged: (_) => _notifyChange(),
          ),
          const SizedBox(height: AppSizes.p12),
          TextFormField(
            controller: _customKebeleCtrl,
            decoration: const InputDecoration(
              labelText: 'Kebele *',
              prefixIcon: Icon(Icons.home_outlined),
              hintText: 'e.g., 01, Ude, Tis Abay',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Kebele is required' : null,
            onChanged: (_) => _notifyChange(),
          ),
        ] else ...[
          // Region Dropdown
          DropdownButtonFormField<String>(
            initialValue: _regionList.contains(_selectedRegion)
                ? _selectedRegion
                : null,
            decoration: const InputDecoration(
              labelText: 'Region *',
              prefixIcon: Icon(Icons.public_outlined),
            ),
            items: _regionList
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedRegion = val;
                _selectedZone = null;
                _selectedWoreda = null;
                _selectedKebele = null;
              });
              _notifyChange();
            },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please select a Region' : null,
          ),
          if (_selectedRegion == kCustomOption) ...[
            const SizedBox(height: AppSizes.p8),
            TextFormField(
              controller: _customRegionCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Region *',
                hintText: 'Type custom region name',
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
          const SizedBox(height: AppSizes.p12),

          // Zone Dropdown
          DropdownButtonFormField<String>(
            initialValue: _zoneList.contains(_selectedZone)
                ? _selectedZone
                : null,
            decoration: const InputDecoration(
              labelText: 'Zone *',
              prefixIcon: Icon(Icons.explore_outlined),
            ),
            items: _zoneList
                .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                .toList(),
            onChanged: _selectedRegion == null
                ? null
                : (val) {
                    setState(() {
                      _selectedZone = val;
                      _selectedWoreda = null;
                      _selectedKebele = null;
                    });
                    _notifyChange();
                  },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please select a Zone' : null,
          ),
          if (_selectedZone == kCustomOption) ...[
            const SizedBox(height: AppSizes.p8),
            TextFormField(
              controller: _customZoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Zone *',
                hintText: 'Type custom zone name',
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
          const SizedBox(height: AppSizes.p12),

          // Woreda Dropdown
          DropdownButtonFormField<String>(
            initialValue: _woredaList.contains(_selectedWoreda)
                ? _selectedWoreda
                : null,
            decoration: const InputDecoration(
              labelText: 'Woreda *',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            items: _woredaList
                .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                .toList(),
            onChanged: _selectedZone == null
                ? null
                : (val) {
                    setState(() {
                      _selectedWoreda = val;
                      _selectedKebele = null;
                    });
                    _notifyChange();
                  },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please select a Woreda' : null,
          ),
          if (_selectedWoreda == kCustomOption) ...[
            const SizedBox(height: AppSizes.p8),
            TextFormField(
              controller: _customWoredaCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Woreda *',
                hintText: 'Type custom woreda name',
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
          const SizedBox(height: AppSizes.p12),

          // Kebele Dropdown
          DropdownButtonFormField<String>(
            initialValue: _kebeleList.contains(_selectedKebele)
                ? _selectedKebele
                : null,
            decoration: const InputDecoration(
              labelText: 'Kebele *',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            items: _kebeleList
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: _selectedWoreda == null
                ? null
                : (val) {
                    setState(() {
                      _selectedKebele = val;
                    });
                    _notifyChange();
                  },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please select a Kebele' : null,
          ),
          if (_selectedKebele == kCustomOption) ...[
            const SizedBox(height: AppSizes.p8),
            TextFormField(
              controller: _customKebeleCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Kebele *',
                hintText: 'Type custom kebele name or number',
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
        ],
      ],
    );
  }
}
