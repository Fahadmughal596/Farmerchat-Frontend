import 'package:flutter/material.dart';

import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class GovtSchemeScreen extends StatefulWidget {
  const GovtSchemeScreen({super.key});

  @override
  State<GovtSchemeScreen> createState() => _GovtSchemeScreenState();
}

class _GovtSchemeScreenState extends State<GovtSchemeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'All';
  late Future<Map<String, dynamic>> _schemesFuture;

  final List<Map<String, String>> categories = const [
    {'label': 'All', 'value': ''},
    {'label': 'Subsidy', 'value': 'subsidy'},
    {'label': 'Water', 'value': 'water'},
    {'label': 'Insurance', 'value': 'insurance'},
    {'label': 'Training', 'value': 'training'},
    {'label': 'Solar', 'value': 'solar'},
    {'label': 'Equipment', 'value': 'equipment'},
    {'label': 'Seeds', 'value': 'seeds'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

 Future<void> _loadSchemes() async {
  final selected = categories.firstWhere(
    (item) => item['label'] == selectedCategory,
    orElse: () => {'label': 'All', 'value': ''},
  );

  _schemesFuture = _apiService.fetchGovernmentSchemes(
    category: selected['value']!.isEmpty ? null : selected['value'],
    status: 'active',
  );
}

  Future<void> _refreshSchemes() async {
  setState(() {
    _loadSchemes();
  });

  await _schemesFuture;
}

  List<Map<String, dynamic>> _extractSchemes(Map<String, dynamic> response) {
    final rawList = response['schemes'];

    if (rawList is! List) return [];

    final query = _searchController.text.trim().toLowerCase();

    final schemes = rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((scheme) {
         if (scheme.isEmpty) return false;
         if (query.isEmpty) return true;

      final title = scheme['title']?.toString().toLowerCase() ?? '';
      final titleUr = scheme['title_ur']?.toString().toLowerCase() ?? '';
      final desc = scheme['description']?.toString().toLowerCase() ?? '';
      final region = scheme['region']?.toString().toLowerCase() ?? '';
      final category = scheme['category']?.toString().toLowerCase() ?? '';

      return title.contains(query) ||
          titleUr.contains(query) ||
          desc.contains(query) ||
          region.contains(query) ||
          category.contains(query);
    }).toList();

    return schemes;
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'insurance':
        return Icons.security;
      case 'water':
        return Icons.water_drop;
      case 'solar':
        return Icons.wb_sunny;
      case 'equipment':
        return Icons.agriculture;
      case 'training':
        return Icons.school;
      case 'seeds':
        return Icons.eco;
      case 'organic':
        return Icons.spa;
      case 'subsidy':
      default:
        return Icons.account_balance;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'insurance':
        return Colors.blue;
      case 'water':
        return Colors.cyan;
      case 'solar':
        return Colors.orange;
      case 'equipment':
        return Colors.brown;
      case 'training':
        return Colors.teal;
      case 'seeds':
        return Colors.green;
      case 'organic':
        return Colors.lightGreen;
      case 'subsidy':
      default:
        return AppConstants.primaryGreen;
    }
  }

  String _value(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index]['label']!;
          final isSelected = selectedCategory == label;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
           onSelected: (_) {
            setState(() {
            selectedCategory = label;
            });

  _refreshSchemes();
},
            selectedColor: AppConstants.secondaryGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppConstants.primaryGreen,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppConstants.secondaryGreen
                  : AppConstants.primaryGreen.withOpacity(0.18),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search schemes, region, category...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                   _refreshSchemes();
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

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    final title = _value(scheme['title']);
    final titleUr = _value(scheme['title_ur'], fallback: '');
    final desc = _value(scheme['description'], fallback: 'No description available.');
    final eligibility = _value(scheme['eligibility'], fallback: 'Eligibility details not added yet.');
    final benefits = _value(scheme['benefits'], fallback: '');
    final region = _value(
  scheme['region'] ?? scheme['target_region'] ?? '',
  fallback: 'All Regions',
);
    final deadline = _value(scheme['deadline'], fallback: 'Ongoing');
    final status = _value(
  scheme['status'],
  fallback: 'active',
).toLowerCase();
    final category = _value(scheme['category'], fallback: 'subsidy');
    final categoryDisplay = _value(scheme['category_display'], fallback: category);
    final beneficiaries = _value(scheme['beneficiaries'], fallback: '0');

    final color = _categoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  _categoryIcon(category),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    if (titleUr.isNotEmpty)
                      Text(
                        titleUr,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'active' ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor:
                    status == 'active' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              ),
            ],
          ),
          const Divider(height: 26),
          Row(
            children: [
              _smallInfoChip(Icons.category, categoryDisplay),
              const SizedBox(width: 8),
              _smallInfoChip(Icons.location_on_outlined, region),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          if (benefits.isNotEmpty) ...[
            const SizedBox(height: 10),
            _highlightBox(
              title: 'Benefits',
              text: benefits,
              icon: Icons.check_circle_outline,
            ),
          ],
          const SizedBox(height: 10),
          _highlightBox(
            title: 'Eligibility',
            text: eligibility,
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                '$beneficiaries beneficiaries',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                deadline,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfoChip(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppConstants.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppConstants.primaryGreen),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppConstants.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightBox({
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppConstants.secondaryGreen),
          const SizedBox(width: 7),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
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
              textAlign: TextAlign.center,
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
              _refreshSchemes();
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

  Widget _buildBody() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _schemesFuture,
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

        if (snapshot.hasError || !snapshot.hasData) {
          return Expanded(
            child: _emptyState(
              icon: Icons.cloud_off,
              title: 'Unable to load schemes',
              subtitle: 'Please check your internet connection.',
            ),
          );
        }

        final schemes = _extractSchemes(snapshot.data!);

        if (schemes.isEmpty) {
          return Expanded(
            child: _emptyState(
              icon: Icons.account_balance_outlined,
              title: 'No schemes found',
              subtitle: 'Schemes added from admin panel will appear here.',
            ),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            color: AppConstants.primaryGreen,
            onRefresh: _refreshSchemes,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                return _buildSchemeCard(schemes[index]);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text(
          'Government Schemes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
           _refreshSchemes();
           },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          _buildFilterChips(),
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