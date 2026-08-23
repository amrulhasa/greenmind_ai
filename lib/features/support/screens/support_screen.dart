import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({
    super.key,
  });

  @override
  State<SupportScreen> createState() =>
      _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _subjectController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _selectedCategory = 'General';

  bool _submitting = false;

  // ============================================================
  // CATEGORIES
  // ============================================================

  static const List<String> _categories = [
    'General',
    'Account',
    'Plant Report',
    'AI Diagnosis',
    'Technical Issue',
    'Other',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE TICKET
  // ============================================================

  Future<void> _createTicket() async {
    if (_submitting) {
      return;
    }

    final String subject =
        _subjectController.text.trim();

    final String message =
        _messageController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (subject.isEmpty) {
      _showMessage(
        'Please enter a subject.',
      );
      return;
    }

    if (subject.length < 3) {
      _showMessage(
        'Subject must contain at least 3 characters.',
      );
      return;
    }

    if (message.isEmpty) {
      _showMessage(
        'Please describe your problem.',
      );
      return;
    }

    if (message.length < 5) {
      _showMessage(
        'Message must contain at least 5 characters.',
      );
      return;
    }

    // ----------------------------------------------------------
    // START
    // ----------------------------------------------------------

    setState(() {
      _submitting = true;
    });

    try {
      await SupportService.createTicket(
        subject: subject,
        message: message,
        category: _selectedCategory,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // RESET
      // --------------------------------------------------------

      _subjectController.clear();
      _messageController.clear();

      setState(() {
        _selectedCategory = 'General';
        _submitting = false;
      });

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      _showSuccessMessage(
        'Your support ticket has been submitted.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
      });

      _showMessage(
        _cleanErrorMessage(error),
      );
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final String text =
        error.toString().toLowerCase();

    if (text.contains('logged in') ||
        text.contains('unauthenticated')) {
      return 'Please login again and try again.';
    }

    if (text.contains('permission-denied') ||
        text.contains('permission denied')) {
      return 'You do not have permission to create a support ticket.';
    }

    if (text.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Unable to submit your ticket. Please try again.';
  }

  // ============================================================
  // SUCCESS MESSAGE
  // ============================================================

  void _showSuccessMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F9F5),
        foregroundColor: const Color(0xFF172018),

        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        centerTitle: true,

        title: const Text(
          'Support',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,

                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.support_agent_rounded,
                        size: 36,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'How Can We Help?',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172018),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create a support ticket and '
                      'our administration team will '
                      'review your request.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF68736B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // CREATE TICKET TITLE
              // ==================================================

              const Text(
                'Create Support Ticket',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CATEGORY
              // ==================================================

              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,

                decoration:
                    _inputDecoration(
                  hint: 'Select category',
                  icon: Icons.category_outlined,
                ),

                items: _categories
                    .map(
                      (String category) =>
                          DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),

                onChanged: _submitting
                    ? null
                    : (String? value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // SUBJECT
              // ==================================================

              const Text(
                'Subject',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _subjectController,
                enabled: !_submitting,
                maxLength: 100,
                textCapitalization:
                    TextCapitalization.sentences,

                decoration: _inputDecoration(
                  hint: 'What do you need help with?',
                  icon: Icons.subject_rounded,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // MESSAGE
              // ==================================================

              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _messageController,
                enabled: !_submitting,

                minLines: 5,
                maxLines: 8,
                maxLength: 1000,

                textCapitalization:
                    TextCapitalization.sentences,

                textInputAction:
                    TextInputAction.newline,

                decoration: _inputDecoration(
                  hint:
                      'Describe your problem or question...',
                  icon: Icons.message_outlined,
                  alignIconTop: true,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SUBMIT
              // ==================================================

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed:
                      _submitting
                          ? null
                          : _createTicket,

                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                        ),

                  label: Text(
                    _submitting
                        ? 'Submitting...'
                        : 'Submit Ticket',

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,

                    disabledBackgroundColor:
                        const Color(0xFF81A784),

                    disabledForegroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // MY TICKETS
              // ==================================================

              const Text(
                'My Support Tickets',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 14),

              StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    SupportService.watchMyTickets(),

                builder: (
                  BuildContext context,
                  AsyncSnapshot<
                          QuerySnapshot<
                              Map<String, dynamic>>>
                      snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildStateCard(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to load tickets',
                      message:
                          'Please try again later.',
                    );
                  }

                  final List<
                          QueryDocumentSnapshot<
                              Map<String, dynamic>>>
                      documents =
                      snapshot.data?.docs ?? [];

                  if (documents.isEmpty) {
                    return _buildStateCard(
                      icon:
                          Icons.support_agent_outlined,
                      title: 'No tickets yet',
                      message:
                          'Your support tickets will appear here.',
                    );
                  }

                  documents.sort(
                    (
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          a,
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          b,
                    ) {
                      final Timestamp? aTime =
                          a.data()['createdAt']
                              as Timestamp?;

                      final Timestamp? bTime =
                          b.data()['createdAt']
                              as Timestamp?;

                      if (aTime == null &&
                          bTime == null) {
                        return 0;
                      }

                      if (aTime == null) {
                        return 1;
                      }

                      if (bTime == null) {
                        return -1;
                      }

                      return bTime.compareTo(aTime);
                    },
                  );

                  return Column(
                    children: documents
                        .map(
                          (
                            QueryDocumentSnapshot<
                                    Map<String, dynamic>>
                                document,
                          ) =>
                              _buildTicketCard(
                            document,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFF8A938C),
      ),

      filled: true,
      fillColor: Colors.white,

      prefixIcon: alignIconTop
          ? Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 90,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
              ),
            )
          : Icon(
              icon,
              color: const Color(0xFF2E7D32),
            ),

      contentPadding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E7E1),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E7E1),
        ),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E7E1),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // TICKET CARD
  // ============================================================

  Widget _buildTicketCard(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
  ) {
    final Map<String, dynamic> data =
        document.data();

    final String subject =
        data['subject']?.toString() ??
            'No subject';

    final String message =
        data['message']?.toString() ??
            '';

    final String category =
        data['category']?.toString() ??
            'General';

    final String status =
        data['status']?.toString() ??
            'open';

    final Timestamp? createdAt =
        data['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172018),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              _statusChip(status),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF68736B),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 15,
                color: Color(0xFF68736B),
              ),

              const SizedBox(width: 5),

              Text(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF68736B),
                ),
              ),

              const Spacer(),

              if (createdAt != null)
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF7A837C),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    final String label =
        _statusLabel(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _statusForeground(status),
        ),
      ),
    );
  }

  // ============================================================
  // STATE CARD
  // ============================================================

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF2E7D32),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172018),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF68736B),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';

      case 'resolved':
        return 'Resolved';

      case 'closed':
        return 'Closed';

      case 'open':
      default:
        return 'Open';
    }
  }

  Color _statusBackground(String status) {
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

  Color _statusForeground(String status) {
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

  String _formatDate(Timestamp timestamp) {
    final DateTime date =
        timestamp.toDate();

    final String day =
        date.day.toString().padLeft(2, '0');

    final String month =
        date.month.toString().padLeft(2, '0');

    final String year =
        date.year.toString();

    return '$day/$month/$year';
  }
}