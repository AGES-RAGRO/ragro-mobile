/// Builds the Google Maps Directions deep-link for the producer's route screen.
///
/// Why this is a pure function (and not inline in the page): the route screen
/// feeds Google Maps with raw `lat,lng` stops coming from the backend. Two
/// real-world traps break Maps and are handled here:
///  - **`dir_action=navigate` + multiple waypoints**: turn-by-turn navigation
///    does not reliably accept intermediate waypoints and errors out (the Maps
///    app shows "Waypoint, Waypoint, ..." and fails to start). So navigate is
///    used ONLY for a single destination; with waypoints we open the route
///    preview instead (the user taps "Iniciar").
///  - **degenerate / invalid coordinates**: empty, non-numeric, out-of-range,
///    `NaN`/infinite or `0,0` (Null Island) points are dropped, and duplicate
///    points (e.g. two orders at the same demo address) or a point equal to the
///    origin are de-duplicated to avoid Google's "route not found".
///
/// The deep-link also has a practical waypoint cap ([kMaxMapsWaypoints]); extra
/// stops are dropped and [MapsDirections.truncated] is set so the caller can
/// warn the user.
library;

/// Practical limit of intermediate waypoints supported by the Google Maps
/// universal URL (`/maps/dir/?api=1`). Stops beyond this are dropped.
const int kMaxMapsWaypoints = 9;

/// Result of [buildMapsDirectionsUri]: the [uri] to launch (null when there is
/// no valid stop to route to) and whether waypoints were [truncated] by the cap.
class MapsDirections {
  const MapsDirections({required this.uri, this.truncated = false});

  /// Deep-link to launch, or null when there is no valid destination.
  final Uri? uri;

  /// True when more than [kMaxMapsWaypoints] waypoints existed and were dropped.
  final bool truncated;
}

/// Builds a Google Maps directions deep-link from [stops] (each `"lat,lng"`),
/// already in the backend's optimized order. [originLat]/[originLng] pin the
/// producer's GPS as the start when known (and valid); otherwise Maps starts
/// from the device location.
MapsDirections buildMapsDirectionsUri({
  required List<String> stops,
  double? originLat,
  double? originLng,
}) {
  final origin = _validPoint(originLat, originLng);

  // Parse + validate + de-duplicate (also dropping any stop at the origin),
  // preserving the optimized order.
  final seen = <String>{};
  if (origin != null) seen.add(_key(origin.$1, origin.$2));
  final points = <(double, double)>[];
  for (final raw in stops) {
    final p = _parseLatLng(raw);
    if (p == null) continue;
    if (seen.add(_key(p.$1, p.$2))) points.add(p);
  }

  if (points.isEmpty) {
    return const MapsDirections(uri: null);
  }

  final destination = points.last;
  var waypoints = points.sublist(0, points.length - 1);

  final truncated = waypoints.length > kMaxMapsWaypoints;
  if (truncated) {
    waypoints = waypoints.sublist(0, kMaxMapsWaypoints);
  }

  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    if (origin != null) 'origin': _fmt(origin.$1, origin.$2),
    'destination': _fmt(destination.$1, destination.$2),
    if (waypoints.isNotEmpty)
      'waypoints': waypoints.map((p) => _fmt(p.$1, p.$2)).join('|'),
    'travelmode': 'driving',
    // Turn-by-turn navigate is reliable only for a single destination; with
    // waypoints it errors, so open the route preview instead.
    if (waypoints.isEmpty) 'dir_action': 'navigate',
  });

  return MapsDirections(uri: uri, truncated: truncated);
}

/// Parses a `"lat,lng"` string into a coordinate, or null when invalid
/// (wrong shape, non-numeric, non-finite, out of range, or `0,0`).
(double, double)? _parseLatLng(String raw) {
  final parts = raw.split(',');
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  return _validPoint(lat, lng);
}

(double, double)? _validPoint(double? lat, double? lng) {
  if (lat == null || lng == null) return null;
  if (!lat.isFinite || !lng.isFinite) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  if (lat == 0 && lng == 0) return null; // Null Island
  return (lat, lng);
}

/// De-dup key: rounds to 6 decimals (~11cm) so float noise doesn't defeat it.
String _key(double lat, double lng) =>
    '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';

String _fmt(double lat, double lng) => '$lat,$lng';
