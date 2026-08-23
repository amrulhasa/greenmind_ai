import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../support/services/support_service.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({
    super.key,
  });

  @override
  State<AdminSupportScreen> createState() =>
      _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const Color _backgroundColor = Color(0xFFF5F9F5);
  static const Color _primaryColor = Color(0xFF2E7D32);
  static const Color _textColor = Color(0xFF172018);
  static const Color _secondaryTextColor = Color(0xFF68736B);
  static const Color _borderColor = Color(0xFFDCE5DD);

  static const List<String> _filterStatuses = <String>[
    'all',
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  static const List<String> _ticketStatuses = <String>[
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  // ============================================================
  // STATE
  // ============================================================

  String _filterStatus = 'all';

  bool _processing = false;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,

        leading: IconButton(
          tooltip: 'Back',
          onPressed: _goBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        title: const Text(
          'Support Tickets',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ==================================================
            // FILTER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                12,
              ),
              child: _buildFilter(),
            ),

            // ==================================================
            // TICKETS
            // ==================================================

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: SupportService.watchAllTickets(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<
                          QuerySnapshot<Map<String, dynamic>>>
                      snapshot,
                ) {
                  // ==================================================
                  // LOADING
                  // ==================================================

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _primaryColor,
                      ),
                    );
                  }

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (snapshot.hasError) {
                    debugPrint(
                      'ADMIN SUPPORT STREAM ERROR: '
                      '${snapshot.error}',
                    );

                    return _buildState(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to load tickets',
                      message:
                          'Please check your Firestore connection '
                          'and permissions, then try again.',
                      isError: true,
                    );
                  }

                  // ==================================================
                  // DOCUMENTS
                  // ==================================================

                  final List<
                          QueryDocumentSnapshot<
                              Map<String, dynamic>>>
                      documents =
                      List<
                          QueryDocumentSnapshot<
                              Map<String, dynamic>>>.from(
                    snapshot.data?.docs ?? <QueryDocumentSnapshot<
                        Map<String, dynamic>>>[],
                  );

                  // ==================================================
                  // SORT
                  // ==================================================

                  documents.sort(
                    (
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          a,
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          b,
                    ) {
                      final Timestamp? aCreatedAt =
                          _getTimestamp(a.data()['createdAt']);

                      final Timestamp? bCreatedAt =
                          _getTimestamp(b.data()['createdAt']);

                      if (aCreatedAt == null &&
                          bCreatedAt == null) {
                        return 0;
                      }

                      if (aCreatedAt == null) {
                        return 1;
                      }

                      if (bCreatedAt == null) {
                        return -1;
                      }

                      return bCreatedAt.compareTo(
                        aCreatedAt,
                      );
                    },
                  );

                  // ==================================================
                  // FILTER
                  // ==================================================

                  final List<
                          QueryDocumentSnapshot<
                              Map<String, dynamic>>>
                      filteredDocuments =
                      documents.where(
                    (
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          document,
                    ) {
                      if (_filterStatus == 'all') {
                        return true;
                      }

                      final String status = _normalizeStatus(
                        document.data()['status'],
                      );

                      return status == _filterStatus;
                    },
                  ).toList();

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (filteredDocuments.isEmpty) {
                    return _buildState(
                      icon: Icons.support_agent_outlined,
                      title: 'No support tickets',
                      message: _filterStatus == 'all'
                          ? 'There are no support tickets yet.'
                          : 'No ${_statusLabel(_filterStatus)} '
                              'tickets found.',
                    );
                  }

                  // ==================================================
                  // LIST
                  // ==================================================

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      32,
                    ),
                    itemCount: filteredDocuments.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return _buildTicketCard(
                        filteredDocuments[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACK
  // ============================================================

  void _goBack() {
    if (!mounted) {
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/admin');
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
          items: _filterStatuses.map(
            (String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  _statusLabel(status),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: _processing
              ? null
              : (String? value) {
                  if (value == null || !mounted) {
                    return;
                  }

                  setState(() {
                    _filterStatus = value;
                  });
                },
        ),
      ),
    );
  }

  // ============================================================
  // TICKET CARD
  // ============================================================

  Widget _buildTicketCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data();

    final String ticketId = document.id;

    final String subject = _getString(
      data['subject'],
      fallback: 'No subject',
    );

    final String message = _getString(
      data['message'],
    );

    final String category = _getString(
      data['category'],
      fallback: 'General',
    );

    final String status = _normalizeStatus(
      data['status'],
    );

    final String userEmail = _getString(
      data['userEmail'],
      fallback: 'Unknown user',
    );

    final Timestamp? createdAt = _getTimestamp(
      data['createdAt'],
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              _statusChip(status),
            ],
          ),

          const SizedBox(height: 10),

          // ======================================================
          // USER
          // ======================================================

          Row(
            children: <Widget>[
              const Icon(
                Icons.email_outlined,
                size: 15,
                color: _secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CATEGORY + DATE
          // ======================================================

          Row(
            children: <Widget>[
              const Icon(
                Icons.category_outlined,
                size: 15,
                color: _secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _secondaryTextColor,
                  ),
                ),
              ),
              if (createdAt != null) ...<Widget>[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _formatDateTime(createdAt),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A837C),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // ======================================================
          // MESSAGE
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.isEmpty
                  ? 'No message provided.'
                  : message,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF4E584F),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // ACTIONS
          // ======================================================

          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _processing
                      ? null
                      : () => _showStatusDialog(
                            ticketId,
                            status,
                          ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'Status',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: const BorderSide(
                      color: _primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                tooltip: 'Delete ticket',
                onPressed: _processing
                    ? null
                    : () => _confirmDelete(ticketId),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS DIALOG
  // ============================================================

  Future<void> _showStatusDialog(
    String ticketId,
    String currentStatus,
  ) async {
    String selectedStatus =
        _ticketStatuses.contains(currentStatus)
            ? currentStatus
            : 'open';

    final String? result = await showDialog<String>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Update Ticket Status',
              ),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _ticketStatuses.map(
                  (String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        _statusLabel(status),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (
                  String? value,
                ) {
                  if (value == null) {
                    return;
                  }

                  setDialogState(() {
                    selectedStatus = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(
                      selectedStatus,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted ||
        result == null ||
        result == currentStatus) {
      return;
    }

    await _updateStatus(
      ticketId,
      result,
    );
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateStatus(
    String ticketId,
    String status,
  ) async {
    if (_processing) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await SupportService.updateTicketStatus(
        ticketId: ticketId,
        status: status,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Ticket status updated successfully.',
      );
    } catch (error) {
      debugPrint(
        'UPDATE SUPPORT TICKET ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _confirmDelete(
    String ticketId,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete Ticket?',
          ),
          content: const Text(
            'This support ticket will be permanently deleted. '
            'This action cannot be undone.',
          ),
          actions: <Widget>[
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _deleteTicket(ticketId);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteTicket(
    String ticketId,
  ) async {
    if (_processing) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await SupportService.deleteTicket(
        ticketId: ticketId,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Support ticket deleted successfully.',
      );
    } catch (error) {
      debugPrint(
        'DELETE SUPPORT TICKET ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  // ============================================================
  // EMPTY / ERROR STATE
  // ============================================================

  Widget _buildState({
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50,
              color: isError
                  ? const Color(0xFFC62828)
                  : _primaryColor,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: _secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _statusForeground(status),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String _statusLabel(
    String status,
  ) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';

      case 'resolved':
        return 'Resolved';

      case 'closed':
        return 'Closed';

      case 'open':
        return 'Open';

      case 'all':
        return 'All Tickets';

      default:
        if (status.trim().isEmpty) {
          return 'Open';
        }

        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (String word) {
                if (word.isEmpty) {
                  return word;
                }

                return word[0].toUpperCase() +
                    word.substring(1).toLowerCase();
              },
            )
            .join(' ');
    }
  }

  // ============================================================
  // STATUS BACKGROUND
  // ============================================================

  Color _statusBackground(
    String status,
  ) {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFFFF3CD);

      case 'resolved':
        return const Color(0xFFE8F5E9);

      case 'closed':
        return const Color(0xFFECEFF1);

      case 'open':
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  // ============================================================
  // STATUS FOREGROUND
  // ============================================================

  Color _statusForeground(
    String status,
  ) {
    switch (status) {
      case 'in_progress':
        return const Color(0xFF8A6500);

      case 'resolved':
        return const Color(0xFF2E7D32);

      case 'closed':
        return const Color(0xFF546E7A);

      case 'open':
      default:
        return const Color(0xFF1565C0);
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(
    Timestamp timestamp,
  ) {
    final DateTime date = timestamp.toDate();

    final String day = date.day
        .toString()
        .padLeft(2, '0');

    final String month = date.month
        .toString()
        .padLeft(2, '0');

    final String year = date.year.toString();

    final String hour = date.hour
        .toString()
        .padLeft(2, '0');

    final String minute = date.minute
        .toString()
        .padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // ============================================================
  // TIMESTAMP HELPER
  // ============================================================

  Timestamp? _getTimestamp(
    Object? value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    return null;
  }

  // ============================================================
  // STRING HELPER
  // ============================================================

  String _getString(
    Object? value, {
    String fallback = '',
  }) {
    final String text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  // ============================================================
  // STATUS NORMALIZER
  // ============================================================

  String _normalizeStatus(
    Object? value,
  ) {
    final String status = value
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';

    if (_ticketStatuses.contains(status)) {
      return status;
    }

    return 'open';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
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
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(
    Object error,
  ) {
    final String text = error
        .toString()
        .toLowerCase();

    if (text.contains('permission-denied') ||
        text.contains('permission denied')) {
      return 'You do not have permission to perform this action.';
    }

    if (text.contains('network') ||
        text.contains('unavailable')) {
      return 'Network error. Please check your internet connection.';
    }

    if (text.contains('not-found') ||
        text.contains('not found')) {
      return 'The support ticket could not be found.';
    }

    return 'Something went wrong. Please try again.';
  }
}