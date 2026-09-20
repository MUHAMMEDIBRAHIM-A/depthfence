import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:depthfenc/domain/models/survey_models.dart';
import 'package:depthfenc/data/repositories/survey_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SurveyRepository Offline Queueing Tests', () {
    late SurveyRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SurveyRepository();
    });

    test('saveParcel queues operation when offline', () async {
      final parcel = LandParcelModel(
        id: 'P-999',
        ulpin: 'ULPIN-OFFLINE-TEST',
        ownerName: 'Field Offline Survey',
        areaHa: 1.85,
        center: const LatLng(20.5937, 78.9629),
        status: ParcelStatus.pending,
      );

      final success = await repository.saveParcel(parcel);
      expect(success, isFalse);
    });

    test('getParcels handles offline state gracefully', () async {
      final parcels = await repository.getParcels();
      expect(parcels, isNotNull);
    });
  });
}
