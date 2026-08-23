import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/announcement_badge_provider.dart';

// ============================================================
// ANNOUNCEMENTS SCREEN
// ============================================================

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({
    super.key,
  });

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

// ============================================================
// STATE
// ============================================================

class _AnnouncementsScreenState
    extends ConsumerState<AnnouncementsScreen> {
  static final CollectionReference<
      Map<String, dynamic>> _announcementsCollection =
      FirebaseFirestore.instance.collection(
    'announcements',
  );

  bool _markedAsRead = false;

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9F5),

      appBar: _buildAppBar(
        context,
      ),

      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _announcementsCollection
              .where(
                'isPublished',
                isEqualTo: true,
              )
              .snapshots(),

          builder: (
            BuildContext context,
            AsyncSnapshot<
                    QuerySnapshot<
                        Map<String, dynamic>>>
                snapshot,
          ) {
            // --------------------------------------------------
            // LOADING
            // --------------------------------------------------

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                      Color(0xFF2E7D32),
                ),
              );
            }

            // --------------------------------------------------
            // ERROR
            // --------------------------------------------------

            if (snapshot.hasError) {
              return _buildErrorState(
                snapshot.error,
              );
            }

            // --------------------------------------------------
            // DOCUMENTS
            // --------------------------------------------------

            final List<
                    QueryDocumentSnapshot<
                        Map<String, dynamic>>>
                documents =
                List<
                    QueryDocumentSnapshot<
                        Map<String, dynamic>>>.from(
              snapshot.data?.docs ?? [],
            );

            // --------------------------------------------------
            // SORT NEWEST FIRST
            // --------------------------------------------------

            documents.sort(
              (
                QueryDocumentSnapshot<
                        Map<String, dynamic>>
                    a,
                QueryDocumentSnapshot<
                        Map<String, dynamic>>
                    b,
              ) {
                final Timestamp? dateA =
                    _getTimestamp(
                  a.data()['createdAt'],
                );

                final Timestamp? dateB =
                    _getTimestamp(
                  b.data()['createdAt'],
                );

                if (dateA == null &&
                    dateB == null) {
                  return 0;
                }

                if (dateA == null) {
                  return 1;
                }

                if (dateB == null) {
                  return -1;
                }

                return dateB.compareTo(
                  dateA,
                );
              },
            );

            // --------------------------------------------------
            // MARK CURRENT ANNOUNCEMENTS AS READ
            // --------------------------------------------------

            if (!_markedAsRead &&
                documents.isNotEmpty) {
              _markedAsRead = true;

              final List<String> ids =
                  documents
                      .map(
                        (
                          QueryDocumentSnapshot<
                                  Map<String, dynamic>>
                              document,
                        ) =>
                            document.id,
                      )
                      .toList();

              Future.microtask(
                () {
                  return ref
                      .read(
                        announcementBadgeProvider
                            .notifier,
                      )
                      .markAllAsRead(
                    ids,
                  );
                },
              );
            }

            // --------------------------------------------------
            // EMPTY
            // --------------------------------------------------

            if (documents.isEmpty) {
              return _buildEmptyState();
            }

            // --------------------------------------------------
            // LIST
            // --------------------------------------------------

            return RefreshIndicator(
              color:
                  const Color(0xFF2E7D32),

              backgroundColor:
                  Colors.white,

              onRefresh: () async {
                await Future<void>.delayed(
                  const Duration(
                    milliseconds: 350,
                  ),
                );

                if (mounted) {
                  setState(() {
                    _markedAsRead = false;
                  });
                }
              },

              child: ListView.builder(
                physics:
                    const BouncingScrollPhysics(
                  parent:
                      AlwaysScrollableScrollPhysics(),
                ),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  32,
                ),

                itemCount:
                    documents.length,

                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  return _AnnouncementCard(
                    document:
                        documents[index],
                    index: index,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // APP BAR
  // ==========================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,

      backgroundColor:
          const Color(0xFFF5F9F5),

      foregroundColor:
          const Color(0xFF172018),

      leading: IconButton(
        tooltip: 'Back',

        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },

        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
      ),

      centerTitle: true,

      title: const Text(
        'Announcements',
        style: TextStyle(
          fontSize: 19,
          fontWeight:
              FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ==========================================================
  // TIMESTAMP
  // ==========================================================

  static Timestamp? _getTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    return null;
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 86,
              height: 86,

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
                Icons.campaign_outlined,
                size: 43,
                color:
                    Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No announcements',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172018),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'There are no announcements available right now.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                    Color(0xFF68736B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState(
    Object? error,
  ) {
    debugPrint(
      'ANNOUNCEMENTS ERROR: $error',
    );

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
                    const Color(
                  0xFFFFEBEE,
                ),

                borderRadius:
                    BorderRadius.circular(
                  25,
                ),
              ),

              child: const Icon(
                Icons.error_outline_rounded,
                size: 41,
                color:
                    Color(0xFFC62828),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Unable to load announcements',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172018),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Please check your connection and try again.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                    Color(0xFF68736B),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _markedAsRead = false;
                });
              },

              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),

              label: const Text(
                'Retry',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2E7D32,
                ),

                foregroundColor:
                    Colors.white,

                elevation: 0,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
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

// ============================================================
// ANNOUNCEMENT CARD
// ============================================================

class _AnnouncementCard
    extends StatelessWidget {
  const _AnnouncementCard({
    required this.document,
    required this.index,
  });

  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  final int index;

  @override
  Widget build(
    BuildContext context,
  ) {
    final Map<String, dynamic> data =
        document.data();

    final String title =
        data['title']?.toString() ??
            'Announcement';

    final String message =
        data['message']?.toString() ??
            '';

    final Timestamp? createdAt =
        data['createdAt'] is Timestamp
            ? data['createdAt']
                as Timestamp
            : null;

    final bool isLatest =
        index == 0;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: isLatest
              ? const Color(
                  0xFFCDE5CF,
                )
              : const Color(
                  0xFFDCE5DD,
                ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.035,
            ),

            blurRadius: 16,

            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 46,
                height: 46,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8F5E9,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: const Icon(
                  Icons.campaign_rounded,
                  color:
                      Color(0xFF2E7D32),
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(
                                0xFF172018,
                              ),
                            ),
                          ),
                        ),

                        if (isLatest)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFE8F5E9,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child:
                                const Text(
                              'LATEST',
                              style:
                                  TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(
                                  0xFF2E7D32,
                                ),
                                letterSpacing:
                                    0.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      isLatest
                          ? 'Latest announcement'
                          : 'Announcement',
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(
                          0xFF6D786F,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // ====================================================
          // MESSAGE
          // ====================================================

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(14),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF7FAF7,
              ),

              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),

            child: Text(
              message,

              style:
                  const TextStyle(
                fontSize: 13,
                height: 1.55,
                color:
                    Color(0xFF4E584F),
              ),
            ),
          ),

          // ====================================================
          // DATE
          // ====================================================

          if (createdAt != null) ...[
            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color:
                      Color(0xFF68736B),
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  _formatDateTime(
                    createdAt,
                  ),

                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        Color(0xFF7A837C),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  static String _formatDateTime(
    Timestamp timestamp,
  ) {
    final DateTime date =
        timestamp.toDate();

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
}