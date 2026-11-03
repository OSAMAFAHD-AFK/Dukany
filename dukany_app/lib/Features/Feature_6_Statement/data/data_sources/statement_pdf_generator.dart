import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/app_config.dart';
import '../../../../core/utils/functions/date_formatter.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../models/statement_model.dart';

/// Builds an Arabic (RTL) A4 PDF statement and saves it in the temp folder.
class StatementPdfGenerator {
  pw.Font? _regularFont;
  pw.Font? _boldFont;

  static final PdfColor _ink = PdfColor.fromHex('#111114');
  static final PdfColor _muted = PdfColor.fromHex('#7A7A85');
  static final PdfColor _soft = PdfColor.fromHex('#F2F2F4');
  static final PdfColor _debt = PdfColor.fromHex('#E5484D');
  static final PdfColor _paid = PdfColor.fromHex('#1E9E64');

  Future<File> generate(StatementModel statement) async {
    _regularFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'));
    _boldFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'));

    final document = pw.Document(
      title: 'كشف حساب ${statement.partyName}',
      theme: pw.ThemeData.withFont(base: _regularFont, bold: _boldFont),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _buildHeader(statement),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount} — تطبيق دُكاني',
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ),
        build: (_) => [_buildSummary(statement), pw.SizedBox(height: 16), _buildTable(statement)],
      ),
    );

    final directory = await getTemporaryDirectory();
    final safeName = statement.partyName.replaceAll(RegExp(r'[^\w؀-ۿ]+'), '_');
    final file = File('${directory.path}/kashf_${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    return file.writeAsBytes(await document.save());
  }

  pw.Widget _buildHeader(StatementModel statement) {
    final periodText = statement.from == null
        ? 'كل الحساب حتى ${formatDate(DateTime.now())}'
        : 'من ${formatDate(statement.from!)} إلى ${formatDate(statement.to?.subtract(const Duration(days: 1)) ?? DateTime.now())}';
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(color: _ink, borderRadius: pw.BorderRadius.circular(12)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  statement.shopName,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'كشف حساب: ${statement.partyName}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(statement.period.label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.white)),
              pw.Text(periodText, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#A4A4AE'))),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(StatementModel statement) {
    pw.Widget box(String label, double value, PdfColor color) => pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _muted)),
            pw.SizedBox(height: 2),
            pw.Text(
              formatMoneyWithCurrency(value),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );

    return pw.Row(
      children: [
        if (statement.from != null) box('رصيد سابق', statement.openingBalance, _ink),
        box(statement.debitLabel, statement.totalDebit, _debt),
        box(statement.creditLabel, statement.totalCredit, _paid),
        box(statement.balanceLabel, statement.closingBalance, _ink),
      ],
    );
  }

  /// pw.Table does not mirror columns for RTL, so cells are listed
  /// left-to-right: balance | credit | debit | description | date.
  pw.Widget _buildTable(StatementModel statement) {
    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    const cellStyle = pw.TextStyle(fontSize: 9.5);

    pw.Widget cell(String text, {pw.TextStyle style = cellStyle, pw.Alignment alignment = pw.Alignment.centerRight}) =>
        pw.Container(
          alignment: alignment,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: pw.Text(text, style: style, textDirection: pw.TextDirection.rtl),
        );

    String money(double value) => value == 0 ? '-' : formatMoney(value);

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(1.3),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(3.6),
        4: pw.FlexColumnWidth(1.3),
      },
      border: pw.TableBorder(horizontalInside: pw.BorderSide(color: _soft, width: 1)),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _ink),
          children: [
            cell('الرصيد', style: headerStyle, alignment: pw.Alignment.center),
            cell(statement.isCustomer ? 'تسديد' : 'دفعة', style: headerStyle, alignment: pw.Alignment.center),
            cell(statement.isCustomer ? 'دين' : 'فاتورة', style: headerStyle, alignment: pw.Alignment.center),
            cell('البيان', style: headerStyle),
            cell('التاريخ', style: headerStyle, alignment: pw.Alignment.center),
          ],
        ),
        if (statement.from != null)
          pw.TableRow(
            children: [
              cell(money(statement.openingBalance), alignment: pw.Alignment.center),
              cell(''),
              cell(''),
              cell('رصيد سابق (منقول)'),
              cell(formatDate(statement.from!), alignment: pw.Alignment.center),
            ],
          ),
        for (final line in statement.lines)
          pw.TableRow(
            children: [
              cell(formatMoney(line.runningBalance), alignment: pw.Alignment.center),
              cell(
                money(line.credit),
                style: cellStyle.copyWith(color: _paid),
                alignment: pw.Alignment.center,
              ),
              cell(
                money(line.debit),
                style: cellStyle.copyWith(color: _debt),
                alignment: pw.Alignment.center,
              ),
              cell(line.description),
              cell(formatDate(line.date), alignment: pw.Alignment.center),
            ],
          ),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _soft),
          children: [
            cell(
              formatMoney(statement.closingBalance),
              style: cellStyle.copyWith(fontWeight: pw.FontWeight.bold),
              alignment: pw.Alignment.center,
            ),
            cell(money(statement.totalCredit), alignment: pw.Alignment.center),
            cell(money(statement.totalDebit), alignment: pw.Alignment.center),
            cell('الإجمالي (${AppConfig.currencyLabel})', style: cellStyle.copyWith(fontWeight: pw.FontWeight.bold)),
            cell(''),
          ],
        ),
      ],
    );
  }
}
