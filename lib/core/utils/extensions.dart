import 'package:intl/intl.dart';

extension StringExtensions on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

extension DoubleExtensions on double {
  String get toCurrencyString {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }
}

extension DateTimeExtensions on DateTime {
  String get toDisplayDate {
    return DateFormat('MMM d, yyyy').format(this);
  }

  String get toOrderId {
    final timestamp = millisecondsSinceEpoch.toString();
    final shortTimestamp = timestamp.substring(timestamp.length - 6);
    return 'LX-$shortTimestamp';
  }
}

extension IntExtensions on int {
  String get toStockStatus {
    const lowStockThreshold = 5;
    if (this <= 0) {
      return 'OUT OF STOCK';
    } else if (this <= lowStockThreshold) {
      return 'LOW STOCK';
    } else {
      return 'IN STOCK';
    }
  }
}
