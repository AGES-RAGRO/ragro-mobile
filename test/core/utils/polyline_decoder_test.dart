import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/core/utils/polyline_decoder.dart';

void main() {
  group('decodePolyline', () {
    test('decodes a well-formed Google polyline', () {
      // Canonical example from Google's encoded polyline docs.
      final points = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(points.length, 3);
      expect(points[0].$1, closeTo(38.5, 0.0001));
      expect(points[0].$2, closeTo(-120.2, 0.0001));
      expect(points[1].$1, closeTo(40.7, 0.0001));
      expect(points[1].$2, closeTo(-120.95, 0.0001));
      expect(points[2].$1, closeTo(43.252, 0.0001));
      expect(points[2].$2, closeTo(-126.453, 0.0001));
    });

    test('empty input returns empty list', () {
      expect(decodePolyline(''), isEmpty);
    });

    test('truncated polyline returns partial list without throwing', () {
      // Drop the trailing chars so the last coordinate pair is incomplete.
      const full = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final truncated = full.substring(0, full.length - 3);

      late final List<(double, double)> points;
      expect(() => points = decodePolyline(truncated), returnsNormally);
      // The first complete pair(s) are still decoded; the partial tail is
      // dropped instead of crashing with a RangeError.
      expect(points, isNotEmpty);
      expect(points.length, lessThan(3));
      expect(points.first.$1, closeTo(38.5, 0.0001));
    });

    test('input truncated mid first coordinate returns empty list', () {
      // A single byte that signals "more bytes follow" but with nothing after
      // it (the do-while would read past the end on the first pair).
      final points = decodePolyline(String.fromCharCode(0x20 + 63));
      expect(points, isEmpty);
    });
  });
}
