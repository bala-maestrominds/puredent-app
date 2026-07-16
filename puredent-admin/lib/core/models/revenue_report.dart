class PaymentMethodShare {
  final String method;
  final num amount;
  final double percent;

  const PaymentMethodShare({required this.method, required this.amount, required this.percent});

  factory PaymentMethodShare.fromJson(Map<String, dynamic> json) => PaymentMethodShare(
        method: json['method'] ?? 'Other',
        amount: (json['amount'] as num?) ?? 0,
        percent: (json['percent'] as num?)?.toDouble() ?? 0,
      );
}

class ServiceRevenue {
  final String name;
  final num amount;

  const ServiceRevenue({required this.name, required this.amount});

  factory ServiceRevenue.fromJson(Map<String, dynamic> json) => ServiceRevenue(
        name: json['name'] ?? 'Unknown',
        amount: (json['amount'] as num?) ?? 0,
      );
}

/// One row of "this service, done by this doctor, earned this much".
class RevenueBreakdownItem {
  final String serviceName;
  final String doctorName;
  final num amount;
  final int visits;

  const RevenueBreakdownItem({
    required this.serviceName,
    required this.doctorName,
    required this.amount,
    required this.visits,
  });

  factory RevenueBreakdownItem.fromJson(Map<String, dynamic> json) => RevenueBreakdownItem(
        serviceName: json['serviceName'] ?? 'Unknown',
        doctorName: json['doctorName'] ?? 'Unknown',
        amount: (json['amount'] as num?) ?? 0,
        visits: (json['visits'] as num?)?.toInt() ?? 0,
      );
}

/// One row of "how many bookings chose Full Payment vs Consultation Fee
/// Only, how much has been collected from each, and how much is still owed".
class PaymentOptionBreakdown {
  final String option;
  final int count;
  final num collected;
  final num outstanding;

  const PaymentOptionBreakdown({
    required this.option,
    required this.count,
    required this.collected,
    required this.outstanding,
  });

  factory PaymentOptionBreakdown.fromJson(Map<String, dynamic> json) => PaymentOptionBreakdown(
        option: json['option'] ?? 'Full Payment',
        count: (json['count'] as num?)?.toInt() ?? 0,
        collected: (json['collected'] as num?) ?? 0,
        outstanding: (json['outstanding'] as num?) ?? 0,
      );
}

class RevenueReport {
  final String period;
  final List<double> values;
  final List<String> labels;
  final double total;
  final double previousTotal;
  final double outstandingBalance;
  final List<PaymentMethodShare> paymentMethods;
  final List<ServiceRevenue> topServices;
  final List<RevenueBreakdownItem> breakdown;
  final List<PaymentOptionBreakdown> paymentOptions;

  const RevenueReport({
    required this.period,
    required this.values,
    required this.labels,
    required this.total,
    required this.previousTotal,
    required this.outstandingBalance,
    required this.paymentMethods,
    required this.topServices,
    required this.breakdown,
    required this.paymentOptions,
  });

  double get average => values.isEmpty ? 0 : total / values.length;
  double get maxValue => values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  String get maxLabel {
    if (values.isEmpty) return '';
    final idx = values.indexOf(maxValue);
    return idx >= 0 && idx < labels.length ? labels[idx] : '';
  }

  double get percentChange => previousTotal == 0 ? (total > 0 ? 100 : 0) : ((total - previousTotal) / previousTotal) * 100;

  factory RevenueReport.fromJson(Map<String, dynamic> json) => RevenueReport(
        period: json['period'] ?? 'week',
        values: (json['values'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? const [],
        labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        total: (json['total'] as num?)?.toDouble() ?? 0,
        previousTotal: (json['previousTotal'] as num?)?.toDouble() ?? 0,
        outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble() ?? 0,
        paymentMethods: (json['paymentMethods'] as List?)
                ?.map((e) => PaymentMethodShare.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        topServices: (json['topServices'] as List?)
                ?.map((e) => ServiceRevenue.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        breakdown: (json['breakdown'] as List?)
                ?.map((e) => RevenueBreakdownItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        paymentOptions: (json['paymentOptions'] as List?)
                ?.map((e) => PaymentOptionBreakdown.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
