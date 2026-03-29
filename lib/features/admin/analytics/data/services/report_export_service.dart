import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/admin/analytics/domain/models/analytics_models.dart';

part 'report_export_service.g.dart';

// ══════════════════════════════════════════════════════
// REPORT EXPORT SERVICE
// Generates downloadable CSV and PDF reports.
// Files are saved to a temp directory then shared via
// the native OS share sheet.
// ══════════════════════════════════════════════════════

class ReportExportService {
  const ReportExportService();

  // ════════════════════════════════════════════════════
  // EXPORT TO CSV
  // Creates a flat multi-section CSV (7 sections)
  // ════════════════════════════════════════════════════
  Future<Either<Failure, String>> exportToCSV(
    AnalyticsReport report,
  ) async {
    try {
      final buffer = StringBuffer();

      // ── Header ───────────────────────────────────
      buffer.writeln('STYLECART ANALYTICS REPORT');
      buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(report.generatedAt)}');
      buffer.writeln('Period: ${report.dateRange.displayLabel}');
      buffer.writeln();

      // ── Section 1: Revenue Summary ───────────────
      buffer.writeln('=== REVENUE SUMMARY ===');
      buffer.writeln('Metric,Value');
      buffer.writeln('Total Revenue,\$${report.revenue.totalRevenue.toStringAsFixed(2)}');
      buffer.writeln('Gross Revenue,\$${report.revenue.grossRevenue.toStringAsFixed(2)}');
      buffer.writeln('Net Revenue,\$${report.revenue.netRevenue.toStringAsFixed(2)}');
      buffer.writeln('Discount Given,\$${report.revenue.discountGiven.toStringAsFixed(2)}');
      buffer.writeln('Shipping Revenue,\$${report.revenue.shippingRevenue.toStringAsFixed(2)}');
      buffer.writeln('Avg Order Value,\$${report.revenue.avgOrderValue.toStringAsFixed(2)}');
      buffer.writeln('Revenue Growth,${report.revenue.revenueGrowthPct.toStringAsFixed(1)}%');
      buffer.writeln('Projected Monthly,\$${report.revenue.projectedMonthly.toStringAsFixed(2)}');
      buffer.writeln();

      // ── Section 2: Order Metrics ─────────────────
      buffer.writeln('=== ORDER METRICS ===');
      buffer.writeln('Metric,Value');
      buffer.writeln('Total Orders,${report.orders.totalOrders}');
      buffer.writeln('Delivered,${report.orders.deliveredOrders}');
      buffer.writeln('Cancelled,${report.orders.cancelledOrders}');
      buffer.writeln('Returned,${report.orders.returnedOrders}');
      buffer.writeln('Pending,${report.orders.pendingOrders}');
      buffer.writeln('Processing,${report.orders.processingOrders}');
      buffer.writeln('Fulfillment Rate,${report.orders.fulfillmentRate.toStringAsFixed(1)}%');
      buffer.writeln('Cancellation Rate,${report.orders.cancellationRate.toStringAsFixed(1)}%');
      buffer.writeln('Refund Rate,${report.orders.refundRate.toStringAsFixed(1)}%');
      buffer.writeln('Avg Delivery Days,${report.orders.avgDeliveryDays}');
      buffer.writeln();

      // ── Section 3: Daily Revenue Time Series ─────
      buffer.writeln('=== DAILY REVENUE ===');
      buffer.writeln('Date,Revenue,Orders');
      for (final point in report.revenueSeries) {
        buffer.writeln(
          '${DateFormat('yyyy-MM-dd').format(point.date)},'
          '${point.value.toStringAsFixed(2)},'
          '${point.count}',
        );
      }
      buffer.writeln();

      // ── Section 4: Category Breakdown ────────────
      buffer.writeln('=== CATEGORY BREAKDOWN ===');
      buffer.writeln('Category,Revenue,Units Sold,Products,Revenue Share');
      for (final cat in report.categoryBreakdown.values) {
        buffer.writeln(
          '${cat.category},'
          '${cat.revenue.toStringAsFixed(2)},'
          '${cat.unitsSold},'
          '${cat.productCount},'
          '${cat.revenueShare.toStringAsFixed(1)}%',
        );
      }
      buffer.writeln();

      // ── Section 5: Top Products ───────────────────
      buffer.writeln('=== TOP PRODUCTS ===');
      buffer.writeln('Rank,Product,Brand,Category,Units Sold,Revenue,Rating,Stock');
      for (var i = 0; i < report.topProducts.length; i++) {
        final p = report.topProducts[i];
        // Wrap name in quotes to handle commas
        buffer.writeln(
          '${i + 1},'
          '"${p.productName}",'
          '"${p.brand}",'
          '${p.category},'
          '${p.unitsSold},'
          '${p.revenue.toStringAsFixed(2)},'
          '${p.avgRating.toStringAsFixed(1)},'
          '${p.currentStock}',
        );
      }
      buffer.writeln();

      // ── Section 6: Top Customers ──────────────────
      buffer.writeln('=== TOP CUSTOMERS ===');
      buffer.writeln('Rank,Name,Email,Total Orders,Total Spent,Elite Status');
      for (var i = 0; i < report.topCustomers.length; i++) {
        final c = report.topCustomers[i];
        buffer.writeln(
          '${i + 1},'
          '"${c.displayName}",'
          '"${c.email}",'
          '${c.totalOrders},'
          '${c.totalSpent.toStringAsFixed(2)},'
          '${c.eliteStatus}',
        );
      }
      buffer.writeln();

      // ── Section 7: Customer Metrics ───────────────
      buffer.writeln('=== CUSTOMER METRICS ===');
      buffer.writeln('Metric,Value');
      buffer.writeln('Total Customers,${report.customers.totalCustomers}');
      buffer.writeln('New Customers,${report.customers.newCustomers}');
      buffer.writeln('Returning Customers,${report.customers.returningCustomers}');
      buffer.writeln('Repeat Purchase Rate,${report.customers.repeatPurchaseRate.toStringAsFixed(1)}%');
      buffer.writeln('Avg Lifetime Value,\$${report.customers.avgLifetimeValue.toStringAsFixed(2)}');
      buffer.writeln('Bronze Members,${report.customers.bronzeCount}');
      buffer.writeln('Silver Members,${report.customers.silverCount}');
      buffer.writeln('Gold Members,${report.customers.goldCount}');
      buffer.writeln('Platinum Members,${report.customers.platinumCount}');

      // Save to temporary directory (per-session path)
      final fileName = 'stylecart_analytics_${DateFormat('yyyy_MM_dd').format(report.generatedAt)}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.csv');
      await file.writeAsString(buffer.toString());

