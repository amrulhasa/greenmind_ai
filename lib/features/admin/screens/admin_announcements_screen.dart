import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends State<AdminAnnouncementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _processing = false;

  CollectionReference<Map<String, dynamic>>
      get _announcementsCollection =>
          _firestore.collection('announcements');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F9F5),
        foregroundColor: const Color(0xFF172018),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Create announcement',
            onPressed:
                _processing ? null : _showCreateAnnouncementDialog,
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _announcementsCollection
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              debugPrint(
                'ANNOUNCEMENT STREAM ERROR: ${snapshot.error}',
              );

              return _buildState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load announcements',
                message:
                    'Please check your Firestore connection and permissions.',
              );
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              itemCount: documents.length,
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                return _buildAnnouncementCard(
                  documents[index],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _processing ? null : _showCreateAnnouncementDialog,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Announcement'),
      ),
    );
  }

  // ============================================================
  // ANNOUNCEMENT CARD
  // ============================================================

  Widget _buildAnnouncementCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data();

    final String title = _readString(
      data['title'],
      fallback: 'Untitled announcement',
    );

    final String message = _readString(data['message']);

    final bool isPublished = data['isPublished'] == true;

    final Timestamp? createdAt =
        data['createdAt'] is Timestamp
            ? data['createdAt'] as Timestamp
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCE5DD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172018),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _publicationChip(isPublished),
            ],
          ),

          const SizedBox(height: 12),

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
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF4E584F),
              ),
            ),
          ),

          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFF68736B),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A837C),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _processing
                      ? null
                      : () => _togglePublished(
                            document.id,
                            isPublished,
                          ),
                  icon: Icon(
                    isPublished
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 17,
                  ),
                  label: Text(
                    isPublished ? 'Unpublish' : 'Publish',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(
                      color: Color(0xFF2E7D32),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                tooltip: 'Delete announcement',
                onPressed: _processing
                    ? null
                    : () => _confirmDelete(document.id),
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
  // PUBLICATION CHIP
  // ============================================================

  Widget _publicationChip(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isPublished
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPublished
              ? const Color(0xFF2E7D32)
              : const Color(0xFF546E7A),
        ),
      ),
    );
  }

  // ============================================================
  // CREATE ANNOUNCEMENT
  // ============================================================

  Future<void> _showCreateAnnouncementDialog() async {
    final TextEditingController titleController =
        TextEditingController();

    final TextEditingController messageController =
        TextEditingController();

    bool publishImmediately = true;

    try {
      final bool? created = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (
              BuildContext context,
              StateSetter setDialogState,
            ) {
              return AlertDialog(
                title: const Text('Create Announcement'),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText:
                              'Enter announcement title',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: messageController,
                        minLines: 4,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText:
                              'Enter announcement message',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Publish immediately',
                        ),
                        subtitle: const Text(
                          'Published announcements can be shown to users.',
                        ),
                        value: publishImmediately,
                        onChanged: (bool value) {
                          setDialogState(() {
                            publishImmediately = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      final String title =
                          titleController.text.trim();

                      final String message =
                          messageController.text.trim();

                      if (title.isEmpty || message.isEmpty) {
                        ScaffoldMessenger.of(dialogContext)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Title and message are required.',
                              ),
                            ),
                          );
                        return;
                      }

                      try {
                        await _announcementsCollection.add({
                          'title': title,
                          'message': message,
                          'isPublished': publishImmediately,
                          'createdAt':
                              FieldValue.serverTimestamp(),
                        });

                        if (!dialogContext.mounted) {
                          return;
                        }

                        Navigator.of(dialogContext).pop(true);
                      } catch (error) {
                        debugPrint(
                          'CREATE ANNOUNCEMENT ERROR: $error',
                        );

                        if (!dialogContext.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(dialogContext)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                _cleanErrorMessage(error),
                              ),
                            ),
                          );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (created == true && mounted) {
        _showMessage(
          'Announcement created successfully.',
        );
      }
    } finally {
      titleController.dispose();
      messageController.dispose();
    }
  }

  // ============================================================
  // TOGGLE PUBLISHED
  // ============================================================

  Future<void> _togglePublished(
    String announcementId,
    bool currentlyPublished,
  ) async {
    if (_processing) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await _announcementsCollection
          .doc(announcementId)
          .update({
        'isPublished': !currentlyPublished,
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        currentlyPublished
            ? 'Announcement unpublished.'
            : 'Announcement published.',
      );
    } catch (error) {
      debugPrint(
        'TOGGLE ANNOUNCEMENT ERROR: $error',
      );

      if (mounted) {
        _showMessage(
          _cleanErrorMessage(error),
        );
      }
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
    String announcementId,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Announcement?'),
          content: const Text(
            'This announcement will be permanently deleted. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAnnouncement(announcementId);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteAnnouncement(
    String announcementId,
  ) async {
    if (_processing) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await _announcementsCollection
          .doc(announcementId)
          .delete();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Announcement deleted successfully.',
      );
    } catch (error) {
      debugPrint(
        'DELETE ANNOUNCEMENT ERROR: $error',
      );

      if (mounted) {
        _showMessage(
          _cleanErrorMessage(error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.campaign_outlined,
              size: 56,
              color: Color(0xFF2E7D32),
            ),

            const SizedBox(height: 14),

            const Text(
              'No announcements',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172018),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Create your first announcement for GreenMind AI users.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF68736B),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _processing
                  ? null
                  : _showCreateAnnouncementDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color(0xFFC62828),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172018),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF68736B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();

    final String day =
        date.day.toString().padLeft(2, '0');

    final String month =
        date.month.toString().padLeft(2, '0');

    final String year = date.year.toString();

    final String hour =
        date.hour.toString().padLeft(2, '0');

    final String minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // ============================================================
  // STRING HELPER
  // ============================================================

  String _readString(
    Object? value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final String result = value.toString().trim();

    return result.isEmpty ? fallback : result;
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
  // ERROR
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final String text =
        error.toString().toLowerCase();

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
      return 'The announcement could not be found.';
    }

    return 'Something went wrong. Please try again.';
  }
}