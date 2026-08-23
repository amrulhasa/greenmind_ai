import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// ANNOUNCEMENT BADGE PROVIDER
// ============================================================

final announcementBadgeProvider =
    NotifierProvider<AnnouncementBadgeNotifier, int>(
  AnnouncementBadgeNotifier.new,
);

// ============================================================
// NOTIFIER
// ============================================================

class AnnouncementBadgeNotifier extends Notifier<int> {
  static const String _readKey =
      'greenmind_read_announcement_ids';

  final CollectionReference<Map<String, dynamic>>
      _collection =
      FirebaseFirestore.instance.collection(
    'announcements',
  );

  StreamSubscription<
          QuerySnapshot<Map<String, dynamic>>>?
      _subscription;

  Set<String> _readAnnouncementIds = <String>{};

  bool _initialized = false;

  bool _loadingReadIds = true;

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  int build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    _initialize();

    return 0;
  }

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _loadReadIds();

    _loadingReadIds = false;

    _listenToAnnouncements();
  }

  // ==========================================================
  // LOAD READ IDS
  // ==========================================================

  Future<void> _loadReadIds() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final List<String>? savedIds =
          preferences.getStringList(
        _readKey,
      );

      if (savedIds == null ||
          savedIds.isEmpty) {
        _readAnnouncementIds = <String>{};
        return;
      }

      _readAnnouncementIds =
          savedIds.toSet();
    } catch (_) {
      _readAnnouncementIds = <String>{};
    }
  }

  // ==========================================================
  // SAVE READ IDS
  // ==========================================================

  Future<void> _saveReadIds() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      await preferences.setStringList(
        _readKey,
        _readAnnouncementIds.toList(),
      );
    } catch (_) {
      // Ignore local storage failures.
    }
  }

  // ==========================================================
  // FIRESTORE LISTENER
  // ==========================================================

  void _listenToAnnouncements() {
    _subscription?.cancel();

    _subscription = _collection
        .where(
          'isPublished',
          isEqualTo: true,
        )
        .snapshots()
        .listen(
      (
        QuerySnapshot<Map<String, dynamic>>
            snapshot,
      ) {
        _updateBadge(
          snapshot.docs,
        );
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        // Keep existing badge value if Firestore
        // temporarily fails.
      },
    );
  }

  // ==========================================================
  // UPDATE BADGE
  // ==========================================================

  void _updateBadge(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        documents,
  ) {
    if (_loadingReadIds) {
      return;
    }

    final Set<String> existingIds =
        documents
            .map(
              (document) => document.id,
            )
            .toSet();

    // --------------------------------------------------------
    // Remove read IDs that no longer exist.
    // --------------------------------------------------------

    final int oldLength =
        _readAnnouncementIds.length;

    _readAnnouncementIds.removeWhere(
      (String id) =>
          !existingIds.contains(id),
    );

    if (_readAnnouncementIds.length !=
        oldLength) {
      unawaited(
        _saveReadIds(),
      );
    }

    // --------------------------------------------------------
    // Count unread published announcements.
    // --------------------------------------------------------

    int unreadCount = 0;

    for (final document in documents) {
      final bool isRead =
          _readAnnouncementIds.contains(
        document.id,
      );

      if (!isRead) {
        unreadCount++;
      }
    }

    state = unreadCount;
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  void refresh() {
    if (_subscription == null) {
      _listenToAnnouncements();
    }
  }

  // ==========================================================
  // MARK ONE AS READ
  // ==========================================================

  Future<void> markAsRead(
    String announcementId,
  ) async {
    if (announcementId.trim().isEmpty) {
      return;
    }

    _readAnnouncementIds.add(
      announcementId,
    );

    // Optimistic UI update.
    if (state > 0) {
      state--;
    }

    await _saveReadIds();
  }

  // ==========================================================
  // MARK ONE AS UNREAD
  // ==========================================================

  Future<void> markAsUnread(
    String announcementId,
  ) async {
    if (announcementId.trim().isEmpty) {
      return;
    }

    _readAnnouncementIds.remove(
      announcementId,
    );

    await _saveReadIds();

    _recalculateFromFirestore();
  }

  // ==========================================================
  // MARK ALL AS READ
  //
  // Optional IDs:
  //   markAllAsRead()
  //   markAllAsRead(ids)
  // ==========================================================

  Future<void> markAllAsRead([
    Iterable<String>? announcementIds,
  ]) async {
    final Iterable<String> ids =
        announcementIds ??
            await _getCurrentAnnouncementIds();

    for (final String id in ids) {
      if (id.trim().isNotEmpty) {
        _readAnnouncementIds.add(id);
      }
    }

    await _saveReadIds();

    // Immediately remove badge.
    state = 0;
  }

  // ==========================================================
  // GET CURRENT ANNOUNCEMENT IDS
  // ==========================================================

  Future<Set<String>>
      _getCurrentAnnouncementIds() async {
    try {
      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _collection
              .where(
                'isPublished',
                isEqualTo: true,
              )
              .get();

      return snapshot.docs
          .map(
            (document) => document.id,
          )
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  // ==========================================================
  // RECALCULATE
  // ==========================================================

  void _recalculateFromFirestore() {
    _collection
        .where(
          'isPublished',
          isEqualTo: true,
        )
        .get()
        .then(
      (
        QuerySnapshot<Map<String, dynamic>>
            snapshot,
      ) {
        _updateBadge(
          snapshot.docs,
        );
      },
    ).catchError(
      (_) {},
    );
  }

  // ==========================================================
  // CLEAR ALL READ DATA
  // ==========================================================

  Future<void> clear() async {
    _readAnnouncementIds.clear();

    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      await preferences.remove(
        _readKey,
      );
    } catch (_) {}

    _recalculateFromFirestore();
  }
}