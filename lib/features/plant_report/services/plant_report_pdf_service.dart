import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/plant_care_report.dart';

class PlantReportPdfService {
  // ============================================================
  // FONT LOADING
  // ============================================================

  static Future<pw.Font> _loadRegularFont() async {
    final data = await rootBundle.load(
      'assets/fonts/NotoSans-Regular.ttf',
    );

    return pw.Font.ttf(data);
  }

  static Future<pw.Font> _loadBoldFont() async {
    final data = await rootBundle.load(
      'assets/fonts/NotoSans-Bold.ttf',
    );

    return pw.Font.ttf(data);
  }

  // ============================================================
  // GENERATE PDF
  // ============================================================

  static Future<Uint8List> generatePdf(
    PlantCareReport report,
  ) async {
    // ==========================================================
    // LOAD FONTS
    // ==========================================================

    final regularFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();

    // ==========================================================
    // LOAD PLANT IMAGE
    // ==========================================================

    pw.MemoryImage? plantImage;

    if (report.hasImage &&
        report.imageBytes != null &&
        report.imageBytes!.isNotEmpty) {
      plantImage = pw.MemoryImage(
        report.imageBytes!,
      );
    }

    // ==========================================================
    // PDF DOCUMENT
    // ==========================================================

    final pdf = pw.Document();

    // ==========================================================
    // COLORS
    // ==========================================================

    final green = PdfColor.fromHex('#2E7D32');

    final darkGreen = PdfColor.fromHex('#1B5E20');

    final lightGreen = PdfColor.fromHex('#E8F5E9');

    final softGreen = PdfColor.fromHex('#F7FAF7');

    final borderGreen = PdfColor.fromHex('#E2E9E3');

    final grey = PdfColor.fromHex('#667067');

    final darkText = PdfColor.fromHex('#172018');

    final footerGrey = PdfColor.fromHex('#8A938C');

    // ==========================================================
    // PAGE
    // ==========================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.fromLTRB(
          32,
          32,
          32,
          42,
        ),

        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),

        // ========================================================
        // HEADER
        // ========================================================

        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              bottom: 15,
            ),

            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.center,

              children: [
                pw.Text(
                  'GREENMIND AI',

                  style: pw.TextStyle(
                    font: boldFont,
                    color: darkGreen,
                    fontSize: 12,
                    letterSpacing: 0.7,
                  ),
                ),

                pw.Spacer(),

                pw.Text(
                  'Plant Care Report',

                  style: pw.TextStyle(
                    font: regularFont,
                    color: grey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        },

        // ========================================================
        // PROFESSIONAL FOOTER
        // ========================================================

        footer: (context) {
          final pageNumber =
              context.pageNumber
                  .toString()
                  .padLeft(2, '0');

          final generatedDate =
              _shortDate(report.generatedAt);

          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 12,
            ),

            padding: const pw.EdgeInsets.only(
              top: 9,
            ),

            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: borderGreen,
                  width: 0.8,
                ),
              ),
            ),

            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.center,

              children: [
                // ==================================================
                // BRAND MARK
                // ==================================================

                pw.Container(
                  width: 22,
                  height: 22,

                  alignment:
                      pw.Alignment.center,

                  decoration: pw.BoxDecoration(
                    color: lightGreen,
                    shape: pw.BoxShape.circle,
                  ),

                  child: pw.Text(
                    'GM',

                    style: pw.TextStyle(
                      font: boldFont,
                      color: green,
                      fontSize: 6.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                pw.SizedBox(
                  width: 7,
                ),

                // ==================================================
                // BRAND INFORMATION
                // ==================================================

                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,

                  mainAxisSize:
                      pw.MainAxisSize.min,

                  children: [
                    pw.Text(
                      'GREENMIND AI',

                      style: pw.TextStyle(
                        font: boldFont,
                        color: darkText,
                        fontSize: 7.5,
                        letterSpacing: 0.5,
                      ),
                    ),

                    pw.SizedBox(
                      height: 1.5,
                    ),

                    pw.Text(
                      'AI-Powered Plant Care Report',

                      style: pw.TextStyle(
                        font: regularFont,
                        color: footerGrey,
                        fontSize: 6.5,
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // ==================================================
                // GENERATED DATE
                // ==================================================

                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.end,

                  mainAxisSize:
                      pw.MainAxisSize.min,

                  children: [
                    pw.Text(
                      'GENERATED',

                      style: pw.TextStyle(
                        font: boldFont,
                        color: footerGrey,
                        fontSize: 5.5,
                        letterSpacing: 0.7,
                      ),
                    ),

                    pw.SizedBox(
                      height: 1.5,
                    ),

                    pw.Text(
                      generatedDate,

                      style: pw.TextStyle(
                        font: regularFont,
                        color: grey,
                        fontSize: 6.5,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(
                  width: 14,
                ),

                // ==================================================
                // PAGE NUMBER
                // ==================================================

                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration: pw.BoxDecoration(
                    color: lightGreen,

                    borderRadius:
                        pw.BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: pw.Row(
                    mainAxisSize:
                        pw.MainAxisSize.min,

                    children: [
                      pw.Text(
                        'PAGE',

                        style: pw.TextStyle(
                          font: boldFont,
                          color: green,
                          fontSize: 5.5,
                          letterSpacing: 0.5,
                        ),
                      ),

                      pw.SizedBox(
                        width: 4,
                      ),

                      pw.Text(
                        pageNumber,

                        style: pw.TextStyle(
                          font: boldFont,
                          color: darkGreen,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

        // ========================================================
        // CONTENT
        // ========================================================

        build: (context) => [
          // ======================================================
          // REPORT HERO
          // ======================================================

          pw.Container(
            padding: const pw.EdgeInsets.all(18),

            decoration: pw.BoxDecoration(
              color: darkGreen,

              borderRadius:
                  pw.BorderRadius.circular(18),
            ),

            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [
                // ==================================================
                // PLANT IMAGE
                // ==================================================

                if (plantImage != null) ...[
                  pw.Container(
                    width: 145,
                    height: 145,

                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,

                      borderRadius:
                          pw.BorderRadius.circular(
                        16,
                      ),

                      border: pw.Border.all(
                        color: PdfColors.white,
                        width: 3,
                      ),
                    ),

                    child: pw.ClipRRect(
                      horizontalRadius: 13,
                      verticalRadius: 13,

                      child: pw.Image(
                        plantImage,
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),

                  pw.SizedBox(
                    width: 20,
                  ),
                ],

                // ==================================================
                // PLANT INFORMATION
                // ==================================================

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text(
                        report.generatedFromImage
                            ? 'IMAGE PLANT CARE REPORT'
                            : 'PLANT CARE REPORT',

                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),

                      pw.SizedBox(
                        height: 10,
                      ),

                      pw.Text(
                        report.plantName,

                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 22,
                        ),
                      ),

                      pw.SizedBox(
                        height: 5,
                      ),

                      pw.Text(
                        report.scientificName,

                        style: pw.TextStyle(
                          font: regularFont,
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),

                      pw.SizedBox(
                        height: 16,
                      ),

                      pw.Wrap(
                        spacing: 6,
                        runSpacing: 6,

                        children: [
                          _pdfBadge(
                            report.category,
                            boldFont,
                          ),

                          _pdfBadge(
                            '${report.confidencePercentage}% Confidence',
                            boldFont,
                          ),

                          _pdfBadge(
                            '${report.normalizedHealthScore}% '
                            '${report.healthStatus}',
                            boldFont,
                          ),
                        ],
                      ),

                      pw.SizedBox(
                        height: 14,
                      ),

                      pw.Text(
                        'Generated by GreenMind AI',

                        style: pw.TextStyle(
                          font: regularFont,
                          color: PdfColors.white,
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 20,
          ),

          // ======================================================
          // IDENTIFICATION SUMMARY
          // ======================================================

          _sectionTitle(
            'Identification Summary',
            green,
            boldFont,
          ),

          pw.Container(
            padding: const pw.EdgeInsets.all(15),

            decoration: pw.BoxDecoration(
              color: PdfColors.white,

              border: pw.Border.all(
                color: borderGreen,
              ),

              borderRadius:
                  pw.BorderRadius.circular(12),
            ),

            child: pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(
                    'Plant',
                    report.plantName,
                    darkText,
                    grey,
                    regularFont,
                    boldFont,
                  ),
                ),

                pw.SizedBox(
                  width: 12,
                ),

                pw.Expanded(
                  child: _infoItem(
                    'Scientific Name',
                    report.scientificName,
                    darkText,
                    grey,
                    regularFont,
                    boldFont,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 18,
          ),

          // ======================================================
          // HEALTH OVERVIEW
          // ======================================================

          _sectionTitle(
            'Health Overview',
            green,
            boldFont,
          ),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),

            decoration: pw.BoxDecoration(
              color: lightGreen,

              borderRadius:
                  pw.BorderRadius.circular(12),
            ),

            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [
                // HEALTH SCORE
                pw.Container(
                  width: 60,
                  height: 60,

                  alignment:
                      pw.Alignment.center,

                  decoration: pw.BoxDecoration(
                    color: green,
                    shape: pw.BoxShape.circle,
                  ),

                  child: pw.Text(
                    '${report.normalizedHealthScore}%',

                    style: pw.TextStyle(
                      font: boldFont,
                      color: PdfColors.white,
                      fontSize: 14,
                    ),
                  ),
                ),

                pw.SizedBox(
                  width: 15,
                ),

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text(
                        report.healthStatus,

                        style: pw.TextStyle(
                          font: boldFont,
                          color: darkGreen,
                          fontSize: 16,
                        ),
                      ),

                      pw.SizedBox(
                        height: 5,
                      ),

                      pw.Text(
                        report.overview,

                        style: pw.TextStyle(
                          font: regularFont,
                          color: grey,
                          fontSize: 9,
                          lineSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 18,
          ),

          // ======================================================
          // CARE REQUIREMENTS
          // ======================================================

          _sectionTitle(
            'Care Requirements',
            green,
            boldFont,
          ),

          pw.Table(
            border: pw.TableBorder.all(
              color: borderGreen,
              width: 0.5,
            ),

            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(3),
            },

            children: [
              _tableRow(
                'Sunlight',
                report.sunlight,
                true,
                regularFont,
                boldFont,
                grey,
              ),

              _tableRow(
                'Watering',
                report.watering,
                false,
                regularFont,
                boldFont,
                grey,
              ),

              _tableRow(
                'Soil',
                report.soil,
                true,
                regularFont,
                boldFont,
                grey,
              ),

              _tableRow(
                'Temperature',
                report.temperature,
                false,
                regularFont,
                boldFont,
                grey,
              ),

              _tableRow(
                'Humidity',
                report.humidity,
                true,
                regularFont,
                boldFont,
                grey,
              ),

              _tableRow(
                'Fertilizer',
                report.fertilizer,
                false,
                regularFont,
                boldFont,
                grey,
              ),
            ],
          ),

          pw.SizedBox(
            height: 18,
          ),

          // ======================================================
          // HEALTH OBSERVATIONS
          // ======================================================

          _sectionTitle(
            'Health Observations',
            green,
            boldFont,
          ),

          if (report.symptoms.isEmpty)
            _bulletItem(
              'No specific health issues were detected.',
              lightGreen,
              green,
              regularFont,
              boldFont,
            )
          else
            ...report.symptoms.map(
              (symptom) => _bulletItem(
                symptom,
                lightGreen,
                green,
                regularFont,
                boldFont,
              ),
            ),

          pw.SizedBox(
            height: 12,
          ),

          // ======================================================
          // CARE SCHEDULE
          // ======================================================

          _sectionTitle(
            'Care Schedule',
            green,
            boldFont,
          ),

          if (report.careSchedule.isEmpty)
            pw.Container(
              padding:
                  const pw.EdgeInsets.all(12),

              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: borderGreen,
                ),

                borderRadius:
                    pw.BorderRadius.circular(10),
              ),

              child: pw.Text(
                'No care schedule available.',

                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: grey,
                ),
              ),
            )
          else
            ...report.careSchedule.map(
              (task) => pw.Container(
                margin:
                    const pw.EdgeInsets.only(
                  bottom: 8,
                ),

                padding:
                    const pw.EdgeInsets.all(12),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: borderGreen,
                  ),

                  borderRadius:
                      pw.BorderRadius.circular(
                    10,
                  ),
                ),

                child: pw.Row(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,

                  children: [
                    pw.Container(
                      width: 34,
                      height: 34,

                      alignment:
                          pw.Alignment.center,

                      decoration:
                          pw.BoxDecoration(
                        color: lightGreen,
                        shape: pw.BoxShape.circle,
                      ),

                      child: pw.Text(
                        'OK',

                        style: pw.TextStyle(
                          font: boldFont,
                          color: green,
                          fontSize: 6,
                        ),
                      ),
                    ),

                    pw.SizedBox(
                      width: 10,
                    ),

                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,

                        children: [
                          pw.Text(
                            task.title,

                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 11,
                            ),
                          ),

                          pw.SizedBox(
                            height: 3,
                          ),

                          pw.Text(
                            task.description,

                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 8,
                              color: grey,
                              lineSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(
                      width: 8,
                    ),

                    pw.Text(
                      task.frequency,

                      style: pw.TextStyle(
                        font: boldFont,
                        color: green,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          pw.SizedBox(
            height: 10,
          ),

          // ======================================================
          // AI RECOMMENDATIONS
          // ======================================================

          _sectionTitle(
            'AI Recommendations',
            green,
            boldFont,
          ),

          if (report.recommendations.isEmpty)
            _bulletItem(
              'No additional recommendations available.',
              lightGreen,
              green,
              regularFont,
              boldFont,
            )
          else
            ...report.recommendations.map(
              (recommendation) => _bulletItem(
                recommendation,
                lightGreen,
                green,
                regularFont,
                boldFont,
              ),
            ),

          pw.SizedBox(
            height: 18,
          ),

          // ======================================================
          // REPORT METADATA
          // ======================================================

          _sectionTitle(
            'Report Information',
            green,
            boldFont,
          ),

          pw.Container(
            padding:
                const pw.EdgeInsets.all(12),

            decoration: pw.BoxDecoration(
              color: softGreen,

              borderRadius:
                  pw.BorderRadius.circular(10),
            ),

            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [
                _metadataRow(
                  'Generated',
                  _formatDate(
                    report.generatedAt,
                  ),
                  regularFont,
                  boldFont,
                  grey,
                ),

                pw.SizedBox(
                  height: 5,
                ),

                _metadataRow(
                  'Identification Confidence',
                  report.confidenceText,
                  regularFont,
                  boldFont,
                  grey,
                ),

                pw.SizedBox(
                  height: 5,
                ),

                _metadataRow(
                  'Image Source',
                  _imageSourceText(report),
                  regularFont,
                  boldFont,
                  grey,
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 18,
          ),

          // ======================================================
          // DISCLAIMER
          // ======================================================

          pw.Container(
            padding:
                const pw.EdgeInsets.all(12),

            decoration: pw.BoxDecoration(
              color: softGreen,

              borderRadius:
                  pw.BorderRadius.circular(10),

              border: pw.Border.all(
                color: borderGreen,
              ),
            ),

            child: pw.Text(
              'This report is generated by '
              'GreenMind AI to assist with '
              'general plant care. For severe '
              'disease or pest problems, consult '
              'a qualified horticulture professional.',

              style: pw.TextStyle(
                font: regularFont,
                color: grey,
                fontSize: 7.5,
                lineSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // SAVE / SHARE PDF
  // ============================================================

  static Future<void> saveOrSharePdf(
    Uint8List bytes,
    String plantName,
  ) async {
    final cleanName =
        plantName.trim().isEmpty
            ? 'Plant'
            : plantName.trim();

    final safeName = cleanName
        .replaceAll(
          RegExp(r'[^a-zA-Z0-9]+'),
          '_',
        )
        .replaceAll(
          RegExp(r'_+'),
          '_',
        )
        .replaceAll(
          RegExp(r'^_|_$'),
          '',
        );

    final fileName =
        '${safeName.isEmpty ? 'Plant' : safeName}'
        '_Plant_Care_Report.pdf';

    await Printing.sharePdf(
      bytes: bytes,
      filename: fileName,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  static pw.Widget _sectionTitle(
    String title,
    PdfColor color,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(
        bottom: 10,
      ),

      child: pw.Text(
        title,

        style: pw.TextStyle(
          font: boldFont,
          color: color,
          fontSize: 15,
        ),
      ),
    );
  }

  // ============================================================
  // PDF BADGE
  // ============================================================

  static pw.Widget _pdfBadge(
    String text,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(
          '#4CAF50',
        ),

        borderRadius:
            pw.BorderRadius.circular(20),
      ),

      child: pw.Text(
        text,

        style: pw.TextStyle(
          font: boldFont,
          color: PdfColors.white,
          fontSize: 7.5,
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  static pw.Widget _infoItem(
    String title,
    String value,
    PdfColor darkText,
    PdfColor grey,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,

      children: [
        pw.Text(
          title,

          style: pw.TextStyle(
            font: boldFont,
            fontSize: 8,
            color: grey,
          ),
        ),

        pw.SizedBox(
          height: 4,
        ),

        pw.Text(
          value,

          style: pw.TextStyle(
            font: regularFont,
            fontSize: 9,
            color: darkText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BULLET ITEM
  // ============================================================

  static pw.Widget _bulletItem(
    String text,
    PdfColor lightGreen,
    PdfColor green,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 7,
      ),

      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [
          pw.Container(
            width: 18,
            height: 18,

            alignment:
                pw.Alignment.center,

            decoration: pw.BoxDecoration(
              color: lightGreen,
              shape: pw.BoxShape.circle,
            ),

            child: pw.Text(
              'OK',

              style: pw.TextStyle(
                font: boldFont,
                color: green,
                fontSize: 5.5,
              ),
            ),
          ),

          pw.SizedBox(
            width: 7,
          ),

          pw.Expanded(
            child: pw.Text(
              text,

              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
                lineSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  static pw.TableRow _tableRow(
    String title,
    String value,
    bool alternate,
    pw.Font regularFont,
    pw.Font boldFont,
    PdfColor grey,
  ) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: alternate
            ? PdfColor.fromHex(
                '#F8FAF8',
              )
            : PdfColors.white,
      ),

      children: [
        pw.Padding(
          padding:
              const pw.EdgeInsets.all(9),

          child: pw.Text(
            title,

            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8.5,
            ),
          ),
        ),

        pw.Padding(
          padding:
              const pw.EdgeInsets.all(9),

          child: pw.Text(
            value,

            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8.5,
              color: grey,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // METADATA ROW
  // ============================================================

  static pw.Widget _metadataRow(
    String title,
    String value,
    pw.Font regularFont,
    pw.Font boldFont,
    PdfColor grey,
  ) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,

      children: [
        pw.SizedBox(
          width: 145,

          child: pw.Text(
            title,

            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
              color: grey,
            ),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            value,

            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: grey,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE SOURCE
  // ============================================================

  static String _imageSourceText(
    PlantCareReport report,
  ) {
    if (!report.generatedFromImage) {
      return 'Not image-based';
    }

    if (report.imageSource == 'camera') {
      return 'Camera';
    }

    if (report.imageSource == 'gallery') {
      return 'Gallery';
    }

    return 'Image';
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String _formatDate(
    DateTime date,
  ) {
    final local = date.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(2, '0');

    final month =
        local.month
            .toString()
            .padLeft(2, '0');

    final year =
        local.year.toString();

    final hour =
        local.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        local.minute
            .toString()
            .padLeft(2, '0');

    return '$day/$month/$year '
        '$hour:$minute';
  }

  // ============================================================
  // SHORT DATE FOR FOOTER
  // ============================================================

  static String _shortDate(
    DateTime date,
  ) {
    final local = date.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(2, '0');

    final month =
        local.month
            .toString()
            .padLeft(2, '0');

    final year =
        local.year.toString();

    return '$day/$month/$year';
  }
}