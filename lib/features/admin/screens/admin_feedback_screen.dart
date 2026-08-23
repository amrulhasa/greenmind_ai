import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../feedback/services/feedback_service.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({
    super.key,
  });

  @override
  State<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState
    extends State<AdminFeedbackScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String _searchQuery = '';

  bool _isDeleting = false;
  bool _isUpdatingStatus = false;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback Management',
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'User Feedback',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Review and manage feedback submitted by users.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 20,
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

                decoration:
                    InputDecoration(
                  hintText:
                      'Search feedback...',

                  prefixIcon:
                      const Icon(
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
                              icon:
                                  const Icon(
                                Icons
                                    .clear_rounded,
                              ),
                            )
                          : null,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // FIRESTORE
              // ==================================================

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('feedback')
                      .snapshots(),

                  builder: (
                    context,
                    snapshot,
                  ) {
                    // ==================================================
                    // LOADING
                    // ==================================================

                    if (snapshot
                            .connectionState ==
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
                        onRetry: () {
                          setState(() {});
                        },
                      );
                    }

                    final List<
                            QueryDocumentSnapshot<
                                Map<String,
                                    dynamic>>>
                        documents =
                        snapshot.data?.docs ??
                            [];

                    // ==================================================
                    // EMPTY
                    // ==================================================

                    if (documents.isEmpty) {
                      return const _EmptyView();
                    }

                    // ==================================================
                    // SORT
                    // ==================================================

                    final List<
                            QueryDocumentSnapshot<
                                Map<String,
                                    dynamic>>>
                        sortedDocuments =
                        List.from(documents);

                    sortedDocuments.sort(
                      (
                        a,
                        b,
                      ) {
                        final DateTime aDate =
                            _getTimestamp(
                          a.data()['createdAt'],
                        );

                        final DateTime bDate =
                            _getTimestamp(
                          b.data()['createdAt'],
                        );

                        return bDate.compareTo(
                          aDate,
                        );
                      },
                    );

                    // ==================================================
                    // SEARCH
                    // ==================================================

                    final List<
                            QueryDocumentSnapshot<
                                Map<String,
                                    dynamic>>>
                        filteredDocuments =
                        sortedDocuments
                            .where(
                      (document) {
                        final Map<String,
                                dynamic>
                            data =
                            document.data();

                        final String name =
                            _string(
                          data['name'],
                        );

                        final String email =
                            _string(
                          data['email'] ??
                              data['userEmail'],
                        );

                        final String userEmail =
                            _string(
                          data['userEmail'],
                        );

                        final String userId =
                            _string(
                          data['userId'],
                        );

                        final String message =
                            _string(
                          data['message'] ??
                              data['feedback'],
                        );

                        final String status =
                            _string(
                          data['status'],
                        );

                        final String subject =
                            _string(
                          data['subject'],
                        );

                        return name.contains(
                              _searchQuery,
                            ) ||
                            email.contains(
                              _searchQuery,
                            ) ||
                            userEmail.contains(
                              _searchQuery,
                            ) ||
                            userId.contains(
                              _searchQuery,
                            ) ||
                            message.contains(
                              _searchQuery,
                            ) ||
                            status.contains(
                              _searchQuery,
                            ) ||
                            subject.contains(
                              _searchQuery,
                            );
                      },
                    ).toList();

                    // ==================================================
                    // NO SEARCH RESULT
                    // ==================================================

                    if (filteredDocuments
                        .isEmpty) {
                      return const _NoSearchResult();
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

                      child:
                          ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(),

                        itemCount:
                            filteredDocuments
                                .length,

                        separatorBuilder:
                            (
                          context,
                          index,
                        ) =>
                                const SizedBox(
                          height: 12,
                        ),

                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final QueryDocumentSnapshot<
                                  Map<String,
                                      dynamic>>
                              document =
                              filteredDocuments[
                                  index];

                          return _FeedbackCard(
                            feedbackId:
                                document.id,

                            data:
                                document.data(),

                            onTap: () {
                              _showFeedbackDetails(
                                context,
                                document.id,
                                document.data(),
                              );
                            },

                            onDelete: () {
                              _confirmDeleteFeedback(
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

  String _string(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
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

    if (value is int) {
      return DateTime
          .fromMillisecondsSinceEpoch(
        value,
      );
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _confirmDeleteFeedback(
    BuildContext context,
    String feedbackId,
    Map<String, dynamic> data,
  ) async {
    if (_isDeleting) {
      return;
    }

    final String name =
        (data['name'] ??
                data['email'] ??
                data['userEmail'] ??
                'this user')
            .toString();

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete Feedback?',
          ),

          content: Text(
            'Are you sure you want to delete the feedback submitted by "$name"?\n\nThis action cannot be undone.',
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
                'Delete',
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

    await _deleteFeedback(
      context,
      feedbackId,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteFeedback(
    BuildContext context,
    String feedbackId,
  ) async {
    if (_isDeleting) {
      return;
    }

    final NavigatorState navigator =
        Navigator.of(context);
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    setState(() {
      _isDeleting = true;
    });

    try {
      await FeedbackService.deleteFeedback(
        feedbackId: feedbackId,
      );

      if (!mounted) {
        return;
      }

      navigator.maybePop();

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Feedback deleted successfully.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } on FirebaseException catch (
      error
    ) {
      if (!mounted) {
        return;
      }

      _showError(
        error.code == 'permission-denied'
            ? 'You do not have permission to delete feedback.'
            : 'Failed to delete feedback.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        'Failed to delete feedback. Please try again.',
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
  // STATUS UPDATE
  // ============================================================

  Future<void> _updateFeedbackStatus(
    BuildContext context,
    String feedbackId,
    String status,
  ) async {
    if (_isUpdatingStatus) {
      return;
    }

    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await FeedbackService.updateFeedbackStatus(
        feedbackId: feedbackId,
        status: status,
      );

      if (!mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Feedback status updated to ${status.toUpperCase()}.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } on FirebaseException catch (
      error
    ) {
      if (!mounted) {
        return;
      }

      _showError(
        error.code == 'permission-denied'
            ? 'You do not have permission to update feedback.'
            : 'Failed to update feedback status.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        'Failed to update feedback status.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showFeedbackDetails(
    BuildContext context,
    String feedbackId,
    Map<String, dynamic> data,
  ) {
    final String name =
        (data['name'] ??
                'Anonymous User')
            .toString();

    final String email =
        (data['email'] ??
                data['userEmail'] ??
                'Not provided')
            .toString();

    final String userId =
        (data['userId'] ?? '')
            .toString();

    final String subject =
        (data['subject'] ??
                'General Feedback')
            .toString();

    final String message =
        (data['message'] ??
                data['feedback'] ??
                'No message provided.')
            .toString();

    final String status =
        (data['status'] ??
                'pending')
            .toString()
            .toLowerCase();

    final dynamic rating =
        data['rating'];

    final DateTime createdAt =
        _getTimestamp(
      data['createdAt'],
    );

    showModalBottomSheet<void>(
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
                        radius: 28,

                        backgroundColor:
                            const Color(
                          0xFFE8F5E9,
                        ),

                        child: const Icon(
                          Icons
                              .feedback_outlined,
                          color:
                              Color(0xFF2E7D32),
                          size: 28,
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
                              name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              email,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _StatusBadge(
                        status: status,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // DETAILS
                  // ==================================================

                  _DetailRow(
                    icon: Icons
                        .fingerprint_rounded,
                    label: 'Feedback ID',
                    value: feedbackId,
                  ),

                  _DetailRow(
                    icon: Icons
                        .person_outline_rounded,
                    label: 'User ID',
                    value: userId.isEmpty
                        ? 'Not provided'
                        : userId,
                  ),

                  _DetailRow(
                    icon: Icons
                        .person_outline_rounded,
                    label: 'Name',
                    value: name,
                  ),

                  _DetailRow(
                    icon: Icons
                        .email_outlined,
                    label: 'Email',
                    value: email,
                  ),

                  _DetailRow(
                    icon: Icons
                        .subject_outlined,
                    label: 'Subject',
                    value: subject,
                  ),

                  _DetailRow(
                    icon: Icons
                        .flag_outlined,
                    label: 'Status',
                    value:
                        status.toUpperCase(),
                  ),

                  if (rating != null)
                    _DetailRow(
                      icon: Icons
                          .star_outline_rounded,
                      label: 'Rating',
                      value:
                          _formatRating(
                        rating,
                      ),
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

                  const SizedBox(
                    height: 6,
                  ),

                  // ==================================================
                  // STATUS UPDATE
                  // ==================================================

                  const Text(
                    'Update Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        _validStatusValue(
                      status,
                    ),

                    decoration:
                        InputDecoration(
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child:
                            Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'reviewed',
                        child:
                            Text('Reviewed'),
                      ),
                      DropdownMenuItem(
                        value: 'resolved',
                        child:
                            Text('Resolved'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child:
                            Text('Rejected'),
                      ),
                      DropdownMenuItem(
                        value: 'closed',
                        child:
                            Text('Closed'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child:
                            Text('Completed'),
                      ),
                    ],

                    onChanged:
                        _isUpdatingStatus
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                _updateFeedbackStatus(
                                  context,
                                  feedbackId,
                                  value,
                                );
                              },
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // MESSAGE
                  // ==================================================

                  const Text(
                    'Feedback Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(
                        alpha: 0.45,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),

                      border:
                          Border.all(
                        color: Theme.of(
                          context,
                        )
                            .dividerColor,
                      ),
                    ),

                    child: Text(
                      message.trim().isEmpty
                          ? 'No message provided.'
                          : message,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // DELETE
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
                                  _confirmDeleteFeedback(
                                    sheetContext,
                                    feedbackId,
                                    data,
                                  );
                                },

                      icon:
                          const Icon(
                        Icons
                            .delete_outline_rounded,
                        color:
                            Colors.red,
                      ),

                      label:
                          const Text(
                        'Delete Feedback',
                        style:
                            TextStyle(
                          color:
                              Colors.red,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      style:
                          OutlinedButton
                              .styleFrom(
                        side:
                            const BorderSide(
                          color:
                              Colors.red,
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
  // VALID STATUS
  // ============================================================

  String? _validStatusValue(
    String status,
  ) {
    const List<String> statuses = [
      'pending',
      'reviewed',
      'resolved',
      'rejected',
      'closed',
      'completed',
    ];

    if (statuses.contains(status)) {
      return status;
    }

    return 'pending';
  }

  // ============================================================
  // RATING
  // ============================================================

  String _formatRating(
    dynamic value,
  ) {
    if (value is num) {
      return '${value.toStringAsFixed(1)} / 5';
    }

    return value.toString();
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final String day =
        dateTime.day.toString().padLeft(
              2,
              '0',
            );

    final String month =
        dateTime.month.toString().padLeft(
              2,
              '0',
            );

    final String year =
        dateTime.year.toString();

    final String hour =
        dateTime.hour.toString().padLeft(
              2,
              '0',
            );

    final String minute =
        dateTime.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year $hour:$minute';
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }
}

// ================================================================
// FEEDBACK CARD
// ================================================================

class _FeedbackCard extends StatelessWidget {
  final String feedbackId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FeedbackCard({
    required this.feedbackId,
    required this.data,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        (data['name'] ??
                'Anonymous User')
            .toString();

    final String email =
        (data['email'] ??
                data['userEmail'] ??
                'No email')
            .toString();

    final String message =
        (data['message'] ??
                data['feedback'] ??
                'No message')
            .toString();

    final String status =
        (data['status'] ??
                'pending')
            .toString();

    final dynamic rating =
        data['rating'];

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
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              CircleAvatar(
                radius: 27,

                backgroundColor:
                    const Color(
                  0xFFE8F5E9,
                ),

                child:
                    const Icon(
                  Icons
                      .feedback_outlined,
                  color:
                      Color(0xFF2E7D32),
                  size: 27,
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
                      CrossAxisAlignment
                          .start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        _StatusBadge(
                          status: status,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      email,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      message,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    if (rating != null) ...[
                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .star_rounded,
                            size: 18,
                            color:
                                Colors.amber,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            _formatRating(
                              rating,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 4,
              ),

              // ==================================================
              // DELETE
              // ==================================================

              IconButton(
                tooltip:
                    'Delete feedback',

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
              // ARROW
              // ==================================================

              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 8,
                ),

                child:
                    Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRating(
    dynamic value,
  ) {
    if (value is num) {
      return '${value.toStringAsFixed(1)} / 5';
    }

    return value.toString();
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String normalized =
        status.toLowerCase().trim();

    final bool resolved =
        normalized == 'resolved' ||
            normalized == 'reviewed' ||
            normalized == 'completed';

    final bool rejected =
        normalized == 'rejected' ||
            normalized == 'closed';

    final Color color =
        resolved
            ? const Color(0xFF2E7D32)
            : rejected
                ? Colors.red
                : Colors.orange;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        normalized.toUpperCase(),

        style: TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 20,
            color:
                const Color(0xFF2E7D32),
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
                  const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY
// ================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons
                .feedback_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'No feedback yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'There are no user feedback records in Firestore yet.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// NO SEARCH RESULT
// ================================================================

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons
                .search_off_rounded,
            size: 56,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'No feedback found.',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'Try a different search term.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ERROR
// ================================================================

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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

            const Text(
              'Unable to load feedback.',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              error,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(
                Icons.refresh_rounded,
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