      return Right(file.path);
    } catch (e) {
      return Left(ServerFailure('CSV export failed: $e'));
    }
  }

  // ════════════════════════════════════════════════════
  // EXPORT TO PDF
  // 2-page professional report with header + tables.
  // Uses PdfGoogleFonts (requires internet connection);
  // falls back to built-in font if unavailable.
  // ════════════════════════════════════════════════════
  Future<Either<Failure, String>> exportToPDF(
    AnalyticsReport report,
  ) async {
    try {
      final pdf = pw.Document();
      final now = report.generatedAt;

      // Load fonts — graceful fallback
      pw.Font? baseFont;
      pw.Font? boldFont;
      try {
        baseFont = await PdfGoogleFonts.interRegular();
        boldFont = await PdfGoogleFonts.interBold();
      } catch (_) {
        // If no internet, PdfGoogleFonts throws;
        // pw defaults (Helvetica) will be used instead
        debugPrint('[ReportExport] Google Fonts unavailable, using default');
      }

      final theme = baseFont != null && boldFont != null
          ? pw.ThemeData.withFont(base: baseFont, bold: boldFont)
          : pw.ThemeData();

      // ── Page 1: Cover + Revenue + Category ───────
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
          build: (pw.Context context) => [
            // Header banner
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('0D0D0D'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STYLECART',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('D4AF37'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Analytics Report',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        report.dateRange.displayLabel,
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${DateFormat('MMM dd, yyyy').format(now)}',
                        style: pw.TextStyle(color: PdfColor.fromHex('9E9E9E'), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // KPI Cards (2×2 grid)
            _pdfSectionTitle('REVENUE OVERVIEW'),
            pw.SizedBox(height: 12),
            pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildPDFKPICard('Total Revenue', '\$${report.revenue.totalRevenue.toStringAsFixed(2)}', '${report.revenue.formattedGrowth} vs prev', PdfColor.fromHex('D4AF37')),
                _buildPDFKPICard('Avg Order Value', '\$${report.revenue.avgOrderValue.toStringAsFixed(2)}', '${report.orders.totalOrders} orders', PdfColor.fromHex('E8614A')),
                _buildPDFKPICard('Fulfillment Rate', '${report.orders.fulfillmentRate.toStringAsFixed(1)}%', '${report.orders.deliveredOrders} delivered', PdfColor.fromHex('26C6A6')),
                _buildPDFKPICard('New Customers', '${report.customers.newCustomers}', 'Repeat: ${report.customers.repeatPurchaseRate.toStringAsFixed(1)}%', PdfColor.fromHex('4CAF50')),
              ],
            ),

            pw.SizedBox(height: 24),

            // Daily revenue table
            _pdfSectionTitle('DAILY REVENUE BREAKDOWN'),
            pw.SizedBox(height: 8),
            _buildPDFTable(
              headers: ['Date', 'Revenue', 'Orders'],
              rows: report.revenueSeries
                  .map((p) => [DateFormat('MMM dd').format(p.date), '\$${p.value.toStringAsFixed(2)}', '${p.count}'])
                  .toList(),
            ),

            pw.SizedBox(height: 24),

            // Category table
            _pdfSectionTitle('SALES BY CATEGORY'),
            pw.SizedBox(height: 8),
            _buildPDFTable(
              headers: ['Category', 'Revenue', 'Units', 'Share'],
              rows: report.categoryBreakdown.values
                  .map((c) => [c.category, '\$${c.revenue.toStringAsFixed(2)}', '${c.unitsSold}', '${c.revenueShare.toStringAsFixed(1)}%'])
                  .toList(),
            ),
          ],
        ),
      );

      // ── Page 2: Products + Customers + Footer ────
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
          build: (pw.Context context) => [
            _pdfSectionTitle('TOP PERFORMING PRODUCTS'),
            pw.SizedBox(height: 8),
            _buildPDFTable(
              headers: ['Rank', 'Product', 'Units', 'Revenue', 'Rating', 'Stock'],
              rows: report.topProducts.asMap().entries.map((e) {
                final name = e.value.productName;
                final truncated = name.length > 25 ? '${name.substring(0, 25)}…' : name;
                return [
                  '#${e.key + 1}',
                  truncated,
                  '${e.value.unitsSold}',
                  '\$${e.value.revenue.toStringAsFixed(2)}',
                  '${e.value.avgRating.toStringAsFixed(1)}★',
                  '${e.value.currentStock}',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 24),

            _pdfSectionTitle('TOP CUSTOMERS'),
            pw.SizedBox(height: 8),
            _buildPDFTable(
              headers: ['Rank', 'Customer', 'Orders', 'Spent', 'Status'],
              rows: report.topCustomers.asMap().entries.map((e) => [
                    '#${e.key + 1}',
                    e.value.displayName,
                    '${e.value.totalOrders}',
                    '\$${e.value.totalSpent.toStringAsFixed(2)}',
                    e.value.eliteStatus,
                  ]).toList(),
            ),

            pw.SizedBox(height: 24),

            // Confidentiality footer
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Confidential — StyleCart Analytics Report. Do not distribute without authorization.',
              style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('5A5A5A'), fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      );

      // Save PDF to temporary directory
      final fileName = 'stylecart_report_${DateFormat('yyyy_MM_dd').format(now)}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());

      return Right(file.path);
    } catch (e) {
      return Left(ServerFailure('PDF export failed: $e'));
    }
  }

  // ── Share file via native OS share sheet ───────────
  Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
      text: 'StyleCart Analytics Report',
    );
  }

  // ── PDF helpers ────────────────────────────────────
  pw.Widget _pdfSectionTitle(String title) => pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('9E9E9E'),
          letterSpacing: 1.5,
        ),
      );

  pw.Widget _buildPDFKPICard(
    String label,
    String value,
    String subtitle,
    PdfColor accentColor,
  ) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('2A1515')),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('9E9E9E'))),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: accentColor)),
            pw.SizedBox(height: 2),
            pw.Text(subtitle, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('5A5A5A'))),
          ],
        ),
      );

  pw.Widget _buildPDFTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) =>
      pw.Table(
        border: pw.TableBorder.all(color: PdfColor.fromHex('2A1515'), width: 0.5),
        columnWidths: {for (int i = 0; i < headers.length; i++) i: const pw.FlexColumnWidth()},
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('1A0A0A')),
            children: headers
                .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(h, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('D4AF37'))),
                    ))
                .toList(),
          ),
          // Data rows with alternating background
          ...rows.asMap().entries.map((entry) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key % 2 == 0 ? PdfColors.white : PdfColor.fromHex('F9F9F9'),
                ),
                children: entry.value
                    .map((cell) => pw.Padding(
                          padding: const pw.EdgeInsets.all(7),
                          child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
                        ))
                    .toList(),
              )),
        ],
      );
}

@riverpod
ReportExportService reportExportService(ReportExportServiceRef ref) =>
    const ReportExportService();
