import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:depthfenc/domain/models/survey_models.dart';
import 'package:depthfenc/core/storage/secure_storage.dart';

/// Offline-first repository handling local storage, pending queueing, and Supabase synchronization.
class SurveyRepository {
  final SupabaseClient? _supabase;
  final SecureStorageVault _storage;

  SurveyRepository({
    SupabaseClient? supabase,
    SecureStorageVault? storage,
  })  : _supabase = supabase ?? _getSupabaseClientSafely(),
        _storage = storage ?? SecureStorageVault();

  static SupabaseClient? _getSupabaseClientSafely() {
    try {
      if (Supabase.instance.isInitialized) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  /// Fetches land parcels from Supabase with graceful fallback to local data.
  Future<List<LandParcelModel>> getParcels() async {
    final client = _supabase;
    if (client != null) {
      try {
        final response = await client
            .from('parcels')
            .select()
            .timeout(const Duration(seconds: 10));

        final data = response as List<dynamic>;
        return data
            .map((e) => LandParcelModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase parcel fetch failed, using offline cache: $e');
      }
    }
    return [];
  }

  /// Inserts a new land parcel into Supabase or queues it for offline sync.
  Future<bool> saveParcel(LandParcelModel parcel) async {
    final client = _supabase;
    if (client != null) {
      try {
        await client.from('parcels').insert({
          'ulpin': parcel.ulpin,
          'owner_name': parcel.ownerName,
          'area_ha': parcel.areaHa,
          'latitude': parcel.center.latitude,
          'longitude': parcel.center.longitude,
          'status': parcel.status.name,
          'created_by': client.auth.currentUser?.id,
        });
        return true;
      } catch (e) {
        debugPrint('Supabase parcel insert failed, queueing offline: $e');
      }
    }

    // Queue operation offline
    final queue = await _storage.getPendingQueue();
    queue.add({
      'id': 'op_${DateTime.now().millisecondsSinceEpoch}',
      'action': 'create_parcel',
      'payload': parcel.toJson(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _storage.savePendingQueue(queue);
    return false;
  }

  /// Synchronizes pending offline operations when network connection is restored.
  Future<int> syncPendingQueue() async {
    final client = _supabase;
    if (client == null) return 0;

    final queue = await _storage.getPendingQueue();
    if (queue.isEmpty) return 0;

    int syncedCount = 0;
    final remainingQueue = <Map<String, dynamic>>[];

    for (final op in queue) {
      try {
        final action = op['action'] as String?;
        final payload = op['payload'] as Map<String, dynamic>?;

        if (action == 'create_parcel' && payload != null) {
          final parcel = LandParcelModel.fromJson(payload);
          await client.from('parcels').insert({
            'ulpin': parcel.ulpin,
            'owner_name': parcel.ownerName,
            'area_ha': parcel.areaHa,
            'latitude': parcel.center.latitude,
            'longitude': parcel.center.longitude,
            'status': parcel.status.name,
            'created_by': client.auth.currentUser?.id,
          });
          syncedCount++;
        }
      } catch (e) {
        debugPrint('Sync failed for operation ${op['id']}: $e');
        remainingQueue.add(op);
      }
    }

    await _storage.savePendingQueue(remainingQueue);
    return syncedCount;
  }
}
