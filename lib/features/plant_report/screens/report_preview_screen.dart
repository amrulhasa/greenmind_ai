import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/plant_care_report.dart';
import '../services/plant_report_pdf_service.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({
    super.key,
    required this.report,
  });

  final PlantCareReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care Report'),
      ),
      body: PdfPreview(
        build: (format) => PlantReportPdfService.generatePdf(report),
      ),
    );
  }
}

class PlantPdfGenerator {
  const PlantPdfGenerator();

  Future<Uint8List> generate(
    PlantCareReport report,
  ) async {
    // ============================================================
    // LOAD FONTS
    // ============================================================

    final regularData = await rootBundle.load(
      'assets/fonts/NotoSans-Regular.ttf',
    );

    final boldData = await rootBundle.load(
      'assets/fonts/NotoSans-Bold.ttf',
    );

    final italicData = await rootBundle.load(
      'assets/fonts/NotoSans-Italic.ttf',
    );

    final regularFont = pw.Font.ttf(
      regularData,
    );

    final boldFont = pw.Font.ttf(
      boldData,
    );

    final italicFont = pw.Font.ttf(
      italicData,
    );

    // ============================================================
    // DOCUMENT
    // ============================================================

    final pdf = pw.Document();

    // ============================================================
    // THEME
    // ============================================================

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
    );

    // ============================================================
    // PAGE
    // ============================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,

        margin: const pw.EdgeInsets.all(32),

        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              bottom: 16,
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GreenMind AI',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),
                pw.Text(
                  'Plant Care Report',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },

        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 16,
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AI-generated plant-care guidance',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber}',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          );
        },

        build: (context) {
          return [
            _buildHeader(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 20),

            _buildHealthSection(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 16),

            _buildCareSection(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 16),

            _buildSymptomsSection(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 16),

            _buildRecommendationsSection(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 16),

            _buildScheduleSection(
              report,
              boldFont,
              regularFont,
            ),

            pw.SizedBox(height: 20),

            pw.Divider(),

            pw.SizedBox(height: 8),

            pw.Text(
              'This report is generated using GreenMind AI '
              'and is intended for general plant-care guidance. '
              'It should not be considered a laboratory diagnosis.',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // HEADER
  // ============================================================

  pw.Widget _buildHeader(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),

      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#2E7D32'),
        borderRadius: pw.BorderRadius.circular(16),
      ),

      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [
          pw.Text(
            'PLANT CARE REPORT',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            report.plantName,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 25,
              color: PdfColors.white,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            report.scientificName,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
              color: PdfColors.white,
              fontStyle: pw.FontStyle.italic,
            ),
          ),

          pw.SizedBox(height: 14),

          pw.Row(
            children: [
              _badge(
                '${(report.identificationConfidence * 100).round()}% AI confidence',
                regularFont,
              ),

              pw.SizedBox(width: 8),

              _badge(
                '${report.healthScore}% health',
                regularFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH
  // ============================================================

  pw.Widget _buildHealthSection(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return _section(
      title: 'Plant Health',
      boldFont: boldFont,
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            report.healthStatus,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColor.fromHex('#2E7D32'),
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            'Health Score: ${report.healthScore}/100',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            report.overview,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              lineSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARE
  // ============================================================

  pw.Widget _buildCareSection(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return _section(
      title: 'Care Requirements',
      boldFont: boldFont,
      child: pw.Column(
        children: [
          _infoRow(
            'Sunlight',
            report.sunlight,
            boldFont,
            regularFont,
          ),

          _infoRow(
            'Watering',
            report.watering,
            boldFont,
            regularFont,
          ),

          _infoRow(
            'Soil',
            report.soil,
            boldFont,
            regularFont,
          ),

          _infoRow(
            'Temperature',
            report.temperature,
            boldFont,
            regularFont,
          ),

          _infoRow(
            'Humidity',
            report.humidity,
            boldFont,
            regularFont,
          ),

          _infoRow(
            'Fertilizer',
            report.fertilizer,
            boldFont,
            regularFont,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SYMPTOMS
  // ============================================================

  pw.Widget _buildSymptomsSection(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    if (report.symptoms.isEmpty) {
      return _section(
        title: 'Visible Symptoms',
        boldFont: boldFont,
        child: pw.Text(
          'No significant visible symptoms were detected.',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 10,
          ),
        ),
      );
    }

    return _section(
      title: 'Visible Symptoms',
      boldFont: boldFont,
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: report.symptoms
            .map(
              (symptom) => pw.Padding(
                padding:
                    const pw.EdgeInsets.only(
                  bottom: 6,
                ),
                child: pw.Row(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• ',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        symptom,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // RECOMMENDATIONS
  // ============================================================

  pw.Widget _buildRecommendationsSection(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return _section(
      title: 'AI Recommendations',
      boldFont: boldFont,
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: report.recommendations.isEmpty
            ? [
                pw.Text(
                  'No additional recommendations were provided.',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                  ),
                ),
              ]
            : report.recommendations
                .map(
                  (recommendation) =>
                      pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      bottom: 7,
                    ),
                    child: pw.Row(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '• ',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 10,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            recommendation,
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                              lineSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  pw.Widget _buildScheduleSection(
    PlantCareReport report,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    if (report.careSchedule.isEmpty) {
      return _section(
        title: 'Care Schedule',
        boldFont: boldFont,
        child: pw.Text(
          'No recurring care schedule was generated.',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 10,
          ),
        ),
      );
    }

    return _section(
      title: 'Care Schedule',
      boldFont: boldFont,
      child: pw.Column(
        children: report.careSchedule
            .map(
              (task) => pw.Container(
                width: double.infinity,
                margin:
                    const pw.EdgeInsets.only(
                  bottom: 8,
                ),
                padding:
                    const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color:
                        PdfColor.fromHex('#DDE7DE'),
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(8),
                ),
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

                    pw.SizedBox(height: 4),

                    pw.Text(
                      task.description,
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 9,
                        lineSpacing: 2,
                      ),
                    ),

                    pw.SizedBox(height: 4),

                    pw.Text(
                      'Frequency: ${task.frequency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  pw.Widget _section({
    required String title,
    required pw.Font boldFont,
    required pw.Widget child,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),

      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(
          color: PdfColor.fromHex('#E0E7E1'),
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),

      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 15,
            ),
          ),

          pw.SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  pw.Widget _infoRow(
    String title,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 7,
      ),

      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#EDF1ED'),
          ),
        ),
      ),

      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 9,
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          pw.Expanded(
            child: pw.Text(
              value,
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
  // BADGE
  // ============================================================

  pw.Widget _badge(
    String text,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#4C9850'),
        borderRadius:
            pw.BorderRadius.circular(20),
      ),

      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 8,
          color: PdfColors.white,
        ),
      ),
    );
  }
}