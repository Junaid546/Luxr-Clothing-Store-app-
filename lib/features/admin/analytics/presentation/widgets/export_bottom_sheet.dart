import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stylecart/app/theme/app_colors.dart';
import 'package:stylecart/app/theme/app_text_styles.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/utils/extensions.dart';
import 'package:stylecart/features/admin/analytics/data/services/analytics_cache_service.dart';
import 'package:stylecart/features/admin/analytics/data/services/report_export_service.dart';
import 'package:stylecart/features/admin/analytics/domain/models/analytics_models.dart';

// ══════════════════════════════════════════════════════
// EXPORT BOTTOM SHEET
// Shown when the user taps the download icon in the
// Analytics App Bar. Provides CSV, PDF, and Snapshot
// export options with loading states and error feedback.
// ══════════════════════════════════════════════════════

class ExportBottomSheet extends ConsumerStatefulWidget {
  final AnalyticsReport report;
  const ExportBottomSheet({required this.report, super.key});

  @override
  ConsumerState<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends ConsumerState<ExportBottomSheet> {
  bool _isExportingCSV = false;
  bool _isExportingPDF = false;
  bool _isSavingSnapshot = false;

  // ── Export CSV ─────────────────────────────────────
  Future<void> _exportCSV() async {
    setState(() => _isExportingCSV = true);
    final result =
        await ref.read(reportExportServiceProvider).exportToCSV(widget.report);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        setState(() => _isExportingCSV = false);
        _showError(failure.message);
      },
      (String path) {
        setState(() => _isExportingCSV = false);
        ref.read(reportExportServiceProvider).shareFile(
              path,
              'StyleCart Analytics — ${widget.report.dateRange.displayLabel}',
            );
      },
    );
  }

  // ── Export PDF ─────────────────────────────────────
  Future<void> _exportPDF() async {
    setState(() => _isExportingPDF = true);
    final result =
        await ref.read(reportExportServiceProvider).exportToPDF(widget.report);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        setState(() => _isExportingPDF = false);
        _showError(failure.message);
      },
      (String path) {
        setState(() => _isExportingPDF = false);
        ref.read(reportExportServiceProvider).shareFile(
              path,
              'StyleCart Report PDF — ${widget.report.dateRange.displayLabel}',
            );
      },
    );
  }

  // ── Save daily snapshot ────────────────────────────
  Future<void> _saveSnapshot() async {
    setState(() => _isSavingSnapshot = true);
    try {
      await ref
          .read(analyticsCacheServiceProvider)
          .writeDailySnapshot(DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Snapshot saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Snapshot failed: $e');
    } finally {
      if (mounted) setState(() => _isSavingSnapshot = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Export Report',
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            report.dateRange.displayLabel,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),

          // Summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _SummaryRow('Period', report.period.toUpperCase()),
                _SummaryRow(
                    'Revenue', report.revenue.totalRevenue.toCurrencyString),
                _SummaryRow('Orders', '${report.orders.totalOrders}'),
                _SummaryRow(
                  'Generated',
                  DateFormat('MMM dd, HH:mm').format(report.generatedAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Export options
          _ExportOption(
            icon: Icons.table_chart_outlined,
            title: 'Export as CSV',
            subtitle: 'Spreadsheet-friendly format (7 sections)',
            color: AppColors.success,
            isLoading: _isExportingCSV,
            onTap: _exportCSV,
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Export as PDF',
            subtitle: 'Formatted report document (2 pages)',
            color: AppColors.primary,
            isLoading: _isExportingPDF,
            onTap: _exportPDF,
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.save_outlined,
            title: 'Save Daily Snapshot',
            subtitle: "Cache today's data to Firestore",
            color: AppColors.gold,
            isLoading: _isSavingSnapshot,
            onTap: _saveSnapshot,
          ),
        ],
      ),
    );
  }
}

// ── Summary row widget ─────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// ── Export option tile ─────────────────────────────────
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Disabled during export to prevent double-tap
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: color,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white)),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
