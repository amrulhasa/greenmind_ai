import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({
    super.key,
  });

  @override
  State<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState
    extends State<AdminReportsScreen> {
  // ==========================================================================
  // FIRESTORE
  // ==========================================================================

  final CollectionReference<Map<String, dynamic>>
      _reportsCollection =
      FirebaseFirestore.instance.collection(
    'reports',
  );

  // ==========================================================================
  // STREAM
  // ==========================================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _reportsStream {
    return _reportsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      // ========================================================================
      // APP BAR
      // ========================================================================

      appBar: AppBar(
        title: const Text(
          'Reports',
        ),
        elevation: 0,
      ),

      // ========================================================================
      // BODY
      // ========================================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _reportsStream,
        builder: (
          context,
          snapshot,
        ) {
          // ====================================================================
          // LOADING
          // ====================================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ====================================================================
          // ERROR
          // ====================================================================

          if (snapshot.hasError) {
            return _ErrorView(
              message:
                  _friendlyError(
                snapshot.error,
              ),
              onRetry: _retry,
            );
          }

          // ====================================================================
          // DATA
          // ====================================================================

          final documents =
              snapshot.data?.docs ??
                  <QueryDocumentSnapshot<
                      Map<String, dynamic>>>[];

          // ====================================================================
          // EMPTY
          // ====================================================================

          if (documents.isEmpty) {
            return const _EmptyReportsView();
          }

          // ====================================================================
          // REPORT LIST
          // ====================================================================

          return RefreshIndicator(
            onRefresh: _refreshReports,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: EdgeInsets.all(
                MediaQuery.of(context)
                        .size
                        .width >=
                    1000
                    ? AppSpacing.xl
                    : AppSpacing.lg,
              ),

              children: [
                // ==================================================================
                // HEADER
                // ==================================================================

                Text(
                  'Plant Care Reports',
                  style:
                      AppTextStyles.heading1,
                ),

                const SizedBox(
                  height: AppSpacing.xs,
                ),

                Text(
                  '${documents.length} report(s) found',
                  style:
                      AppTextStyles.subtitle,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // ==================================================================
                // REPORTS
                // ==================================================================

                ...documents.map(
                  (
                    document,
                  ) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child:
                          _ReportCard(
                        document:
                            document,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // RETRY
  // ==========================================================================

  void _retry() {
    setState(() {});
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  Future<void> _refreshReports() async {
    try {
      await _reportsCollection
          .limit(1)
          .get(
            const GetOptions(
              source:
                  Source.server,
            ),
          );
    } catch (_) {
      // StreamBuilder will display
      // the actual Firestore error.
    }
  }

  // ==========================================================================
  // FRIENDLY ERROR
  // ==========================================================================

  String _friendlyError(
    Object? error,
  ) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied.\n\n'
              'Please check your Firestore security rules.';

        case 'failed-precondition':
          return 'Firestore index/configuration is required.\n\n'
              '${error.message ?? ''}';

        case 'unavailable':
          return 'Firestore is temporarily unavailable.\n\n'
              'Please check your internet connection.';

        case 'unauthenticated':
          return 'Your login session has expired.\n\n'
              'Please login again.';

        default:
          return error.message ??
              'Unable to load reports.';
      }
    }

    return error?.toString() ??
        'Unable to load reports.';
  }
}

// ============================================================================
// REPORT CARD
// ============================================================================

class _ReportCard
    extends StatelessWidget {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  const _ReportCard({
    required this.document,
  });

  // ==========================================================================
  // STRING
  // ==========================================================================

  String _string(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }

  // ==========================================================================
  // INT
  // ==========================================================================

  int _int(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ==========================================================================
  // DATE
  // ==========================================================================

  String _formatDate(
    dynamic value,
  ) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(
        value,
      );
    }

    if (date == null) {
      return 'Unknown date';
    }

    final String day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final String month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final String year =
        date.year.toString();

    final String hour =
        date.hour.toString().padLeft(
              2,
              '0',
            );

    final String minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year • '
        '$hour:$minute';
  }

  // ==========================================================================
  // STATUS COLOR
  // ==========================================================================

  Color _statusColor(
    String status,
  ) {
    switch (
      status.toLowerCase()
    ) {
      case 'reviewed':
        return Colors.blue;

      case 'resolved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  // ==========================================================================
  // SHOW DETAILS
  // ==========================================================================

  void _showReportDetails(
    BuildContext context,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,
      builder: (
        context,
      ) {
        return _ReportDetailsSheet(
          documentId:
              document.id,
          data:
              document.data(),
        );
      },
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final Map<String, dynamic> data =
        document.data();

    final String plantName =
        _string(
      data['plantName'],
    );

    final String scientificName =
        _string(
      data['scientificName'],
    );

    final String userName =
        _string(
      data['userDisplayName'],
    );

    final String email =
        _string(
      data['email'],
    );

    final String healthStatus =
        _string(
      data['healthStatus'],
    );

    final int healthScore =
        _int(
      data['healthScore'],
    ).clamp(
      0,
      100,
    );

    final String status =
        _string(
          data['status'],
        ).isEmpty
            ? 'pending'
            : _string(
                data['status'],
              ).toLowerCase();

    final String createdAt =
        _formatDate(
      data['createdAt'] ??
          data['generatedAt'],
    );

    final Color statusColor =
        _statusColor(
      status,
    );

    return Material(
      color:
          Theme.of(context)
              .colorScheme
              .surface,
      borderRadius:
          BorderRadius.circular(18),
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showReportDetails(
            context,
          );
        },
        child: Container(
          padding:
              const EdgeInsets.all(20),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  Theme.of(context)
                      .dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================================
              // TOP
              // ==================================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------------------------------
                  // ICON
                  // ----------------------------------------------------------------

                  Container(
                    width: 54,
                    height: 54,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .medical_services_rounded,
                      color:
                          AppColors.primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  // ----------------------------------------------------------------
                  // TITLE
                  // ----------------------------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          plantName.isEmpty
                              ? 'Plant Care Report'
                              : plantName,
                          style:
                              AppTextStyles.heading3,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

                        if (scientificName
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            scientificName,
                            style:
                                AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // ----------------------------------------------------------------
                  // STATUS
                  // ----------------------------------------------------------------

                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            statusColor.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style:
                            TextStyle(
                          color:
                              statusColor,
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 11,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================================
              // USER
              // ==================================================================

              if (userName.isNotEmpty ||
                  email.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons
                          .person_outline_rounded,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        userName.isNotEmpty
                            ? userName
                            : email,
                        style:
                            AppTextStyles.body,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (email.isNotEmpty &&
                  userName.isNotEmpty) ...[
                const SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        email,
                        style:
                            AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(
                height: 14,
              ),

              // ==================================================================
              // HEALTH + DATE
              // ==================================================================

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // ----------------------------------------------------------------
                  // HEALTH SCORE
                  // ----------------------------------------------------------------

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .health_and_safety_outlined,
                          size: 17,
                          color:
                              AppColors.primary,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          'Health: $healthScore%',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ----------------------------------------------------------------
                  // HEALTH STATUS
                  // ----------------------------------------------------------------

                  if (healthStatus
                      .isNotEmpty)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        color:
                            Theme.of(context)
                                .dividerColor
                                .withValues(
                              alpha: 0.08,
                            ),
                      ),
                      child: Text(
                        healthStatus,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                  // ----------------------------------------------------------------
                  // DATE
                  // ----------------------------------------------------------------

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      color:
                          Theme.of(context)
                              .dividerColor
                              .withValues(
                            alpha: 0.08,
                          ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          createdAt,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================================
              // VIEW
              // ==================================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Text(
                    'View Report',
                    style:
                        TextStyle(
                      color:
                          AppColors.primary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 18,
                    color:
                        AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DETAILS SHEET
// ============================================================================

class _ReportDetailsSheet
    extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const _ReportDetailsSheet({
    required this.documentId,
    required this.data,
  });

  @override
  State<_ReportDetailsSheet> createState() =>
      _ReportDetailsSheetState();
}

class _ReportDetailsSheetState
    extends State<_ReportDetailsSheet> {
  late String _status;

  bool _isUpdating = false;

  final CollectionReference<Map<String, dynamic>>
      _reportsCollection =
      FirebaseFirestore.instance.collection(
    'reports',
  );

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    final String storedStatus =
        _string(
      widget.data['status'],
    ).toLowerCase();

    _status =
        _isValidStatus(
          storedStatus,
        )
            ? storedStatus
            : 'pending';
  }

  // ==========================================================================
  // STRING
  // ==========================================================================

  String _string(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }

  // ==========================================================================
  // VALID STATUS
  // ==========================================================================

  bool _isValidStatus(
    String value,
  ) {
    return const [
      'pending',
      'reviewed',
      'resolved',
      'rejected',
    ].contains(value);
  }

  // ==========================================================================
  // UPDATE STATUS
  // ==========================================================================

  Future<void> _updateStatus(
    String status,
  ) async {
    if (_isUpdating) {
      return;
    }

    if (!_isValidStatus(status)) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _reportsCollection
          .doc(widget.documentId)
          .update({
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _status = status;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Report marked as ${_statusLabel(status)}.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _friendlyFirestoreError(
              error,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update report: $error',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================================
  // STATUS LABEL
  // ==========================================================================

  String _statusLabel(
    String status,
  ) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'reviewed':
        return 'Reviewed';

      case 'resolved':
        return 'Resolved';

      case 'rejected':
        return 'Rejected';

      default:
        return status;
    }
  }

  // ==========================================================================
  // FIRESTORE ERROR
  // ==========================================================================

  String _friendlyFirestoreError(
    FirebaseException error,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied. Please check Firestore security rules.';

      case 'not-found':
        return 'This report no longer exists.';

      case 'unavailable':
        return 'Firestore is temporarily unavailable.';

      case 'unauthenticated':
        return 'Your login session has expired.';

      default:
        return error.message ??
            'Unable to update the report.';
    }
  }

  // ==========================================================================
  // STRING LIST
  // ==========================================================================

  List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return <String>[];
    }

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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final Map<String, dynamic> data =
        widget.data;

    final String plantName =
        _string(
      data['plantName'],
    );

    final String scientificName =
        _string(
      data['scientificName'],
    );

    final String overview =
        _string(
      data['overview'] ??
          data['description'],
    );

    final String email =
        _string(
      data['email'],
    );

    final String userName =
        _string(
      data['userDisplayName'],
    );

    final String healthStatus =
        _string(
      data['healthStatus'],
    );

    final int healthScore =
        data['healthScore'] is num
            ? (data['healthScore']
                    as num)
                .round()
                .clamp(
                  0,
                  100,
                )
            : 0;

    final List<String> recommendations =
        _stringList(
      data['recommendations'],
    );

    final List<String> symptoms =
        _stringList(
      data['symptoms'],
    );

    final String sunlight =
        _string(
      data['sunlight'],
    );

    final String watering =
        _string(
      data['watering'],
    );

    final String soil =
        _string(
      data['soil'],
    );

    final String temperature =
        _string(
      data['temperature'],
    );

    final String humidity =
        _string(
      data['humidity'],
    );

    final String fertilizer =
        _string(
      data['fertilizer'],
    );

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Material(
        color:
            Theme.of(context)
                .scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================================
                // TITLE
                // ==================================================================

                Text(
                  plantName.isEmpty
                      ? 'Plant Care Report'
                      : plantName,
                  style:
                      AppTextStyles.heading1,
                ),

                if (scientificName
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    scientificName,
                    style:
                        AppTextStyles.subtitle,
                  ),
                ],

                const SizedBox(
                  height: 20,
                ),

                // ==================================================================
                // USER
                // ==================================================================

                if (userName.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.person_outline,
                    title:
                        'User',
                    value:
                        userName,
                  ),

                if (email.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.email_outlined,
                    title:
                        'Email',
                    value:
                        email,
                  ),

                // ==================================================================
                // HEALTH
                // ==================================================================

                _InfoTile(
                  icon:
                      Icons.health_and_safety_outlined,
                  title:
                      'Health Status',
                  value:
                      '${healthStatus.isEmpty ? 'Unknown' : healthStatus} • $healthScore%',
                ),

                // ==================================================================
                // OVERVIEW
                // ==================================================================

                if (overview.isNotEmpty)
                  _Section(
                    title:
                        'Overview',
                    child:
                        Text(
                      overview,
                      style:
                          AppTextStyles.body,
                    ),
                  ),

                // ==================================================================
                // CARE INFORMATION
                // ==================================================================

                if (sunlight.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.wb_sunny_outlined,
                    title:
                        'Sunlight',
                    value:
                        sunlight,
                  ),

                if (watering.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.water_drop_outlined,
                    title:
                        'Watering',
                    value:
                        watering,
                  ),

                if (soil.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.grass_outlined,
                    title:
                        'Soil',
                    value:
                        soil,
                  ),

                if (temperature.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.thermostat_outlined,
                    title:
                        'Temperature',
                    value:
                        temperature,
                  ),

                if (humidity.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.water_outlined,
                    title:
                        'Humidity',
                    value:
                        humidity,
                  ),

                if (fertilizer.isNotEmpty)
                  _InfoTile(
                    icon:
                        Icons.eco_outlined,
                    title:
                        'Fertilizer',
                    value:
                        fertilizer,
                  ),

                // ==================================================================
                // SYMPTOMS
                // ==================================================================

                if (symptoms.isNotEmpty)
                  _Section(
                    title:
                        'Symptoms',
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children:
                          symptoms.map(
                        (
                          symptom,
                        ) {
                          return Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 8,
                            ),
                            child:
                                Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  '• ',
                                ),
                                Expanded(
                                  child:
                                      Text(
                                    symptom,
                                    style:
                                        AppTextStyles.body,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                // ==================================================================
                // RECOMMENDATIONS
                // ==================================================================

                if (recommendations
                    .isNotEmpty)
                  _Section(
                    title:
                        'Recommendations',
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children:
                          recommendations.map(
                        (
                          item,
                        ) {
                          return Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 8,
                            ),
                            child:
                                Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Icon(
                                  Icons
                                      .check_circle_outline,
                                  size: 19,
                                  color:
                                      AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child:
                                      Text(
                                    item,
                                    style:
                                        AppTextStyles.body,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                // ==================================================================
                // ADMIN STATUS
                // ==================================================================

                _Section(
                  title:
                      'Admin Status',
                  child:
                      DropdownButtonFormField<
                          String>(
                    initialValue:
                        _status,
                    isExpanded:
                        true,
                    decoration:
                        const InputDecoration(
                      border:
                          OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    items:
                        const [
                      DropdownMenuItem(
                        value:
                            'pending',
                        child:
                            Text(
                          'Pending',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'reviewed',
                        child:
                            Text(
                          'Reviewed',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'resolved',
                        child:
                            Text(
                          'Resolved',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'rejected',
                        child:
                            Text(
                          'Rejected',
                        ),
                      ),
                    ],
                    onChanged:
                        _isUpdating
                            ? null
                            : (
                                String?
                                    value,
                              ) {
                                if (value !=
                                    null) {
                                  _updateStatus(
                                    value,
                                  );
                                }
                              },
                  ),
                ),

                // ==================================================================
                // LOADING
                // ==================================================================

                if (_isUpdating)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 12,
                    ),
                    child:
                        LinearProgressIndicator(),
                  ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// INFO TILE
// ============================================================================

class _InfoTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                AppColors.primary,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.subtitle,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  value,
                  style:
                      AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION
// ============================================================================

class _Section
    extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                AppTextStyles.heading3,
          ),
          const SizedBox(
            height: 8,
          ),
          child,
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY REPORTS
// ============================================================================

class _EmptyReportsView
    extends StatelessWidget {
  const _EmptyReportsView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
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
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .description_outlined,
                size: 45,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              'No Reports Yet',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'No plant-care reports have been generated yet.',
              style:
                  AppTextStyles.subtitle,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR VIEW
// ============================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 60,
              color:
                  Colors.red,
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              'Unable to Load Reports',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              message,
              style:
                  AppTextStyles.subtitle,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  onRetry,
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}