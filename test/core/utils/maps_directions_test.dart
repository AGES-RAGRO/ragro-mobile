import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/core/utils/maps_directions.dart';

void main() {
  group('buildMapsDirectionsUri', () {
    test('single pending stop uses dir_action=navigate without waypoints', () {
      final result = buildMapsDirectionsUri(
        stops: const ['-16.70,-49.25'],
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      expect(result.truncated, isFalse);
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['origin'], '-16.68,-49.26');
      expect(uri.queryParameters['destination'], '-16.7,-49.25');
      expect(uri.queryParameters.containsKey('waypoints'), isFalse);
      expect(uri.queryParameters['dir_action'], 'navigate');
      expect(uri.queryParameters['travelmode'], 'driving');
    });

    test('multiple pending stops DROP dir_action=navigate and add waypoints',
        () {
      final result = buildMapsDirectionsUri(
        stops: const ['-16.70,-49.25', '-16.72,-49.27', '-16.74,-49.29'],
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      // navigate mode errors with waypoints — must be absent here.
      expect(uri.queryParameters.containsKey('dir_action'), isFalse);
      expect(uri.queryParameters['destination'], '-16.74,-49.29');
      expect(
        uri.queryParameters['waypoints'],
        '-16.7,-49.25|-16.72,-49.27',
      );
    });

    test('omits origin when GPS is unknown', () {
      final result = buildMapsDirectionsUri(
        stops: const ['-16.70,-49.25', '-16.72,-49.27'],
      );

      final uri = result.uri!;
      expect(uri.queryParameters.containsKey('origin'), isFalse);
      expect(uri.queryParameters['destination'], '-16.72,-49.27');
      expect(uri.queryParameters['waypoints'], '-16.7,-49.25');
    });

    test('de-duplicates identical coordinates (same demo address)', () {
      // Two orders at the same address must not become waypoint==destination
      // (Google "route not found").
      final result = buildMapsDirectionsUri(
        stops: const ['-16.70,-49.25', '-16.70,-49.25'],
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      expect(uri.queryParameters['destination'], '-16.7,-49.25');
      expect(uri.queryParameters.containsKey('waypoints'), isFalse);
      // Collapses to a single stop -> navigate is valid again.
      expect(uri.queryParameters['dir_action'], 'navigate');
    });

    test('drops a stop equal to the origin', () {
      final result = buildMapsDirectionsUri(
        stops: const ['-16.68,-49.26', '-16.72,-49.27'],
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      expect(uri.queryParameters['destination'], '-16.72,-49.27');
      expect(uri.queryParameters.containsKey('waypoints'), isFalse);
    });

    test('drops invalid coordinates (empty, non-numeric, 0,0, out of range)',
        () {
      final result = buildMapsDirectionsUri(
        stops: const [
          '',
          'abc',
          '0.0,0.0',
          '999,999',
          '-16.72,-49.27',
        ],
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      expect(uri.queryParameters['destination'], '-16.72,-49.27');
      expect(uri.queryParameters.containsKey('waypoints'), isFalse);
    });

    test('caps waypoints at kMaxMapsWaypoints and flags truncated', () {
      // 12 stops -> 11 waypoints + 1 destination; cap drops to 9 waypoints.
      final stops = [for (var i = 0; i < 12; i++) '-16.${700 + i},-49.25'];
      final result = buildMapsDirectionsUri(
        stops: stops,
        originLat: -16.68,
        originLng: -49.26,
      );

      final uri = result.uri!;
      expect(result.truncated, isTrue);
      expect(
        uri.queryParameters['waypoints']!.split('|').length,
        kMaxMapsWaypoints,
      );
      // Destination is still the last stop, not dropped by the cap.
      expect(uri.queryParameters['destination'], '-16.711,-49.25');
    });

    test('returns null uri when no valid stop remains', () {
      final result = buildMapsDirectionsUri(
        stops: const ['', '0.0,0.0', 'abc'],
        originLat: -16.68,
        originLng: -49.26,
      );

      expect(result.uri, isNull);
      expect(result.truncated, isFalse);
    });

    test('empty stop list returns null uri', () {
      final result = buildMapsDirectionsUri(stops: const []);
      expect(result.uri, isNull);
    });

    test('ignores a 0,0 origin (treated as unknown GPS)', () {
      final result = buildMapsDirectionsUri(
        stops: const ['-16.72,-49.27'],
        originLat: 0,
        originLng: 0,
      );

      final uri = result.uri!;
      expect(uri.queryParameters.containsKey('origin'), isFalse);
      expect(uri.queryParameters['destination'], '-16.72,-49.27');
    });
  });
}
