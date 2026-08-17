import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/nursery.dart';
import '../services/location_service.dart';
import '../services/nursery_service.dart';

import '../widgets/nursery_bottom_sheet.dart';
import '../widgets/nursery_card.dart';
import '../widgets/nursery_map.dart';

class NearbyNurseryScreen extends StatefulWidget {
  const NearbyNurseryScreen({
    super.key,
  });

  @override
  State<NearbyNurseryScreen> createState() =>
      _NearbyNurseryScreenState();
}

class _NearbyNurseryScreenState
    extends State<NearbyNurseryScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final NurseryService _nurseryService =
      NurseryService();

  final LocationService _locationService =
      LocationService.instance;

  // ============================================================
  // STATE
  // ============================================================

  List<Nursery> _nurseries = [];

  double? _latitude;
  double? _longitude;

  bool _isLoading = true;

  String? _errorMessage;

  double _radius =
      NurseryService.defaultRadiusMeters;

  // Prevent an old request from updating the UI.
  int _requestId = 0;

  // ============================================================
  // TIMEOUT
  // ============================================================

  static const Duration _searchTimeout =
      Duration(seconds: 45);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _loadNearbyNurseries();
        }
      },
    );
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<Position> _getCurrentPosition() async {
    try {
      return await _locationService
          .getCurrentLocation();
    }

    // ----------------------------------------------------------
    // LOCATION SERVICE DISABLED
    // ----------------------------------------------------------

    on AppLocationServiceDisabledException {
      throw const _LocationUiException(
        'Location service is turned off.',
      );
    }

    // ----------------------------------------------------------
    // PERMISSION DENIED
    // ----------------------------------------------------------

    on AppLocationPermissionDeniedException {
      throw const _LocationUiException(
        'Location permission was denied.',
      );
    }

    // ----------------------------------------------------------
    // PERMISSION DENIED FOREVER
    // ----------------------------------------------------------

    on AppLocationPermissionDeniedForeverException {
      throw const _LocationUiException(
        'Location permission is permanently denied.',
      );
    }

    // ----------------------------------------------------------
    // LOCATION FETCH ERROR
    // ----------------------------------------------------------

    on LocationFetchException catch (error) {
      throw _LocationUiException(
        error.message,
      );
    }

    // ----------------------------------------------------------
    // TIMEOUT
    // ----------------------------------------------------------

    on TimeoutException {
      throw const _LocationUiException(
        'Getting your location took too long.',
      );
    }

    // ----------------------------------------------------------
    // UNKNOWN ERROR
    // ----------------------------------------------------------

    catch (error) {
      debugPrint(
        'Location error: $error',
      );

      throw const _LocationUiException(
        'Unable to get your current location.',
      );
    }
  }

  // ============================================================
  // LOAD NEARBY NURSERIES
  // ============================================================

  Future<void> _loadNearbyNurseries() async {
    if (!mounted) {
      return;
    }

    final int currentRequestId =
        ++_requestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ========================================================
      // STEP 1 — GET LOCATION
      // ========================================================

      final Position position =
          await _getCurrentPosition();

      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      debugPrint(
        'User location: '
        '${position.latitude}, '
        '${position.longitude}',
      );

      // ========================================================
      // STEP 2 — SEARCH NURSERIES
      // ========================================================

      final List<Nursery> nurseries =
          await _nurseryService
              .searchNearbyNurseries(
                latitude:
                    position.latitude,
                longitude:
                    position.longitude,
                radiusMeters:
                    _radius,
              )
              .timeout(
                _searchTimeout,
                onTimeout: () {
                  throw TimeoutException(
                    'The nursery search took too long.',
                    _searchTimeout,
                  );
                },
              );

      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      // ========================================================
      // STEP 3 — UPDATE UI
      // ========================================================

      setState(() {
        _latitude =
            position.latitude;

        _longitude =
            position.longitude;

        _nurseries =
            nurseries;

        _isLoading = false;

        _errorMessage = null;
      });
    }

    // ==========================================================
    // LOCATION ERROR
    // ==========================================================

    on _LocationUiException catch (error) {
      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      debugPrint(
        'Location UI error: ${error.message}',
      );

      setState(() {
        _isLoading = false;
        _errorMessage =
            error.message;
      });
    }

    // ==========================================================
    // NURSERY SEARCH ERROR
    // ==========================================================

    on NurserySearchException catch (error) {
      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      debugPrint(
        'Nursery search error: '
        '${error.message}',
      );

      setState(() {
        _isLoading = false;
        _errorMessage =
            error.message;
      });
    }

    // ==========================================================
    // TIMEOUT ERROR
    // ==========================================================

    on TimeoutException catch (error) {
      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      final String text =
          error.message
                  ?.toLowerCase() ??
              '';

      setState(() {
        _isLoading = false;

        if (text.contains('location')) {
          _errorMessage =
              'Getting your location took too long.\n'
              'Please allow location access in Chrome '
              'and try again.';
        } else {
          _errorMessage =
              'The nursery search took too long.\n'
              'The OpenStreetMap search servers may be busy.';
        }
      });
    }

    // ==========================================================
    // UNKNOWN ERROR
    // ==========================================================

    catch (error) {
      if (!mounted ||
          currentRequestId != _requestId) {
        return;
      }

      debugPrint(
        'Nearby nursery error: $error',
      );

      setState(() {
        _isLoading = false;

        _errorMessage =
            'Unable to find nearby nurseries.\n'
            'Please check your internet connection '
            'and try again.';
      });
    }
  }

  // ============================================================
  // SHOW NURSERY DETAILS
  // ============================================================

  void _showNursery(
    Nursery nursery,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          AppColors.surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(
            AppRadius.circular,
          ),
        ),
      ),
      builder: (_) {
        return NurseryBottomSheet(
          nursery: nursery,
        );
      },
    );
  }

  // ============================================================
  // OPEN LOCATION SETTINGS
  // ============================================================

  Future<void> _openLocationSettings() async {
    if (kIsWeb) {
      await _showWebLocationHelp();
      return;
    }

    try {
      final bool opened =
          await _locationService
              .openLocationSettings();

      if (!opened && mounted) {
        await _showNativeLocationHelp();
      }
    } catch (error) {
      debugPrint(
        'Location settings error: $error',
      );

      if (mounted) {
        await _showNativeLocationHelp();
      }
    }
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  Future<void> _openAppSettings() async {
    if (kIsWeb) {
      await _showWebLocationHelp();
      return;
    }

    try {
      final bool opened =
          await _locationService
              .openAppSettings();

      if (!opened && mounted) {
        await _showNativeLocationHelp();
      }
    } catch (error) {
      debugPrint(
        'App settings error: $error',
      );

      if (mounted) {
        await _showNativeLocationHelp();
      }
    }
  }

  // ============================================================
  // WEB LOCATION HELP
  // ============================================================

  Future<void> _showWebLocationHelp() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Allow Location in Chrome',
          ),
          content: const Text(
            'For the GreenMind AI localhost app:\n\n'
            '1. Click the site/permission icon '
            'near the Chrome address bar.\n'
            '2. Find Location permission.\n'
            '3. Select Allow.\n'
            '4. Reload the page.\n'
            '5. Press Try Again.\n\n'
            'If Location was previously blocked, '
            'open Chrome site settings for localhost '
            'and change Location to Allow.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // NATIVE LOCATION HELP
  // ============================================================

  Future<void> _showNativeLocationHelp() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Location Required',
          ),
          content: const Text(
            'Please enable Location/GPS and allow '
            'GreenMind AI to access your location, '
            'then try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SELECT SEARCH RADIUS
  // ============================================================

  Future<void> _selectRadius() async {
    if (_isLoading) {
      return;
    }

    final double? selected =
        await showModalBottomSheet<double>(
      context: context,
      backgroundColor:
          AppColors.surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(
            AppRadius.circular,
          ),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Radius',
                  style:
                      AppTextStyles.title,
                ),

                const SizedBox(
                  height:
                      AppSpacing.xs,
                ),

                Text(
                  'Choose how far GreenMind '
                  'should search.',
                  style:
                      AppTextStyles.caption,
                ),

                const SizedBox(
                  height:
                      AppSpacing.md,
                ),

                _RadiusOption(
                  value: 2000,
                  label: '2 km',
                  selected:
                      _radius == 2000,
                ),

                _RadiusOption(
                  value: 5000,
                  label: '5 km',
                  selected:
                      _radius == 5000,
                ),

                _RadiusOption(
                  value: 10000,
                  label: '10 km',
                  selected:
                      _radius == 10000,
                ),

                _RadiusOption(
                  value: 20000,
                  label: '20 km',
                  selected:
                      _radius == 20000,
                ),

                const SizedBox(
                  height:
                      AppSpacing.sm,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null ||
        selected == _radius ||
        !mounted) {
      return;
    }

    setState(() {
      _radius = selected;
    });

    await _loadNearbyNurseries();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby Nurseries',
              style:
                  AppTextStyles.title,
            ),
            Text(
              'Find plant shops near you',
              style:
                  AppTextStyles.caption,
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Search radius',
            onPressed:
                _isLoading
                    ? null
                    : _selectRadius,
            icon: const Icon(
              Icons.tune_rounded,
            ),
          ),

          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading
                    ? null
                    : _loadNearbyNurseries,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          const SizedBox(
            width: 4,
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return _buildLoading();
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_errorMessage != null) {
      return _buildError();
    }

    // ----------------------------------------------------------
    // LOCATION MISSING
    // ----------------------------------------------------------

    if (_latitude == null ||
        _longitude == null) {
      return _buildError(
        customMessage:
            'Your current location could not be determined.',
      );
    }

    // ----------------------------------------------------------
    // MAIN CONTENT
    // ----------------------------------------------------------

    return Column(
      children: [
        // ======================================================
        // MAP
        // ======================================================

        SizedBox(
          height:
              MediaQuery.sizeOf(context)
                      .height *
                  0.30,
          child: NurseryMap(
            userLatitude:
                _latitude!,
            userLongitude:
                _longitude!,
            nurseries:
                _nurseries,
            onNurseryTap:
                _showNursery,
          ),
        ),

        // ======================================================
        // HEADER
        // ======================================================

        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _nurseries.isEmpty
                      ? 'No nurseries found'
                      : '${_nurseries.length} '
                        'nurseries nearby',
                  style:
                      AppTextStyles.title,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      AppSpacing.sm,
                  vertical:
                      AppSpacing.xs,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.circular,
                  ),
                ),
                child: Text(
                  '${(_radius / 1000).toStringAsFixed(0)} km',
                  style:
                      AppTextStyles.caption
                          .copyWith(
                    color:
                        AppColors.primary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // LIST
        // ======================================================

        Expanded(
          child:
              _nurseries.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),

                      itemCount:
                          _nurseries.length,

                      itemBuilder:
                          (context, index) {
                        final Nursery nursery =
                            _nurseries[index];

                        return NurseryCard(
                          nursery:
                              nursery,
                          onTap: () {
                            _showNursery(
                              nursery,
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ============================================================
  // LOADING UI
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
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
              child:
                  const Padding(
                padding:
                    EdgeInsets.all(20),
                child:
                    CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),

            const SizedBox(
              height:
                  AppSpacing.lg,
            ),

            Text(
              'Finding nearby nurseries...',
              style:
                  AppTextStyles.title,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  AppSpacing.xs,
            ),

            Text(
              kIsWeb
                  ? 'Getting your browser location '
                    'and searching nearby plant shops.'
                  : 'Getting your location and '
                    'searching nearby plant shops.',
              style:
                  AppTextStyles.caption,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            Text(
              'This normally takes only a few seconds.',
              style:
                  AppTextStyles.caption
                      .copyWith(
                color:
                    AppColors.textSecondary,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR UI
  // ============================================================

  Widget _buildError({
    String? customMessage,
  }) {
    final String message =
        customMessage ??
            _errorMessage ??
            'Something went wrong.';

    final String lowerMessage =
        message.toLowerCase();

    final bool locationError =
        lowerMessage.contains(
              'location service',
            ) ||
            lowerMessage.contains(
              'gps',
            ) ||
            lowerMessage.contains(
              'current location',
            ) ||
            lowerMessage.contains(
              'getting your location',
            ) ||
            lowerMessage.contains(
              'location could not',
            );

    final bool permissionError =
        lowerMessage.contains(
      'permission',
    );

    final bool permanentlyDenied =
        lowerMessage.contains(
      'permanently denied',
    );

    final bool isWebLocationError =
        kIsWeb &&
            (locationError ||
                permissionError ||
                lowerMessage.contains(
                  'location',
                ));

    return Center(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.error
                        .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.location_off_rounded,
                size: 38,
                color:
                    AppColors.error,
              ),
            ),

            const SizedBox(
              height:
                  AppSpacing.lg,
            ),

            Text(
              'Unable to find nurseries',
              style:
                  AppTextStyles.title,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  AppSpacing.sm,
            ),

            Text(
              message,
              style:
                  AppTextStyles.body,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  AppSpacing.lg,
            ),

            // --------------------------------------------------
            // WEB LOCATION
            // --------------------------------------------------

            if (isWebLocationError)
              FilledButton.icon(
                onPressed:
                    _openLocationSettings,
                icon:
                    const Icon(
                  Icons.location_on_rounded,
                ),
                label:
                    const Text(
                  'Allow Location',
                ),
              )

            // --------------------------------------------------
            // NATIVE LOCATION
            // --------------------------------------------------

            else if (locationError)
              FilledButton.icon(
                onPressed:
                    _openLocationSettings,
                icon:
                    const Icon(
                  Icons.location_on_rounded,
                ),
                label:
                    const Text(
                  'Turn On Location',
                ),
              )

            // --------------------------------------------------
            // PERMISSION
            // --------------------------------------------------

            else if (permissionError ||
                permanentlyDenied)
              FilledButton.icon(
                onPressed:
                    _openAppSettings,
                icon:
                    const Icon(
                  Icons.settings_rounded,
                ),
                label:
                    const Text(
                  'Open App Settings',
                ),
              )

            // --------------------------------------------------
            // NORMAL ERROR
            // --------------------------------------------------

            else
              FilledButton.icon(
                onPressed:
                    _loadNearbyNurseries,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                    const Text(
                  'Try Again',
                ),
              ),

            const SizedBox(
              height:
                  AppSpacing.sm,
            ),

            // Always provide a retry option
            // for location/search problems.
            TextButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : _loadNearbyNurseries,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Search Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmpty() {
    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const SizedBox(
            height:
                AppSpacing.md,
          ),

          Container(
            width: 80,
            height: 80,
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
            child:
                const Icon(
              Icons.local_florist_outlined,
              size: 42,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height:
                AppSpacing.md,
          ),

          Text(
            'No nurseries found nearby',
            style:
                AppTextStyles.title,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height:
                AppSpacing.xs,
          ),

          Text(
            'No plant shops or garden centres '
            'were found within the selected radius.',
            style:
                AppTextStyles.caption,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height:
                AppSpacing.md,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  _selectRadius,
              icon:
                  const Icon(
                Icons.tune_rounded,
              ),
              label:
                  const Text(
                'Increase Radius',
              ),
            ),
          ),

          const SizedBox(
            height:
                AppSpacing.sm,
          ),

          TextButton.icon(
            onPressed:
                _loadNearbyNurseries,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text(
              'Search Again',
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// RADIUS OPTION
// ================================================================

class _RadiusOption
    extends StatelessWidget {
  const _RadiusOption({
    required this.value,
    required this.label,
    required this.selected,
  });

  final double value;
  final String label;
  final bool selected;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading:
          Icon(
        selected
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color:
            selected
                ? AppColors.primary
                : AppColors.textSecondary,
      ),

      title:
          Text(label),

      trailing:
          selected
              ? const Icon(
                  Icons.check_rounded,
                  color:
                      AppColors.primary,
                )
              : null,

      onTap: () {
        Navigator.of(
          context,
        ).pop(value);
      },
    );
  }
}

// ================================================================
// LOCATION UI EXCEPTION
// ================================================================

class _LocationUiException
    implements Exception {
  const _LocationUiException(
    this.message,
  );

  final String message;

  @override
  String toString() {
    return message;
  }
}