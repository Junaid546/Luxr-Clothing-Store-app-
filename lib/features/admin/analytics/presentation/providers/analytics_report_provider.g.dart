// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsReportHash() => r'1be10aafe68d7744a47c886ed35e26d5f922f86d';

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
String _$comparisonMetricsHash() => r'6d8b9a42cd06a684d5c9ce6fec5c7bf6a54557cc';

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
typedef ComparisonMetricsRef =
    AutoDisposeFutureProviderRef<List<ComparisonMetric>>;
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
