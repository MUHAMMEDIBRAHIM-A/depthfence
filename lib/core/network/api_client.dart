import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Network exception wrapper for DepthFence API operations.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() =>
      'ApiException: $message ${statusCode != null ? "($statusCode)" : ""}';
}

/// Offline pending operation item for resilient background synchronization.
class PendingSyncOperation {
  final String id;
  final String action; // 'create_parcel' | 'log_anomaly' | 'update_status'
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  PendingSyncOperation({
    required this.id,
    required this.action,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'] as String,
      action: json['action'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Robust HTTP API client with retries, timeout management, and logging.
class ApiClient {
  final http.Client _client;
  final Duration timeout;
  final int maxRetries;

  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 3,
  }) : _client = client ?? http.Client();

  /// Executes HTTP POST request with automatic exponential backoff retry.
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        debugPrint('🌐 HTTP POST Attempt $attempts/$maxRetries -> $uri');
        final response = await _client
            .post(uri, headers: headers, body: body)
            .timeout(timeout);

        if (response.statusCode >= 500 && attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }

        return response;
      } on TimeoutException {
        if (attempts >= maxRetries) {
          throw ApiException('Request timed out after $maxRetries attempts');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } on SocketException catch (e) {
        if (attempts >= maxRetries) {
          throw ApiException('Network unreachable: ${e.message}');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } catch (e) {
        throw ApiException('Unexpected network error: $e');
      }
    }
  }

  /// Closes client resources.
  void dispose() {
    _client.close();
  }
}
