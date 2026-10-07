class SubscriptionPlanModel {
  final int id;
  final String name;
  final String? description;
  final int? monthlyPrice;
  final int? quarterlyPrice;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    this.description,
    this.monthlyPrice,
    this.quarterlyPrice,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] ?? '',
      description: json['description'],
      monthlyPrice: (json['monthlyPrice'] as num?)?.toInt(),
      quarterlyPrice: (json['quarterlyPrice'] as num?)?.toInt(),
    );
  }

  int? priceFor(int months) => months == 3 ? quarterlyPrice : monthlyPrice;
}

class PaymentOrderModel {
  final int? orderId;
  final int durationMonths;
  final int baseAmountInSom;
  final int commissionInSom;
  final int amountInSom;
  final String? payUrl;

  PaymentOrderModel({
    this.orderId,
    required this.durationMonths,
    required this.baseAmountInSom,
    required this.commissionInSom,
    required this.amountInSom,
    this.payUrl,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    int n(String k) => (json[k] as num?)?.toInt() ?? 0;
    return PaymentOrderModel(
      orderId: (json['orderId'] as num?)?.toInt(),
      durationMonths: n('durationMonths'),
      baseAmountInSom: n('baseAmountInSom'),
      commissionInSom: n('commissionInSom'),
      amountInSom: n('amountInSom'),
      payUrl: json['payUrl'],
    );
  }
}

class MySubscriptionModel {
  final bool active;
  final DateTime? endDate;
  final int daysLeft;
  final List<SeriesAccessModel> series;

  MySubscriptionModel({required this.active, this.endDate, this.daysLeft = 0, this.series = const []});

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      active: json['active'] ?? false,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
      series: json['series'] != null
          ? (json['series'] as List).map((e) => SeriesAccessModel.fromJson(e)).toList()
          : const [],
    );
  }

  bool get hasAnything => active || series.isNotEmpty;
}

class SeriesAccessModel {
  final int seriesId;
  final String title;
  final String? imagePath;
  final DateTime? endDate;
  final int daysLeft;

  SeriesAccessModel({required this.seriesId, required this.title, this.imagePath, this.endDate, this.daysLeft = 0});

  factory SeriesAccessModel.fromJson(Map<String, dynamic> json) {
    return SeriesAccessModel(
      seriesId: (json['seriesId'] as num).toInt(),
      title: (json['title'] as String?)?.trim() ?? '',
      imagePath: json['imagePath'],
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
    );
  }
}
