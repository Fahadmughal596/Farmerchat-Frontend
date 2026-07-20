class MarketRateModel {
  final int id;
  final String cropName;
  final String cropNameUr;
  final String mandiName;
  final String region;
  final String price;
  final String unit;
  final String priceChange;
  final String direction;
  final String status;
  final String dateRecorded;

  const MarketRateModel({
    required this.id,
    required this.cropName,
    required this.cropNameUr,
    required this.mandiName,
    required this.region,
    required this.price,
    required this.unit,
    required this.priceChange,
    required this.direction,
    required this.status,
    required this.dateRecorded,
  });

  factory MarketRateModel.fromJson(Map<String, dynamic> json) {
    return MarketRateModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      cropName: json['crop_name']?.toString().trim() ?? '',
      cropNameUr: json['crop_name_ur']?.toString().trim() ?? '',
      mandiName: json['mandi_name']?.toString().trim() ?? '',
      region: json['region']?.toString().trim() ?? '',
      price: json['price']?.toString().trim() ?? '0',
      unit: json['unit']?.toString().trim() ?? '40kg',
      priceChange:
          json['price_change']?.toString().trim() ??
          json['change_percent']?.toString().trim() ??
          '0',
      direction: json['direction']?.toString().trim().toLowerCase() ??
          'neutral',
      status:
          json['status']?.toString().trim().toLowerCase() ?? 'published',
      dateRecorded: json['date_recorded']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_name': cropName,
      'crop_name_ur': cropNameUr,
      'mandi_name': mandiName,
      'region': region,
      'price': price,
      'unit': unit,
      'price_change': priceChange,
      'direction': direction,
      'status': status,
      'date_recorded': dateRecorded,
    };
  }

  String get displayPrice {
    final value = double.tryParse(price);
    if (value == null) return price;
    return value.toStringAsFixed(0);
  }

  String get displayChange {
    final value = double.tryParse(priceChange) ?? 0;

    if (value == 0) {
      return '0.00%';
    }

    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  bool get isUp => direction == 'up';

  bool get isDown => direction == 'down';

  bool get isNeutral =>
      direction == 'neutral' || (!isUp && !isDown);

  double get priceValue =>
      double.tryParse(price) ?? 0;

  double get changeValue =>
      double.tryParse(priceChange) ?? 0;
}