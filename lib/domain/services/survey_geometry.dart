import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Survey geometry engine for calculating geodesic distances, side lengths,
/// perimeter, and polygon area in meters and square meters.
class SurveyGeometryService {
  static const Distance _distanceCalculator = Distance();

  /// Returns geodesic distance between two points in meters.
  static double metersBetween(LatLng a, LatLng b) {
    return _distanceCalculator(a, b);
  }

  /// Formats distance into human-readable string (m or km).
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(2)} m';
  }

  /// Calculates individual side lengths between sequential boundary vertices.
  static List<double> calculateSideLengths(List<LatLng> corners) {
    if (corners.length < 2) return [];
    final List<double> sides = [];
    for (int i = 0; i < corners.length; i++) {
      final nextIndex = (i + 1) % corners.length;
      sides.add(metersBetween(corners[i], corners[nextIndex]));
    }
    return sides;
  }

  /// Calculates total boundary perimeter in meters.
  static double calculatePerimeter(List<LatLng> corners) {
    final sides = calculateSideLengths(corners);
    return sides.fold(0.0, (sum, side) => sum + side);
  }

  /// Calculates closed polygon area in square meters using spherical shoelace formula.
  static double calculateAreaSquareMeters(List<LatLng> corners) {
    if (corners.length < 3) return 0.0;
    const double metersPerDegreeLat = 111320.0;
    final LatLng origin = corners.first;
    final double metersPerDegreeLng =
        111320.0 * math.cos(origin.latitude * math.pi / 180.0);

    final points = corners
        .map((p) => [
              (p.longitude - origin.longitude) * metersPerDegreeLng,
              (p.latitude - origin.latitude) * metersPerDegreeLat,
            ])
        .toList();

    double areaSum = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      areaSum += points[i][0] * points[j][1] - points[j][0] * points[i][1];
    }

    return areaSum.abs() / 2.0;
  }
}
