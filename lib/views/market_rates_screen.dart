import 'package:flutter/material.dart';

import 'package:dashboard_screen/models/market_rate_model.dart';
import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class MarketRatesScreen extends StatefulWidget {
  const MarketRatesScreen({super.key});

  @override
  State<MarketRatesScreen> createState() => _MarketRatesScreenState();
}

class _MarketRatesScreenState extends State<MarketRatesScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  String selectedRegion = 'All';
  late Future<List<MarketRateModel>> _ratesFuture;

  final List<String> regions = const [
    'All',
    'Punjab',
    'Sindh',
    'Balochistan',
    'KPK',
    'Lahore',
    'Faisalabad',
    'Multan',
    'Karachi',
    'Sahiwal',
    'Bahawalpur',
    'Rawalpindi',
  ];

  @override
  void initState() {
    super.initState();
    _ratesFuture = apiService.fetchMarketRates();
  }

Future<void> _refreshRates() async {
  setState(() {
    _ratesFuture = apiService.fetchMarketRates(
      crop: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      region: selectedRegion == 'All' ? null : selectedRegion,
    );
  });

  await _ratesFuture;
}

  List<MarketRateModel> _filterLocal(List<MarketRateModel> rates) {
  final query = _searchController.text.trim().toLowerCase();

  return rates.where((rate) {
    final cropName = rate.cropName.toLowerCase();
    final cropNameUr = rate.cropNameUr.toLowerCase();
    final mandiName = rate.mandiName.toLowerCase();
    final region = rate.region.toLowerCase();

    final matchRegion = selectedRegion == 'All' ||
        region.contains(selectedRegion.toLowerCase()) ||
        mandiName.contains(selectedRegion.toLowerCase());

    final matchSearch = query.isEmpty ||
        cropName.contains(query) ||
        cropNameUr.contains(query) ||
        mandiName.contains(query) ||
        region.contains(query);

    return matchRegion && matchSearch;
  }).toList();
}

  Color _changeColor(MarketRateModel rate) {
    if (rate.isUp) return Colors.green;
    if (rate.isDown) return Colors.red;
    return Colors.grey;
  }

  IconData _changeIcon(MarketRateModel rate) {
    if (rate.isUp) return Icons.arrow_upward;
    if (rate.isDown) return Icons.arrow_downward;
    return Icons.remove;
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = regions[index];
          final selected = selectedRegion == label;

          return ChoiceChip(
            label: Text(label),
            selected: selected,
           onSelected: (_) {
  setState(() {
    selectedRegion = label;
  });

  _refreshRates();
},
            selectedColor: AppConstants.secondaryGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppConstants.primaryGreen,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
            side: BorderSide(
              color: selected
                  ? AppConstants.secondaryGreen
                  : AppConstants.primaryGreen.withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _refreshRates(),
        decoration: InputDecoration(
          hintText: 'Search crop, mandi, or region...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                 onPressed: () {
                _refreshRates();
                 },
                )
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRateCard(MarketRateModel rate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppConstants.primaryGreen.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                child: const Icon(
                  Icons.grass,
                  color: AppConstants.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.cropName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    if (rate.cropNameUr.isNotEmpty)
                      Text(
                        rate.cropNameUr,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _changeColor(rate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _changeIcon(rate),
                      size: 14,
                      color: _changeColor(rate),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rate.displayChange,
                      style: TextStyle(
                        color: _changeColor(rate),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  icon: Icons.storefront,
                  label: 'Mandi',
                  value: rate.mandiName,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Region',
                  value: rate.region,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  'PKR ',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  rate.displayPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '/ ${rate.unit}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (rate.dateRecorded.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'Updated: ${rate.dateRecorded}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.secondaryGreen, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<MarketRateModel>>(
      future: _ratesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Expanded(
            child: _emptyState(
              icon: Icons.cloud_off,
              title: 'Unable to load market rates',
              subtitle: 'Please check your internet connection.',
            ),
          );
        }

        final allRates = snapshot.data ?? [];
        final displayedRates = _filterLocal(allRates);

        if (allRates.isEmpty) {
          return Expanded(
            child: _emptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No market rates found',
              subtitle: 'Rates added from admin panel will appear here.',
            ),
          );
        }

        if (displayedRates.isEmpty) {
          return Expanded(
            child: _emptyState(
              icon: Icons.search_off,
              title: 'No matching rates',
              subtitle: 'Try another crop, mandi, or region.',
            ),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            color: AppConstants.primaryGreen,
            onRefresh: _refreshRates,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: displayedRates.length,
              itemBuilder: (context, index) {
                return _buildRateCard(displayedRates[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppConstants.primaryGreen.withOpacity(0.35)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
               _refreshRates();
               },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text(
          'Mandi Rates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          _buildFilterChips(),
          const SizedBox(height: 6),
          _buildBody(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}