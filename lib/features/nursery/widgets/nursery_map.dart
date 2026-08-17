import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../models/nursery.dart';

class NurseryMap extends StatefulWidget {
  const NurseryMap({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    required this.nurseries,
    this.onNurseryTap,
  });

  final double userLatitude;
  final double userLongitude;
  final List<Nursery> nurseries;
  final ValueChanged<Nursery>? onNurseryTap;

  @override
  State<NurseryMap> createState() => _NurseryMapState();
}

class _NurseryMapState extends State<NurseryMap> {
  // ============================================================
  // MAP CONTROLLER
  // ============================================================

  final MapController _mapController = MapController();

  bool _mapReady = false;

  // ============================================================
  // USER LOCATION
  // ============================================================

  LatLng get _userLocation {
    return LatLng(
      widget.userLatitude,
      widget.userLongitude,
    );
  }

  // ============================================================
  // NURSERY MARKERS
  // ============================================================

  List<Marker> get _nurseryMarkers {
    return widget.nurseries.map((nursery) {
      return Marker(
        point: LatLng(
          nursery.latitude,
          nursery.longitude,
        ),
        width: 62,
        height: 76,
        alignment: Alignment.topCenter,

        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onNurseryTap?.call(nursery);
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --------------------------------------------------
              // NURSERY MARKER
              // --------------------------------------------------

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 8,
                      offset: const Offset(
                        0,
                        3,
                      ),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              // --------------------------------------------------
              // POINTER
              // --------------------------------------------------

              Transform.translate(
                offset: const Offset(
                  0,
                  -2,
                ),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ============================================================
  // USER MARKER
  // ============================================================

  Marker get _userMarker {
    return Marker(
      point: _userLocation,
      width: 58,
      height: 58,
      alignment: Alignment.center,

      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.22,
              ),
              blurRadius: 10,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
        ),

        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAP READY
  // ============================================================

  void _onMapReady() {
    _mapReady = true;

    if (widget.nurseries.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAllNurseries();
        }
      });
    }
  }

  // ============================================================
  // WIDGET UPDATE
  // ============================================================

  @override
  void didUpdateWidget(
    covariant NurseryMap oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final locationChanged =
        oldWidget.userLatitude !=
            widget.userLatitude ||
        oldWidget.userLongitude !=
            widget.userLongitude;

    final nurseryCountChanged =
        oldWidget.nurseries.length !=
            widget.nurseries.length;

    if (_mapReady &&
        (locationChanged ||
            nurseryCountChanged)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.nurseries.isNotEmpty) {
          _showAllNurseries();
        } else {
          _moveToUser();
        }
      });
    }
  }

  // ============================================================
  // MOVE TO USER
  // ============================================================

  void _moveToUser() {
    if (!_mapReady) return;

    _mapController.move(
      _userLocation,
      14.5,
    );
  }

  // ============================================================
  // SHOW ALL NURSERIES
  // ============================================================

  void _showAllNurseries() {
    if (!_mapReady) return;

    if (widget.nurseries.isEmpty) {
      _moveToUser();
      return;
    }

    final points = <LatLng>[
      _userLocation,
      ...widget.nurseries.map(
        (nursery) {
          return LatLng(
            nursery.latitude,
            nursery.longitude,
          );
        },
      ),
    ];

    if (points.length == 1) {
      _moveToUser();
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      points,
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(
          70,
        ),
        maxZoom: 15,
        minZoom: 10,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppRadius.circular,
      ),

      child: Stack(
        children: [
          // ======================================================
          // OPENSTREETMAP
          // ======================================================

          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 13.5,

              minZoom: 3,
              maxZoom: 19,

              onMapReady: _onMapReady,

              interactionOptions:
                  const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),

            children: [
              // ==================================================
              // MAP TILES
              // ==================================================

              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/'
                    '{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.example.greenmind_ai',

                maxZoom: 19,
              ),

              // ==================================================
              // NURSERY + USER MARKERS
              // ==================================================

              MarkerLayer(
                markers: [
                  _userMarker,
                  ..._nurseryMarkers,
                ],
              ),

              // ==================================================
              // ATTRIBUTION
              // ==================================================

              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // TOP LEFT LABEL
          // ======================================================

          Positioned(
            left: 14,
            top: 14,

            child: _GlassBadge(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    size: 18,
                    color:
                        AppColors.primary,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    'Nearby Nurseries',
                    style:
                        Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // NURSERY COUNT
          // ======================================================

          if (widget.nurseries.isNotEmpty)
            Positioned(
              right: 14,
              top: 14,

              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  minWidth: 72,
                  maxWidth: 110,
                ),

                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black
                                .withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 8,
                        offset:
                            const Offset(
                          0,
                          2,
                        ),
                      ),
                    ],
                  ),

                  child: Text(
                    '${widget.nurseries.length} found',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

          // ======================================================
          // MAP CONTROLS
          // ======================================================

          Positioned(
            right: 14,
            bottom: 14,

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ------------------------------------------------
                // SHOW ALL
                // ------------------------------------------------

                _MapButton(
                  icon:
                      Icons.fit_screen_rounded,
                  tooltip:
                      'Show all nurseries',
                  onTap:
                      _showAllNurseries,
                ),

                const SizedBox(
                  height: 8,
                ),

                // ------------------------------------------------
                // MY LOCATION
                // ------------------------------------------------

                _MapButton(
                  icon:
                      Icons.my_location_rounded,
                  tooltip:
                      'My location',
                  onTap:
                      _moveToUser,
                ),
              ],
            ),
          ),

          // ======================================================
          // LEGEND
          // ======================================================

          Positioned(
            left: 14,
            bottom: 14,

            child: _GlassBadge(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 8,
              ),

              child: Row(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  // User
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        const BoxDecoration(
                      color:
                          AppColors.primary,
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // Nursery
                  Container(
                    width: 11,
                    height: 11,
                    decoration:
                        const BoxDecoration(
                      color:
                          AppColors.primary,
                      shape:
                          BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.local_florist,
                      size: 7,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  const Text(
                    'Nursery',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GLASS BADGE
// ============================================================

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.child,
    this.padding =
        const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: padding,

      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(
          alpha: 0.95,
        ),

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.12,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: child,
    );
  }
}

// ============================================================
// MAP BUTTON
// ============================================================

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: AppColors.surface,
      elevation: 5,

      shadowColor:
          Colors.black.withValues(
        alpha: 0.20,
      ),

      borderRadius:
          BorderRadius.circular(14),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),

        onTap: onTap,

        child: Tooltip(
          message: tooltip,

          child: Padding(
            padding:
                const EdgeInsets.all(
              13,
            ),

            child: Icon(
              icon,
              color:
                  AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}