import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:depthfenc/domain/models/survey_models.dart';

void main() {
  group('Domain Models Serialization Tests', () {
    test('LandParcelModel serializes to and from JSON correctly', () {
      final parcel = LandParcelModel(
        id: 'P-101',
        ulpin: 'ULPIN-2026-TEST',
        ownerName: 'Ramesh Kumar',
        areaHa: 2.34,
        center: const LatLng(20.5937, 78.9629),
        status: ParcelStatus.verified,
        confidenceScore: 0.98,
      );

      final json = parcel.toJson();
      expect(json['id'], 'P-101');
      expect(json['ulpin'], 'ULPIN-2026-TEST');
      expect(json['status'], 'verified');

      final deserialized = LandParcelModel.fromJson(json);
      expect(deserialized.id, parcel.id);
      expect(deserialized.ulpin, parcel.ulpin);
      expect(deserialized.center.latitude, parcel.center.latitude);
      expect(deserialized.status, ParcelStatus.verified);
    });

    test('BoundaryNodeModel serializes correctly', () {
      final node = BoundaryNodeModel(
        index: 0,
        point: const LatLng(20.5937, 78.9629),
        status: 'problem',
      );

      final json = node.toJson();
      expect(json['index'], 0);
      expect(json['status'], 'problem');

      final deserialized = BoundaryNodeModel.fromJson(json);
      expect(deserialized.index, 0);
      expect(deserialized.status, 'problem');
    });

    test('AnomalyModel serializes correctly', () {
      final anomaly = AnomalyModel(
        id: 'ANM-99',
        title: 'Unauthorized Fence',
        description: 'Encroachment detected',
        parcelId: 'ULPIN-001',
        severity: AnomalySeverity.critical,
        status: 'new',
        location: const LatLng(20.5937, 78.9629),
        detectedAt: DateTime.now(),
      );

      final json = anomaly.toJson();
      expect(json['id'], 'ANM-99');
      expect(json['severity'], 'critical');

      final deserialized = AnomalyModel.fromJson(json);
      expect(deserialized.id, anomaly.id);
      expect(deserialized.severity, AnomalySeverity.critical);
    });
  });
}
