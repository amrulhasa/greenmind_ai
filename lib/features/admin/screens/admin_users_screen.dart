import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
  });

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends State<AdminUsersScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String _searchQuery = '';

  // ==========================================================
  // USER STREAM
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _usersStream {
    return _firestore
        .collection('users')
        .snapshots();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
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
                'Users',
                style:
                    AppTextStyles.heading1,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                'View and manage GreenMind AI users.',
                style:
                    AppTextStyles.subtitle,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // SEARCH
              // ==================================================

              TextField(
                textInputAction:
                    TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery =
                        value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      'Search users...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip:
                                  'Clear search',
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
                height: AppSpacing.lg,
              ),

              // ==================================================
              // USERS
              // ==================================================

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: _usersStream,
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
                            snapshot.error
                                .toString(),
                      );
                    }

                    // ==================================================
                    // DOCUMENTS
                    // ==================================================

                    final documents =
                        snapshot.data?.docs ??
                            <QueryDocumentSnapshot<
                                Map<String,
                                    dynamic>>>[];

                    if (documents.isEmpty) {
                      return const _EmptyUsersView();
                    }

                    // ==================================================
                    // SORT USERS BY CREATED AT
                    // ==================================================

                    final sortedDocuments =
                        List<
                            QueryDocumentSnapshot<
                                Map<String,
                                    dynamic>>>.from(
                      documents,
                    );

                    sortedDocuments.sort(
                      (
                        first,
                        second,
                      ) {
                        final firstDate =
                            _getTimestamp(
                          first.data()[
                              'createdAt'],
                        );

                        final secondDate =
                            _getTimestamp(
                          second.data()[
                              'createdAt'],
                        );

                        // Both missing
                        if (firstDate == null &&
                            secondDate == null) {
                          return 0;
                        }

                        // First missing -> last
                        if (firstDate == null) {
                          return 1;
                        }

                        // Second missing -> last
                        if (secondDate == null) {
                          return -1;
                        }

                        // Newest first
                        return secondDate
                            .compareTo(
                          firstDate,
                        );
                      },
                    );

                    // ==================================================
                    // FILTER USERS
                    // ==================================================

                    final filteredUsers =
                        sortedDocuments.where(
                      (document) {
                        final data =
                            document.data();

                        final name =
                            _stringValue(
                          data['name'],
                        );

                        final email =
                            _stringValue(
                          data['email'],
                        );

                        final role =
                            _stringValue(
                          data['role'],
                        );

                        final location =
                            _stringValue(
                          data['location'],
                        );

                        final phone =
                            _stringValue(
                          data['phone'],
                        );

                        return name.contains(
                              _searchQuery,
                            ) ||
                            email.contains(
                              _searchQuery,
                            ) ||
                            role.contains(
                              _searchQuery,
                            ) ||
                            location.contains(
                              _searchQuery,
                            ) ||
                            phone.contains(
                              _searchQuery,
                            );
                      },
                    ).toList();

                    // ==================================================
                    // SEARCH RESULT EMPTY
                    // ==================================================

                    if (filteredUsers.isEmpty) {
                      return _NoSearchResultView(
                        query: _searchQuery,
                        onClear: () {
                          setState(() {
                            _searchQuery =
                                '';
                          });
                        },
                      );
                    }

                    // ==================================================
                    // USER LIST
                    // ==================================================

                    return RefreshIndicator(
                      onRefresh: () async {
                        // Firestore Stream automatically
                        // updates the UI.
                        await Future<void>.delayed(
                          const Duration(
                            milliseconds: 300,
                          ),
                        );
                      },
                      child:
                          ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.only(
                          bottom: 24,
                        ),
                        itemCount:
                            filteredUsers.length,
                        separatorBuilder:
                            (
                          context,
                          index,
                        ) {
                          return const SizedBox(
                            height: 12,
                          );
                        },
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final document =
                              filteredUsers[
                                  index];

                          return _UserCard(
                            userId:
                                document.id,
                            data:
                                document.data(),
                            onTap: () {
                              _showUserDetails(
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

  // ==========================================================
  // STRING HELPER
  // ==========================================================

  String _stringValue(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  // ==========================================================
  // TIMESTAMP HELPER
  // ==========================================================

  DateTime? _getTimestamp(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ==========================================================
  // USER DETAILS
  // ==========================================================

  void _showUserDetails(
    BuildContext context,
    String userId,
    Map<String, dynamic> data,
  ) {
    final String name =
        (data['name'] ?? '')
            .toString()
            .trim();

    final String email =
        (data['email'] ?? '')
            .toString()
            .trim();

    final String role =
        (data['role'] ?? 'user')
            .toString()
            .trim();

    final String location =
        (data['location'] ?? '')
            .toString()
            .trim();

    final String phone =
        (data['phone'] ?? '')
            .toString()
            .trim();

    final String bio =
        (data['bio'] ?? '')
            .toString()
            .trim();

    final String createdAt =
        _formatDate(
      _getTimestamp(
        data['createdAt'],
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 +
                  MediaQuery.of(
                    sheetContext,
                  ).viewInsets.bottom,
            ),
            child:
                SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // USER HEADER
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            AppColors.primary
                                    .withValues(
                              alpha: 0.12,
                            ),
                        child: Icon(
                          role.toLowerCase() ==
                                  'admin'
                              ? Icons
                                  .admin_panel_settings_rounded
                              : Icons
                                  .person_rounded,
                          color:
                              AppColors.primary,
                          size: 30,
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
                              name.isEmpty
                                  ? 'Unknown User'
                                  : name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  AppTextStyles
                                      .heading2,
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              email.isEmpty
                                  ? 'No email'
                                  : email,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  AppTextStyles
                                      .subtitle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      _RoleBadge(
                        role: role,
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
                    label: 'User ID',
                    value: userId,
                  ),

                  _DetailRow(
                    icon:
                        Icons.email_outlined,
                    label: 'Email',
                    value: email.isEmpty
                        ? 'Not provided'
                        : email,
                  ),

                  _DetailRow(
                    icon: Icons
                        .person_outline_rounded,
                    label: 'Name',
                    value: name.isEmpty
                        ? 'Not provided'
                        : name,
                  ),

                  _DetailRow(
                    icon: Icons
                        .location_on_outlined,
                    label: 'Location',
                    value: location.isEmpty
                        ? 'Not provided'
                        : location,
                  ),

                  _DetailRow(
                    icon:
                        Icons.phone_outlined,
                    label: 'Phone',
                    value: phone.isEmpty
                        ? 'Not provided'
                        : phone,
                  ),

                  _DetailRow(
                    icon:
                        Icons.info_outline_rounded,
                    label: 'Bio',
                    value: bio.isEmpty
                        ? 'Not provided'
                        : bio,
                  ),

                  _DetailRow(
                    icon:
                        Icons.calendar_today_outlined,
                    label: 'Joined',
                    value: createdAt,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // CLOSE
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();
                      },
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

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Not available';
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

    return '$day/$month/$year';
  }
}

// ================================================================
// USER CARD
// ================================================================

class _UserCard
    extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _UserCard({
    required this.userId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final String name =
        (data['name'] ?? '')
            .toString()
            .trim();

    final String email =
        (data['email'] ?? '')
            .toString()
            .trim();

    final String role =
        (data['role'] ?? 'user')
            .toString()
            .trim();

    final String location =
        (data['location'] ?? '')
            .toString()
            .trim();

    final bool isAdmin =
        role.toLowerCase() == 'admin';

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
                CrossAxisAlignment.center,
            children: [
              // ==================================================
              // AVATAR
              // ==================================================

              CircleAvatar(
                radius: 28,
                backgroundColor:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                child: Icon(
                  isAdmin
                      ? Icons
                          .admin_panel_settings_rounded
                      : Icons
                          .person_rounded,
                  color:
                      AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // USER INFO
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      name.isEmpty
                          ? 'Unknown User'
                          : name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles
                              .heading3,
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      email.isEmpty
                          ? 'No email'
                          : email,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.body,
                    ),

                    if (location
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
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
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  AppTextStyles
                                      .body,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ==================================================
              // ROLE
              // ==================================================

              _RoleBadge(
                role: role,
              ),

              const SizedBox(
                width: 8,
              ),

              // ==================================================
              // ARROW
              // ==================================================

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ROLE BADGE
// ================================================================

class _RoleBadge
    extends StatelessWidget {
  final String role;

  const _RoleBadge({
    required this.role,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isAdmin =
        role.toLowerCase() == 'admin';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: isAdmin
            ? AppColors.primary
              .withValues(alpha: 0.12)
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'USER',
        style: TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w700,
          color: isAdmin
              ? AppColors.primary
              : Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
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
          // ==================================================
          // ICON
          // ==================================================

          Icon(
            icon,
            size: 21,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          // ==================================================
          // LABEL
          // ==================================================

          SizedBox(
            width: 82,
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

          // ==================================================
          // VALUE
          // ==================================================

          Expanded(
            child: SelectableText(
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
// EMPTY USERS
// ================================================================

class _EmptyUsersView
    extends StatelessWidget {
  const _EmptyUsersView();

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
            Icon(
              Icons
                  .people_outline_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'No users found',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'There are no users in Firestore yet.',
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

// ================================================================
// NO SEARCH RESULT
// ================================================================

class _NoSearchResultView
    extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _NoSearchResultView({
    required this.query,
    required this.onClear,
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
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'No users found',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'No users match "$query".',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.subtitle,
            ),

            const SizedBox(
              height: 16,
            ),

            OutlinedButton(
              onPressed: onClear,
              child: const Text(
                'Clear Search',
              ),
            ),
          ],
        ),
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
      child: SingleChildScrollView(
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
              'Unable to load users.',
              style:
                  AppTextStyles.heading3,
              textAlign:
                  TextAlign.center,
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

            const SizedBox(
              height: 16,
            ),

            OutlinedButton.icon(
              onPressed: () {
                // StreamBuilder will rebuild
                // naturally when Firestore
                // reconnects.
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}