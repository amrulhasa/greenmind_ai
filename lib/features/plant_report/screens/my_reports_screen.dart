import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({
    super.key,
  });

  // ============================================================
  // FIREBASE
  // ============================================================

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAF7),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7FAF7),

        elevation: 0,

        centerTitle: false,

        title: const Text(
          'My Reports',

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF18351C),
          ),
        ),

        foregroundColor:
            const Color(0xFF18351C),
      ),

      // ========================================================
      // NOT AUTHENTICATED
      // ========================================================

      body: user == null
          ? const _NotAuthenticatedState()
          : _ReportsStream(
              userId: user.uid,
            ),
    );
  }
}

// =================================================================
// REPORT STREAM
// =================================================================

class _ReportsStream extends StatelessWidget {
  const _ReportsStream({
    required this.userId,
  });

  final String userId;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where(
            'userId',
            isEqualTo: userId,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        // ========================================================
        // LOADING
        // ========================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const _LoadingState();
        }

        // ========================================================
        // ERROR
        // ========================================================

        if (snapshot.hasError) {
          return _ErrorState(
            message:
                'Unable to load your reports.',
            onRetry: () {
              // StreamBuilder automatically reconnects.
              // This action simply rebuilds the screen.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      const MyReportsScreen(),
                ),
              );
            },
          );
        }

        // ========================================================
        // DATA
        // ========================================================

        final documents =
            snapshot.data?.docs ?? [];

        // ========================================================
        // EMPTY
        // ========================================================

        if (documents.isEmpty) {
          return const _EmptyReportsState();
        }

        // ========================================================
        // SORT
        // ========================================================
        //
        // We sort locally instead of using Firestore orderBy.
        // This keeps the query simple and avoids requiring an
        // additional Firestore composite index.
        //
        // ========================================================

        final reports =
            List<QueryDocumentSnapshot<
                Map<String, dynamic>>>.from(
          documents,
        );

        reports.sort(
          (a, b) {
            final aDate =
                _extractDate(
              a.data()['createdAt'],
            );

            final bDate =
                _extractDate(
              b.data()['createdAt'],
            );

            return bDate.compareTo(
              aDate,
            );
          },
        );

        // ========================================================
        // LIST
        // ========================================================

        return RefreshIndicator(
          color:
              const Color(0xFF2E7D32),

          onRefresh: () async {
            // Firestore stream updates automatically.
            // Small delay provides proper pull-to-refresh UX.
            await Future<void>.delayed(
              const Duration(
                milliseconds: 400,
              ),
            );
          },

          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
            ),

            padding:
                const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),

            children: [
              // ==================================================
              // SUMMARY
              // ==================================================

              _ReportsSummary(
                count: reports.length,
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // REPORTS
              // ==================================================

              ...reports.map(
                (
                  document,
                ) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),

                    child:
                        _ReportCard(
                      document:
                          document,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DATE HELPER
  // ============================================================

  static DateTime _extractDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }
}

// =================================================================
// REPORT SUMMARY
// =================================================================

class _ReportsSummary
    extends StatelessWidget {
  const _ReportsSummary({
    required this.count,
  });

  final int count;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,

          colors: [
            Color(0xFFE7F5E9),
            Color(0xFFF8FCF8),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFD5E9D7,
          ),
        ),
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          Container(
            width: 48,
            height: 48,

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: const Icon(
              Icons.description_rounded,

              color:
                  Color(0xFF2E7D32),

              size: 25,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // ------------------------------------------------------
          // TEXT
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Your Plant Reports',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF18351C),
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '$count ${count == 1 ? 'report' : 'reports'} saved',

                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF6B796E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// REPORT CARD
// =================================================================

class _ReportCard
    extends StatelessWidget {
  const _ReportCard({
    required this.document,
  });

  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  @override
  Widget build(
    BuildContext context,
  ) {
    final data =
        document.data();

    // ==========================================================
    // DATA
    // ==========================================================

    final plantName =
        _stringValue(
      data['plantName'],
      fallback:
          'Unknown Plant',
    );

    final scientificName =
        _stringValue(
      data['scientificName'],
    );

    final healthStatus =
        _stringValue(
      data['healthStatus'],
      fallback:
          'Unknown',
    );

    final category =
        _stringValue(
      data['category'],
    );

    final confidence =
        _extractConfidence(
      data,
    );

    final createdAt =
        _extractDate(
      data['createdAt'],
    );

    final isHealthy =
        _isHealthy(
      healthStatus,
    );

    // ==========================================================
    // CARD
    // ==========================================================

    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          22,
        ),

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ReportDetailsScreen(
                reportId:
                    document.id,

                report:
                    data,
              ),
            ),
          );
        },

        child: Container(
          width:
              double.infinity,

          padding:
              const EdgeInsets.all(
            18,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius.circular(
              22,
            ),

            border:
                Border.all(
              color:
                  const Color(
                0xFFE5EBE5,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withValues(
                  alpha: 0.035,
                ),

                blurRadius:
                    16,

                offset:
                    const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),

          child: Column(
            children: [
              // ==================================================
              // TOP
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ----------------------------------------------
                  // ICON
                  // ----------------------------------------------

                  Container(
                    width: 54,
                    height: 54,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE8F5E9,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .local_florist_rounded,

                      color:
                          Color(
                        0xFF2E7D32,
                      ),

                      size: 28,
                    ),
                  ),

                  const SizedBox(
                    width: 13,
                  ),

                  // ----------------------------------------------
                  // PLANT INFO
                  // ----------------------------------------------

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          plantName,

                          maxLines:
                              2,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            fontSize:
                                17,

                            fontWeight:
                                FontWeight.w700,

                            color:
                                Color(
                              0xFF1E2A20,
                            ),
                          ),
                        ),

                        if (scientificName
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(
                            height:
                                3,
                          ),

                          Text(
                            scientificName,

                            maxLines:
                                1,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize:
                                  12.5,

                              fontStyle:
                                  FontStyle
                                      .italic,

                              color:
                                  Color(
                                0xFF7A857C,
                              ),
                            ),
                          ),
                        ],

                        if (category
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(
                            height:
                                5,
                          ),

                          Text(
                            category,

                            style:
                                const TextStyle(
                              fontSize:
                                  11.5,

                              fontWeight:
                                  FontWeight
                                      .w600,

                              color:
                                  Color(
                                0xFF66806B,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // ----------------------------------------------
                  // CHEVRON
                  // ----------------------------------------------

                  const Icon(
                    Icons
                        .chevron_right_rounded,

                    color:
                        Color(
                      0xFF9AA49C,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // DIVIDER
              // ==================================================

              Container(
                height: 1,

                color:
                    const Color(
                  0xFFF0F3F0,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // ==================================================
              // META
              // ==================================================

              Row(
                children: [
                  // ----------------------------------------------
                  // HEALTH
                  // ----------------------------------------------

                  _StatusBadge(
                    text:
                        healthStatus,

                    isHealthy:
                        isHealthy,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // ----------------------------------------------
                  // CONFIDENCE
                  // ----------------------------------------------

                  _MetaItem(
                    icon:
                        Icons
                            .verified_outlined,

                    text:
                        '${confidence.toStringAsFixed(0)}%',
                  ),

                  const Spacer(),

                  // ----------------------------------------------
                  // DATE
                  // ----------------------------------------------

                  _MetaItem(
                    icon:
                        Icons
                            .calendar_today_outlined,

                    text:
                        _formatDate(
                      createdAt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result =
        value.toString().trim();

    return result.isEmpty
        ? fallback
        : result;
  }

  static double _extractConfidence(
    Map<String, dynamic> data,
  ) {
    dynamic value =
        data[
            'identificationConfidencePercentage'];

    value ??=
        data[
            'identificationConfidence'];

    if (value is num) {
      final number =
          value.toDouble();

      // If Firestore contains normalized
      // confidence like 0.95.
      if (number <= 1) {
        return number * 100;
      }

      return number.clamp(
        0,
        100,
      );
    }

    return 0;
  }

  static bool _isHealthy(
    String status,
  ) {
    final value =
        status.toLowerCase();

    return value.contains(
          'healthy',
        ) &&
        !value.contains(
          'unhealthy',
        );
  }

  static DateTime _extractDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  static String _formatDate(
    DateTime date,
  ) {
    if (date.year <= 1970) {
      return 'Unknown date';
    }

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}

// =================================================================
// STATUS BADGE
// =================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.isHealthy,
  });

  final String text;
  final bool isHealthy;

  @override
  Widget build(
    BuildContext context,
  ) {
    final color = isHealthy
        ? const Color(
            0xFF2E7D32,
          )
        : const Color(
            0xFFE67E22,
          );

    final background = isHealthy
        ? const Color(
            0xFFEAF6EC,
          )
        : const Color(
            0xFFFFF3E8,
          );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            background,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            isHealthy
                ? Icons
                    .check_circle_rounded
                : Icons
                    .warning_amber_rounded,

            size: 14,

            color:
                color,
          ),

          const SizedBox(
            width: 4,
          ),

          Text(
            text,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 11.5,

              fontWeight:
                  FontWeight.w700,

              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// META ITEM
// =================================================================

class _MetaItem
    extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Icon(
          icon,

          size: 13,

          color:
              const Color(
            0xFF879189,
          ),
        ),

        const SizedBox(
          width: 4,
        ),

        Text(
          text,

          style:
              const TextStyle(
            fontSize: 11.5,

            fontWeight:
                FontWeight.w600,

            color:
                Color(
              0xFF727D74,
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// EMPTY STATE
// =================================================================

class _EmptyReportsState
    extends StatelessWidget {
  const _EmptyReportsState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE8F5E9,
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),

              child: const Icon(
                Icons
                    .description_outlined,

                size: 44,

                color:
                    Color(
                  0xFF2E7D32,
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            const Text(
              'No Reports Yet',

              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF203124),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Create your first AI plant care report '
              'to see it here.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color:
                    Color(0xFF78837A),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            SizedBox(
              height: 48,

              child:
                  ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop();
                },

                icon:
                    const Icon(
                  Icons
                      .add_rounded,
                  size: 20,
                ),

                label:
                    const Text(
                  'Create Report',
                  style:
                      TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2E7D32,
                  ),

                  foregroundColor:
                      Colors.white,

                  elevation:
                      0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// LOADING STATE
// =================================================================

class _LoadingState
    extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child: CircularProgressIndicator(
        color:
            Color(0xFF2E7D32),
      ),
    );
  }
}

// =================================================================
// ERROR STATE
// =================================================================

class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,

              size: 58,

              color:
                  Color(0xFF9AA49C),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Unable to Load Reports',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF263328),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              message,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 13.5,
                color:
                    Color(0xFF78837A),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            OutlinedButton.icon(
              onPressed:
                  onRetry,

              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),

              label:
                  const Text(
                'Try Again',
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(
                  0xFF2E7D32,
                ),

                side:
                    const BorderSide(
                  color:
                      Color(
                    0xFF2E7D32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// NOT AUTHENTICATED STATE
// =================================================================

class _NotAuthenticatedState
    extends StatelessWidget {
  const _NotAuthenticatedState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .person_outline_rounded,

              size: 60,

              color:
                  Color(0xFF9AA49C),
            ),

            SizedBox(
              height: 18,
            ),

            Text(
              'Please Sign In',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF263328),
              ),
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'Sign in to view your saved plant reports.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                fontSize: 14,
                color:
                    Color(0xFF78837A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// REPORT DETAILS SCREEN
// =================================================================

class ReportDetailsScreen
    extends StatelessWidget {
  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.report,
  });

  final String reportId;

  final Map<String, dynamic>
      report;

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteReport(
    BuildContext context,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,

      builder: (
        context,
      ) {
        return AlertDialog(
          title:
              const Text(
            'Delete Report?',
          ),

          content:
              const Text(
            'This report will be permanently '
            'removed from your account.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore
          .instance
          .collection('reports')
          .doc(reportId)
          .delete();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Report deleted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Unable to delete the report.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final plantName =
        _value(
      report['plantName'],
      'Unknown Plant',
    );

    final scientificName =
        _value(
      report['scientificName'],
      '',
    );

    final healthStatus =
        _value(
      report['healthStatus'],
      'Unknown',
    );

    final overview =
        _value(
      report['overview'],
      _value(
        report['description'],
        '',
      ),
    );

    final sunlight =
        _value(
      report['sunlight'],
      '',
    );

    final watering =
        _value(
      report['watering'],
      '',
    );

    final soil =
        _value(
      report['soil'],
      '',
    );

    final temperature =
        _value(
      report['temperature'],
      '',
    );

    final humidity =
        _value(
      report['humidity'],
      '',
    );

    final fertilizer =
        _value(
      report['fertilizer'],
      '',
    );

    final symptoms =
        _value(
      report['symptoms'],
      '',
    );

    final recommendations =
        _extractList(
      report['recommendations'],
    );

    final confidence =
        _extractConfidence(
      report,
    );

    final isHealthy =
        healthStatus
            .toLowerCase()
            .contains(
              'healthy',
            ) &&
        !healthStatus
            .toLowerCase()
            .contains(
              'unhealthy',
            );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAF7),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7FAF7),

        elevation: 0,

        title:
            const Text(
          'Report Details',
        ),

        foregroundColor:
            const Color(0xFF18351C),

        actions: [
          IconButton(
            tooltip:
                'Delete report',

            onPressed: () {
              _deleteReport(
                context,
              );
            },

            icon:
                const Icon(
              Icons
                  .delete_outline_rounded,

              color:
                  Colors.red,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          32,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER CARD
            // ==================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE4EAE4,
                  ),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE8F5E9,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            17,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .local_florist_rounded,

                          color:
                              Color(
                            0xFF2E7D32,
                          ),

                          size: 29,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              plantName,

                              style:
                                  const TextStyle(
                                fontSize:
                                    21,

                                fontWeight:
                                    FontWeight
                                        .w700,

                                color:
                                    Color(
                                  0xFF18351C,
                                ),
                              ),
                            ),

                            if (scientificName
                                .trim()
                                .isNotEmpty)
                              Text(
                                scientificName,

                                style:
                                    const TextStyle(
                                  fontSize:
                                      13,

                                  fontStyle:
                                      FontStyle
                                          .italic,

                                  color:
                                      Color(
                                    0xFF7A857C,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _StatusBadge(
                    text:
                        healthStatus,

                    isHealthy:
                        isHealthy,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // --------------------------------------------
                  // CONFIDENCE
                  // --------------------------------------------

                  const Text(
                    'Identification Confidence',

                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF344238),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),

                          child:
                              LinearProgressIndicator(
                            value:
                                confidence /
                                    100,

                            minHeight:
                                9,

                            backgroundColor:
                                const Color(
                              0xFFE7EFE8,
                            ),

                            color:
                                const Color(
                              0xFF2E7D32,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        '${confidence.toStringAsFixed(0)}%',

                        style:
                            const TextStyle(
                          fontSize: 14,

                          fontWeight:
                              FontWeight.w700,

                          color:
                              Color(
                            0xFF2E7D32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // REPORT CONTENT
            // ==================================================

            if (overview
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 20,
              ),

              _DetailSection(
                icon:
                    Icons.info_outline_rounded,

                title:
                    'Overview',

                content:
                    overview,
              ),
            ],

            if (sunlight
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.wb_sunny_outlined,

                title:
                    'Sunlight',

                content:
                    sunlight,
              ),
            ],

            if (watering
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.water_drop_outlined,

                title:
                    'Watering',

                content:
                    watering,
              ),
            ],

            if (soil
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.grass_outlined,

                title:
                    'Soil',

                content:
                    soil,
              ),
            ],

            if (temperature
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.thermostat_outlined,

                title:
                    'Temperature',

                content:
                    temperature,
              ),
            ],

            if (humidity
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.water_outlined,

                title:
                    'Humidity',

                content:
                    humidity,
              ),
            ],

            if (fertilizer
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons.eco_outlined,

                title:
                    'Fertilizer',

                content:
                    fertilizer,
              ),
            ],

            if (symptoms
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _DetailSection(
                icon:
                    Icons
                        .visibility_outlined,

                title:
                    'Symptoms',

                content:
                    symptoms,
              ),
            ],

            if (recommendations
                .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              _RecommendationSection(
                recommendations:
                    recommendations,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _value(
    dynamic value,
    String fallback,
  ) {
    if (value == null) {
      return fallback;
    }

    final result =
        value.toString().trim();

    return result.isEmpty
        ? fallback
        : result;
  }

  static double _extractConfidence(
    Map<String, dynamic> data,
  ) {
    dynamic value =
        data[
            'identificationConfidencePercentage'];

    value ??=
        data[
            'identificationConfidence'];

    if (value is num) {
      final number =
          value.toDouble();

      if (number <= 1) {
        return number * 100;
      }

      return number.clamp(
        0,
        100,
      );
    }

    return 0;
  }

  static List<String> _extractList(
    dynamic value,
  ) {
    if (value is List) {
      return value
          .map(
            (item) =>
                item.toString().trim(),
          )
          .where(
            (item) =>
                item.isNotEmpty,
          )
          .toList();
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return value
          .split('\n')
          .map(
            (item) =>
                item.trim(),
          )
          .where(
            (item) =>
                item.isNotEmpty,
          )
          .toList();
    }

    return [];
  }
}

// =================================================================
// DETAIL SECTION
// =================================================================

class _DetailSection
    extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE5EBE5,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,

                size: 21,

                color:
                    const Color(
                  0xFF2E7D32,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Text(
                title,

                style:
                    const TextStyle(
                  fontSize: 16,

                  fontWeight:
                      FontWeight.w700,

                  color:
                      Color(
                    0xFF253128,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            content,

            style:
                const TextStyle(
              fontSize: 13.5,

              height: 1.55,

              color:
                  Color(
                0xFF667269,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// RECOMMENDATIONS
// =================================================================

class _RecommendationSection
    extends StatelessWidget {
  const _RecommendationSection({
    required this.recommendations,
  });

  final List<String>
      recommendations;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEFF8F0,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD8EBD9,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .lightbulb_outline_rounded,

                size: 21,

                color:
                    Color(
                  0xFF2E7D32,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              const Text(
                'Recommendations',

                style:
                    TextStyle(
                  fontSize: 16,

                  fontWeight:
                      FontWeight.w700,

                  color:
                      Color(
                    0xFF253128,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          ...recommendations.map(
            (
              recommendation,
            ) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 9,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 6,
                      ),

                      child:
                          Icon(
                        Icons
                            .circle,

                        size: 7,

                        color:
                            Color(
                          0xFF2E7D32,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Expanded(
                      child:
                          Text(
                        recommendation,

                        style:
                            const TextStyle(
                          fontSize:
                              13.5,

                          height:
                              1.45,

                          color:
                              Color(
                            0xFF667269,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}