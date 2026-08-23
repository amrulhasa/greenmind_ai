import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminLogsScreen extends StatelessWidget {
  const AdminLogsScreen({
    super.key,
  });

  static final CollectionReference<Map<String, dynamic>>
      _logsCollection =
      FirebaseFirestore.instance.collection('admin_logs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Admin Logs',
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _logsCollection
              .orderBy(
                'createdAt',
                descending: true,
              )
              .snapshots(),

          builder: (
            BuildContext context,
            AsyncSnapshot<
                    QuerySnapshot<Map<String, dynamic>>>
                snapshot,
          ) {
            // ====================================================
            // LOADING
            // ====================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (snapshot.hasError) {
              return _ErrorState(
                error: snapshot.error,
              );
            }

            // ====================================================
            // DOCUMENTS
            // ====================================================

            final List<
                    QueryDocumentSnapshot<
                        Map<String, dynamic>>>
                documents =
                snapshot.data?.docs ??
                    <QueryDocumentSnapshot<
                        Map<String, dynamic>>>[];

            // ====================================================
            // EMPTY
            // ====================================================

            if (documents.isEmpty) {
              return const _EmptyState();
            }

            // ====================================================
            // LOG LIST
            // ====================================================

            return RefreshIndicator(
              color: AppColors.primary,

              onRefresh: () async {
                await Future<void>.delayed(
                  const Duration(
                    milliseconds: 500,
                  ),
                );
              },

              child: ListView.builder(
                physics: const BouncingScrollPhysics(
                  parent:
                      AlwaysScrollableScrollPhysics(),
                ),

                padding: const EdgeInsets.all(
                  20,
                ),

                itemCount: documents.length,

                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  final Map<String, dynamic> data =
                      documents[index].data();

                  // ==================================================
                  // ACTION
                  // ==================================================

                  final String action =
                      _readString(
                    data,
                    'action',
                    fallback:
                        'Administrative Activity',
                  );

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================
                  //
                  // Support both:
                  // description
                  // details
                  //
                  // This makes the screen compatible with
                  // different versions of AdminLogService.
                  // ==================================================

                  final String description =
                      _readString(
                    data,
                    'description',
                    fallback: _readString(
                      data,
                      'details',
                    ),
                  );

                  // ==================================================
                  // ADMIN EMAIL
                  // ==================================================

                  final String adminEmail =
                      _readString(
                    data,
                    'adminEmail',
                    fallback: _readString(
                      data,
                      'email',
                      fallback:
                          'Unknown administrator',
                    ),
                  );

                  // ==================================================
                  // CATEGORY / MODULE
                  // ==================================================

                  final String category =
                      _readString(
                    data,
                    'category',
                    fallback: _readString(
                      data,
                      'module',
                    ),
                  );

                  // ==================================================
                  // CREATED AT
                  // ==================================================

                  final Timestamp? createdAt =
                      _readTimestamp(
                    data['createdAt'],
                  );

                  return _AdminLogCard(
                    action: action,
                    description: description,
                    adminEmail: adminEmail,
                    category: category,
                    timestamp: createdAt,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // READ STRING
  // ============================================================

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final dynamic value = data[key];

    if (value == null) {
      return fallback;
    }

    final String result = value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  // ============================================================
  // READ TIMESTAMP
  // ============================================================

  static Timestamp? _readTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    return null;
  }
}

// ==================================================================
// ADMIN LOG CARD
// ==================================================================

class _AdminLogCard extends StatelessWidget {
  const _AdminLogCard({
    required this.action,
    required this.description,
    required this.adminEmail,
    required this.category,
    required this.timestamp,
  });

  final String action;
  final String description;
  final String adminEmail;
  final String category;
  final Timestamp? timestamp;

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return 'Processing time...';
    }

    final DateTime date = timestamp.toDate();

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

    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

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
          // ==================================================
          // ICON
          // ==================================================

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // ==================================================
          // CONTENT
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // ACTION
                // ==================================================

                Text(
                  action,
                  style:
                      AppTextStyles.heading3,
                ),

                // ==================================================
                // CATEGORY
                // ==================================================

                if (category
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 6,
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
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
                        8,
                      ),
                    ),

                    child: Text(
                      category,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ),
                ],

                // ==================================================
                // DESCRIPTION
                // ==================================================

                if (description
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    description,
                    style:
                        AppTextStyles.body,
                  ),
                ],

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // ADMIN
                // ==================================================

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color:
                          Color(0xFF68736B),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Expanded(
                      child: Text(
                        adminEmail,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 11.5,
                          color:
                              Color(0xFF68736B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),

                // ==================================================
                // DATE
                // ==================================================

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color:
                          Color(0xFF68736B),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      _formatDate(
                        timestamp,
                      ),

                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            Color(0xFF68736B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 78,
              height: 78,

              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: const Icon(
                Icons.history_rounded,
                size: 38,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'No Admin Logs',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Administrative activities will appear here.',
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

// ==================================================================
// ERROR STATE
// ==================================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
  });

  final Object? error;

  @override
  Widget build(
    BuildContext context,
  ) {
    debugPrint(
      'ADMIN LOGS ERROR: $error',
    );

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              'Unable to load admin logs',
              style:
                  AppTextStyles.heading3,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Please check your Firestore permissions and try again.',
              style:
                  AppTextStyles.subtitle,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // RETRY
            // ==================================================

            OutlinedButton.icon(
              onPressed: () {
                // StreamBuilder automatically reconnects.
                // This button simply rebuilds this screen.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const AdminLogsScreen(),
                  ),
                );
              },

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}