import 'package:latlong2/latlong.dart';

/// Survey status types for cadastral parcels.
enum ParcelStatus { verified, pending, flagged }

/// Severity level for flagged anomalies.
enum AnomalySeverity { critical, high, medium }

/// Model representing a cadastral land parcel.
class LandParcelModel {
  final String id;
  final String ulpin;
  final String ownerName;
  final double areaHa;
  final LatLng center;
  final ParcelStatus status;
  final double confidenceScore;

  LandParcelModel({
    required this.id,
    required this.ulpin,
    required this.ownerName,
    required this.areaHa,
    required this.center,
    this.status = ParcelStatus.pending,
    this.confidenceScore = 0.95,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ulpin': ulpin,
        'ownerName': ownerName,
        'areaHa': areaHa,
        'latitude': center.latitude,
        'longitude': center.longitude,
        'status': status.name,
        'confidenceScore': confidenceScore,
      };

  factory LandParcelModel.fromJson(Map<String, dynamic> json) {
    return LandParcelModel(
      id: (json['id'] ?? '').toString(),
      ulpin: (json['ulpin'] ?? '').toString(),
      ownerName: (json['ownerName'] ?? 'Field Survey').toString(),
      areaHa: (json['areaHa'] as num?)?.toDouble() ?? 0.0,
      center: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      status: ParcelStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParcelStatus.pending,
      ),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.95,
    );
  }
}

/// Model representing a boundary vertex node.
class BoundaryNodeModel {
  final int index;
  final LatLng point;
  final String status; // 'verified' | 'problem' | 'inspection' | 'normal'

  BoundaryNodeModel({
    required this.index,
    required this.point,
    this.status = 'normal',
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'lat': point.latitude,
        'lng': point.longitude,
        'status': status,
      };

  factory BoundaryNodeModel.fromJson(Map<String, dynamic> json) {
    return BoundaryNodeModel(
      index: (json['index'] as num?)?.toInt() ?? 0,
      point: LatLng(
        (json['lat'] as num?)?.toDouble() ?? 0.0,
        (json['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      status: (json['status'] ?? 'normal').toString(),
    );
  }
}

/// Model representing a geospatial land anomaly log.
class AnomalyModel {
  final String id;
  final String title;
  final String description;
  final String parcelId;
  final AnomalySeverity severity;
  final String status; // 'new' | 'in_progress' | 'resolved'
  final LatLng location;
  final DateTime detectedAt;

  AnomalyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.parcelId,
    required this.severity,
    required this.status,
    required this.location,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'parcelId': parcelId,
        'severity': severity.name,
        'status': status,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'detectedAt': detectedAt.toIso8601String(),
      };

  factory AnomalyModel.fromJson(Map<String, dynamic> json) {
    return AnomalyModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      parcelId: (json['parcelId'] ?? '').toString(),
      severity: AnomalySeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AnomalySeverity.medium,
      ),
      status: (json['status'] ?? 'new').toString(),
      location: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      detectedAt: DateTime.tryParse(json['detectedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
