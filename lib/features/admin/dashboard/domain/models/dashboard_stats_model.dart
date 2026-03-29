import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class DashboardStats extends Equatable {

  const DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.newClients,
    required this.totalClients,
    required this.conversionRate,
    required this.revenueChange,
    required this.ordersChange,
    required this.clientsChange,
    required this.conversionChange,
  });
  final double totalRevenue;
  final int totalOrders;
  final int newClients;
  final int totalClients;
  final double conversionRate;
  final double revenueChange;
  final double ordersChange;
  final double clientsChange;
  final double conversionChange;

  bool get isRevenueUp => revenueChange >= 0;
  bool get isOrdersUp => ordersChange >= 0;
  bool get isClientsUp => clientsChange >= 0;
  bool get isConversionUp => conversionChange >= 0;

  static const DashboardStats empty = DashboardStats(
    totalRevenue: 0,
    totalOrders: 0,
    newClients: 0,
    totalClients: 0,
    conversionRate: 0,
    revenueChange: 0,
    ordersChange: 0,
    clientsChange: 0,
    conversionChange: 0,
  );

  @override
  List<Object> get props => [
        totalRevenue,
        totalOrders,
        newClients,
        totalClients,
        conversionRate,
        revenueChange,
        ordersChange,
        clientsChange,
        conversionChange,
      ];
}

class WeeklyRevenueData extends Equatable {

  const WeeklyRevenueData({required this.days});
  final List<DailyRevenue> days;

  double get total => days.fold(0.0, (sum, d) => sum + d.revenue);

  double get maxRevenue =>
      days.fold(0.0, (max, d) => d.revenue > max ? d.revenue : max);

  @override
  List<Object> get props => [days];
}

class DailyRevenue extends Equatable {

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });
  final DateTime date;
  final double revenue;
  final int orderCount;

  String get dayLabel => DateFormat('EEE').format(date).toUpperCase();

  @override
  List<Object> get props => [date, revenue, orderCount];
}

class ActivityItem extends Equatable {

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp, this.amount,
    this.orderId,
    this.userId,
  });
  final String type; // 'order' | 'customer'
  final String title;
  final String subtitle;
  final double? amount;
  final DateTime timestamp;
  final String? orderId;
  final String? userId;

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(timestamp);
  }

  @override
  List<Object?> get props => [
        type,
        title,
        subtitle,
        amount,
        timestamp,
        orderId,
        userId,
      ];
}
