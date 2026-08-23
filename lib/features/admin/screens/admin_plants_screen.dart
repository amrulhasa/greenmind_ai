import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminPlantsScreen extends StatefulWidget {
  const AdminPlantsScreen({
    super.key,
  });

  @override
  State<AdminPlantsScreen> createState() =>
      _AdminPlantsScreenState();
}

class _AdminPlantsScreenState
    extends State<AdminPlantsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String _searchQuery = '';

  bool _isDeleting = false;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Management',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Text(
                'Plant Scans',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                'View and manage plant identification and disease detection records.',
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // SEARCH
              // ==================================================

              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery =
                        value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      'Search plants or diseases...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery =
                                      '';
                                });
                              },
                              icon: const Icon(
                                Icons.clear_rounded,
                              ),
                            )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // FIRESTORE
              // ==================================================

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: _firestore
                      .collection(
                        'identifications',
                      )
                      .snapshots(),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    // ==================================================
                    // LOADING
                    // ==================================================

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    // ==================================================
                    // ERROR
                    // ==================================================

                    if (snapshot.hasError) {
                      return _ErrorView(
                        error:
                            snapshot.error.toString(),
                      );
                    }

                    // ==================================================
                    // DOCUMENTS
                    // ==================================================

                    final documents =
                        snapshot.data?.docs ?? [];

                    // ==================================================
                    // EMPTY
                    // ==================================================

                    if (documents.isEmpty) {
                      return const _EmptyPlantsView();
                    }

                    // ==================================================
                    // SORT
                    // ==================================================

                    final sortedDocuments =
                        [...documents];

                    sortedDocuments.sort(
                      (a, b) {
                        final aTime =
                            _getTimestamp(
                          a.data()['createdAt'],
                        );

                        final bTime =
                            _getTimestamp(
                          b.data()['createdAt'],
                        );

                        return bTime.compareTo(
                          aTime,
                        );
                      },
                    );

                    // ==================================================
                    // SEARCH
                    // ==================================================

                    final filteredPlants =
                        sortedDocuments.where(
                      (document) {
                        final data =
                            document.data();

                        final plantName =
                            _string(
                          data['plantName'],
                        );

                        final scientificName =
                            _string(
                          data['scientificName'],
                        );

                        final diseaseName =
                            _string(
                          data['diseaseName'],
                        );

                        final status =
                            _string(
                          data['status'],
                        );

                        final scanType =
                            _string(
                          data['scanType'],
                        );

                        final userId =
                            _string(
                          data['userId'],
                        );

                        final description =
                            _string(
                          data['description'],
                        );

                        final symptoms =
                            _string(
                          data['symptoms'],
                        );

                        return plantName.contains(
                              _searchQuery,
                            ) ||
                            scientificName.contains(
                              _searchQuery,
                            ) ||
                            diseaseName.contains(
                              _searchQuery,
                            ) ||
                            status.contains(
                              _searchQuery,
                            ) ||
                            scanType.contains(
                              _searchQuery,
                            ) ||
                            userId.contains(
                              _searchQuery,
                            ) ||
                            description.contains(
                              _searchQuery,
                            ) ||
                            symptoms.contains(
                              _searchQuery,
                            );
                      },
                    ).toList();

                    // ==================================================
                    // NO SEARCH RESULT
                    // ==================================================

                    if (filteredPlants.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 56,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            Text(
                              'No scans found.',
                              style:
                                  AppTextStyles.heading3,
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Try a different search term.',
                              style:
                                  AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      );
                    }

                    // ==================================================
                    // LIST
                    // ==================================================

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(
                            milliseconds: 300,
                          ),
                        );

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            filteredPlants.length,
                        separatorBuilder:
                            (
                          _,
                          _,
                        ) =>
                            const SizedBox(
                          height: 12,
                        ),
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final document =
                              filteredPlants[index];

                          return _PlantCard(
                            plantId:
                                document.id,
                            data:
                                document.data(),
                            onTap: () {
                              _showPlantDetails(
                                context,
                                document.id,
                                document.data(),
                              );
                            },
                            onDelete: () {
                              _confirmDeletePlant(
                                context,
                                document.id,
                                document.data(),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STRING
  // ============================================================

  String _string(
    dynamic value,
  ) {
    return (value ?? '')
        .toString()
        .toLowerCase();
  }

  // ============================================================
  // TIMESTAMP
  // ============================================================

  DateTime _getTimestamp(
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

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<void> _confirmDeletePlant(
    BuildContext context,
    String plantId,
    Map<String, dynamic> data,
  ) async {
    final bool isDisease =
        _isDiseaseScan(data);

    final String title =
        isDisease
            ? 'Remove Disease Detection?'
            : 'Remove Identification?';

    final String displayName =
        isDisease
            ? _getDiseaseName(data)
            : _getPlantName(data);

    if (_isDeleting) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  title,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "$displayName" from plant records?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _deletePlant(
      context,
      plantId,
      displayName,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deletePlant(
    BuildContext context,
    String plantId,
    String plantName,
  ) async {
    if (_isDeleting) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _firestore
          .collection('identifications')
          .doc(plantId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '"$plantName" removed successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              AppColors.primary,
          duration:
              const Duration(
            seconds: 3,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.code ==
                    'permission-denied'
                ? 'You do not have permission to remove this record.'
                : 'Failed to remove record. Please try again.',
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.red,
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ============================================================
  // SHOW DETAILS
  // ============================================================

  void _showPlantDetails(
    BuildContext context,
    String plantId,
    Map<String, dynamic> data,
  ) {
    final bool isDisease =
        _isDiseaseScan(data);

    final String plantName =
        _getPlantName(data);

    final String diseaseName =
        _getDiseaseName(data);

    final String scientificName =
        (data['scientificName'] ??
                'Not provided')
            .toString();

    final String userId =
        (data['userId'] ?? '')
            .toString();

    final String confidence =
        _formatConfidence(
      data['confidence'],
    );

    final String status =
        (data['status'] ??
                'unknown')
            .toString();

    final String description =
        (data['description'] ?? '')
            .toString();

    final String careTips =
        (data['careTips'] ?? '')
            .toString();

    final String symptoms =
        (data['symptoms'] ?? '')
            .toString();

    final String treatment =
        (data['treatment'] ?? '')
            .toString();

    final String prevention =
        (data['prevention'] ?? '')
            .toString();

    final String scanType =
        isDisease
            ? 'Disease Detection'
            : 'Plant Identification';

    final bool isHealthy =
        data['isHealthy'] == true;

    final DateTime createdAt =
        _getTimestamp(
      data['createdAt'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (
        sheetContext,
      ) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            isDisease
                                ? Colors.orange
                                    .withValues(
                                    alpha: 0.12,
                                  )
                                : AppColors
                                    .primary
                                    .withValues(
                                    alpha: 0.12,
                                  ),
                        child: Icon(
                          isDisease
                              ? Icons
                                  .coronavirus_outlined
                              : Icons
                                  .eco_rounded,
                          color:
                              isDisease
                                  ? Colors.orange
                                  : AppColors
                                      .primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              isDisease
                                  ? diseaseName
                                  : plantName,
                              style:
                                  AppTextStyles
                                      .heading2,
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              scanType,
                              style:
                                  AppTextStyles
                                      .subtitle,
                            ),
                          ],
                        ),
                      ),

                      _HealthBadge(
                        isHealthy:
                            isHealthy,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // DETAILS
                  // ==================================================

                  _DetailRow(
                    icon:
                        Icons.fingerprint_rounded,
                    label: 'ID',
                    value: plantId,
                  ),

                  _DetailRow(
                    icon:
                        Icons.person_outline_rounded,
                    label: 'User ID',
                    value:
                        userId.isEmpty
                            ? 'Not provided'
                            : userId,
                  ),

                  _DetailRow(
                    icon:
                        Icons.category_outlined,
                    label: 'Scan Type',
                    value: scanType,
                  ),

                  if (!isDisease)
                    _DetailRow(
                      icon:
                          Icons.eco_outlined,
                      label: 'Plant',
                      value: plantName,
                    ),

                  if (!isDisease)
                    _DetailRow(
                      icon:
                          Icons.science_outlined,
                      label: 'Scientific',
                      value:
                          scientificName,
                    ),

                  if (isDisease)
                    _DetailRow(
                      icon:
                          Icons.coronavirus_outlined,
                      label: 'Disease',
                      value:
                          diseaseName,
                    ),

                  _DetailRow(
                    icon:
                        Icons.analytics_outlined,
                    label: 'Confidence',
                    value: confidence,
                  ),

                  _DetailRow(
                    icon:
                        Icons.info_outline_rounded,
                    label: 'Status',
                    value: status,
                  ),

                  _DetailRow(
                    icon: Icons
                        .health_and_safety_outlined,
                    label: 'Health',
                    value: isHealthy
                        ? 'Healthy'
                        : 'Diseased / Unhealthy',
                  ),

                  if (createdAt
                          .millisecondsSinceEpoch >
                      0)
                    _DetailRow(
                      icon: Icons
                          .schedule_outlined,
                      label: 'Created',
                      value:
                          _formatDateTime(
                        createdAt,
                      ),
                    ),

                  // ==================================================
                  // DISEASE DETAILS
                  // ==================================================

                  if (isDisease &&
                      symptoms
                          .trim()
                          .isNotEmpty)
                    _DetailRow(
                      icon: Icons
                          .sick_outlined,
                      label: 'Symptoms',
                      value: symptoms,
                    ),

                  if (isDisease &&
                      treatment
                          .trim()
                          .isNotEmpty)
                    _DetailRow(
                      icon: Icons
                          .medical_services_outlined,
                      label: 'Treatment',
                      value: treatment,
                    ),

                  if (isDisease &&
                      prevention
                          .trim()
                          .isNotEmpty)
                    _DetailRow(
                      icon: Icons
                          .shield_outlined,
                      label: 'Prevention',
                      value: prevention,
                    ),

                  if (description
                      .trim()
                      .isNotEmpty)
                    _DetailRow(
                      icon: Icons
                          .description_outlined,
                      label: 'Description',
                      value: description,
                    ),

                  if (careTips
                      .trim()
                      .isNotEmpty)
                    _DetailRow(
                      icon: Icons
                          .tips_and_updates_outlined,
                      label: 'Care Tips',
                      value: careTips,
                    ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ==================================================
                  // REMOVE
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _isDeleting
                              ? null
                              : () {
                                  _confirmDeletePlant(
                                    sheetContext,
                                    plantId,
                                    data,
                                  );
                                },
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.red,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .delete_outline_rounded,
                              color:
                                  Colors.red,
                            ),
                      label: Text(
                        _isDeleting
                            ? 'Removing...'
                            : 'Remove Record',
                        style:
                            const TextStyle(
                          color:
                              Colors.red,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.red,
                        side:
                            const BorderSide(
                          color: Color(
                            0xFFE57373,
                          ),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // CLOSE
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();
                      },
                      style:
                          OutlinedButton
                              .styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Close',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // IS DISEASE
  // ============================================================

  bool _isDiseaseScan(
    Map<String, dynamic> data,
  ) {
    final scanType =
        (data['scanType'] ?? '')
            .toString()
            .toLowerCase();

    return scanType ==
            'disease_detection' ||
        data.containsKey('diseaseName');
  }

  // ============================================================
  // PLANT NAME
  // ============================================================

  String _getPlantName(
    Map<String, dynamic> data,
  ) {
    final value =
        (data['plantName'] ?? '')
            .toString()
            .trim();

    return value.isEmpty
        ? 'Unknown Plant'
        : value;
  }

  // ============================================================
  // DISEASE NAME
  // ============================================================

  String _getDiseaseName(
    Map<String, dynamic> data,
  ) {
    final value =
        (data['diseaseName'] ??
                data['plantName'] ??
                '')
            .toString()
            .trim();

    return value.isEmpty
        ? 'Unknown Disease'
        : value;
  }

  // ============================================================
  // CONFIDENCE
  // ============================================================

  String _formatConfidence(
    dynamic value,
  ) {
    if (value == null) {
      return 'Not provided';
    }

    if (value is num) {
      final double number =
          value.toDouble();

      if (number <= 1) {
        return '${(number * 100).toStringAsFixed(1)}%';
      }

      return '${number.toStringAsFixed(1)}%';
    }

    return value.toString();
  }

  // ============================================================
  // DATE TIME
  // ============================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final String day =
        dateTime.day
            .toString()
            .padLeft(2, '0');

    final String month =
        dateTime.month
            .toString()
            .padLeft(2, '0');

    final String year =
        dateTime.year.toString();

    final String hour =
        dateTime.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

// ================================================================
// PLANT CARD
// ================================================================

class _PlantCard extends StatelessWidget {
  final String plantId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlantCard({
    required this.plantId,
    required this.data,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDisease =
        _isDiseaseScan();

    final String title =
        isDisease
            ? _getDiseaseName()
            : _getPlantName();

    final String subtitle =
        isDisease
            ? 'Disease Detection'
            : _getScientificName();

    final String confidence =
        _formatConfidence(
      data['confidence'],
    );

    final String status =
        (data['status'] ??
                'unknown')
            .toString();

    final bool isHealthy =
        data['isHealthy'] == true;

    return Material(
      color: Theme.of(context)
          .colorScheme
          .surface,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context)
                  .dividerColor,
            ),
          ),
          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              CircleAvatar(
                radius: 28,
                backgroundColor:
                    isDisease
                        ? Colors.orange
                            .withValues(
                            alpha: 0.10,
                          )
                        : AppColors
                            .primary
                            .withValues(
                            alpha: 0.10,
                          ),
                child: Icon(
                  isDisease
                      ? Icons
                          .coronavirus_outlined
                      : Icons.eco_rounded,
                  color:
                      isDisease
                          ? Colors.orange
                          : AppColors.primary,
                  size: 29,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // INFO
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.heading3,
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.body,
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .analytics_outlined,
                          size: 15,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          confidence,
                          style:
                              AppTextStyles.body,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ==================================================
              // HEALTH
              // ==================================================

              _HealthBadge(
                isHealthy:
                    isHealthy,
              ),

              const SizedBox(
                width: 4,
              ),

              // ==================================================
              // DELETE
              // ==================================================

              IconButton(
                tooltip:
                    'Remove record',
                onPressed:
                    onDelete,
                icon:
                    const Icon(
                  Icons
                      .delete_outline_rounded,
                  color:
                      Colors.red,
                  size: 22,
                ),
              ),

              // ==================================================
              // DETAILS
              // ==================================================

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isDiseaseScan() {
    final scanType =
        (data['scanType'] ?? '')
            .toString()
            .toLowerCase();

    return scanType ==
            'disease_detection' ||
        data.containsKey(
          'diseaseName',
        );
  }

  String _getPlantName() {
    final value =
        (data['plantName'] ?? '')
            .toString()
            .trim();

    return value.isEmpty
        ? 'Unknown Plant'
        : value;
  }

  String _getDiseaseName() {
    final value =
        (data['diseaseName'] ??
                data['plantName'] ??
                '')
            .toString()
            .trim();

    return value.isEmpty
        ? 'Unknown Disease'
        : value;
  }

  String _getScientificName() {
    final value =
        (data['scientificName'] ??
                '')
            .toString()
            .trim();

    return value.isEmpty
        ? 'Unknown species'
        : value;
  }

  String _formatConfidence(
    dynamic value,
  ) {
    if (value == null) {
      return 'N/A';
    }

    if (value is num) {
      final double number =
          value.toDouble();

      if (number <= 1) {
        return '${(number * 100).toStringAsFixed(1)}%';
      }

      return '${number.toStringAsFixed(1)}%';
    }

    return value.toString();
  }
}

// ================================================================
// HEALTH BADGE
// ================================================================

class _HealthBadge
    extends StatelessWidget {
  final bool isHealthy;

  const _HealthBadge({
    required this.isHealthy,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: isHealthy
            ? AppColors.primary
                .withValues(
                alpha: 0.12,
              )
            : Colors.red.withValues(
                alpha: 0.10,
              ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        isHealthy
            ? 'HEALTHY'
            : 'UNHEALTHY',
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w700,
          color: isHealthy
              ? AppColors.primary
              : Colors.red,
        ),
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          SizedBox(
            width: 90,
            child: Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              value,
              style:
                  AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY VIEW
// ================================================================

class _EmptyPlantsView
    extends StatelessWidget {
  const _EmptyPlantsView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'No plant scans',
            style:
                AppTextStyles.heading3,
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'There are no plant identification or disease detection records in Firestore yet.',
            style:
                AppTextStyles.subtitle,
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

class _ErrorView
    extends StatelessWidget {
  final String error;

  const _ErrorView({
    required this.error,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 56,
              color: Colors.red,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'Unable to load plants.',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}