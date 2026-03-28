// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$latestOrderDateHash() => r'a6af811432eae8b1f0e881096041054b6396491c';

/// See also [latestOrderDate].
@ProviderFor(latestOrderDate)
final latestOrderDateProvider = AutoDisposeStreamProvider<DateTime?>.internal(
  latestOrderDate,
  name: r'latestOrderDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestOrderDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestOrderDateRef = AutoDisposeStreamProviderRef<DateTime?>;
String _$analyticsReportHash() => r'8a17f792bd323340c5a4945a727c5229389f2739';

/// See also [analyticsReport].
@ProviderFor(analyticsReport)
final analyticsReportProvider =
    AutoDisposeFutureProvider<AnalyticsReport>.internal(
  analyticsReport,
  name: r'analyticsReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsReportRef = AutoDisposeFutureProviderRef<AnalyticsReport>;
String _$comparisonMetricsHash() => r'272515b34ed2de2970d9c58ecc0f56acc0e6b2a1';

/// See also [comparisonMetrics].
@ProviderFor(comparisonMetrics)
final comparisonMetricsProvider =
    AutoDisposeFutureProvider<List<ComparisonMetric>>.internal(
  comparisonMetrics,
  name: r'comparisonMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comparisonMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ComparisonMetricsRef
    = AutoDisposeFutureProviderRef<List<ComparisonMetric>>;
String _$analyticsPeriodStateHash() =>
    r'ceae2e6f9c90347dfdd9dec106ed0e6bd1d4a47c';

/// See also [AnalyticsPeriodState].
@ProviderFor(AnalyticsPeriodState)
final analyticsPeriodStateProvider =
    AutoDisposeNotifierProvider<AnalyticsPeriodState, String>.internal(
  AnalyticsPeriodState.new,
  name: r'analyticsPeriodStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsPeriodStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnalyticsPeriodState = AutoDisposeNotifier<String>;
String _$customDateRangeHash() => r'4814ccaed218aa3409d69ffbc35a17e6785b9d77';

/// See also [CustomDateRange].
@ProviderFor(CustomDateRange)
final customDateRangeProvider =
    AutoDisposeNotifierProvider<CustomDateRange, DateRange?>.internal(
  CustomDateRange.new,
  name: r'customDateRangeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customDateRangeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomDateRange = AutoDisposeNotifier<DateRange?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
