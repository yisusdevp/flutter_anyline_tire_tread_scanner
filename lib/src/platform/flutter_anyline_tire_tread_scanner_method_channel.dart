import 'package:flutter/services.dart';

import '../core/measurement_system.dart';
import '../core/scanning_event.dart';
import '../core/tread_depth_result.dart';
import 'flutter_anyline_tire_tread_scanner_platform_interface.dart';

/// An implementation of [AnylineTireTreadScannerPlatformInterface] that uses method channels.
class AnylineTireTreadScannerMethodChannel extends AnylineTireTreadScannerPlatformInterface {
  /// The method channel used to interact with the native platform.
  final _methodChannel = const MethodChannel('geekbears.com/flutter_anyline_tire_tread_scanner');

  /// The event channel used to receive changes from the native platform.
  final _eventsChannel = const EventChannel('geekbears.com/flutter_anyline_tire_tread_scanner/events');

  @override
  Stream<ScanningEvent> get onScanningEvent {
    return _eventsChannel.receiveBroadcastStream().map((event) {
      final eventType = event["event"];

      switch (eventType) {
        case "scan-aborted":
          return ScanningAborted.fromMap(event);
        case "upload-aborted":
          return UploadAbortedEvent.fromMap(event);
        case "upload-completed":
          return UploadCompletedEvent.fromMap(event);
        case "upload-failed":
          return UploadFailedEvent.fromMap(event);
        default:
          return ScanningAborted.fromMap(event);
      }
    });
  }

  @override
  Future<void> setup({
    required String licenseKey,
  }) async =>
      await _methodChannel.invokeMethod(
        'setup',
        licenseKey,
      );

  @override
  Future<void> open({
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) async =>
      await _methodChannel.invokeMethod(
        'open',
        measurementSystem.name,
      );

  @override
  Future<TreadDepthResult?> getTreadDepthResult({
    required String uuid,
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) async {
    final result = await _methodChannel.invokeMethod(
      'getTreadDepthResult',
      {
        'uuid': uuid,
        'measurementSystem': measurementSystem.name,
      },
    );

    if (result == null) return null;

    return TreadDepthResult.fromMap(result!);
  }
}
