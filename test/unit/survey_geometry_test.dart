import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:depthfenc/domain/services/survey_geometry.dart';

void main() {
  group('SurveyGeometryService Tests', () {
    const p1 = LatLng(20.5937, 78.9629);
    const p2 = LatLng(20.5945, 78.9629);
    const p3 = LatLng(20.5945, 78.9637);
    const p4 = LatLng(20.5937, 78.9637);

    final corners = [p1, p2, p3, p4];

    test('metersBetween calculates non-zero distance', () {
      final distance = SurveyGeometryService.metersBetween(p1, p2);
      expect(distance, greaterThan(0));
      expect(distance, closeTo(89.0, 10.0));
    });

    test('formatDistance formats meters and kilometers correctly', () {
      expect(SurveyGeometryService.formatDistance(150.5), '150.50 m');
      expect(SurveyGeometryService.formatDistance(1500.0), '1.50 km');
    });

    test('calculateSideLengths returns 4 side lengths for a quadrilateral', () {
      final sides = SurveyGeometryService.calculateSideLengths(corners);
      expect(sides.length, equals(4));
      for (final side in sides) {
        expect(side, greaterThan(0));
      }
    });

    test('calculatePerimeter returns total perimeter', () {
      final perimeter = SurveyGeometryService.calculatePerimeter(corners);
      expect(perimeter, greaterThan(200));
    });

    test('calculateAreaSquareMeters returns non-zero polygon area', () {
      final area = SurveyGeometryService.calculateAreaSquareMeters(corners);
      expect(area, greaterThan(5000));
    });
  });
}
