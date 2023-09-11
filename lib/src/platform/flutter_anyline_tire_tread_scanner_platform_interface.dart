import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../core/measurement_system.dart';
import '../core/scanning_event.dart';
import '../core/tread_depth_result.dart';
import 'flutter_anyline_tire_tread_scanner_method_channel.dart';

abstract class AnylineTireTreadScannerPlatformInterface extends PlatformInterface {
  /// Constructs a FlutterAnylineTireTreadScannerPlatform.
  AnylineTireTreadScannerPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static AnylineTireTreadScannerPlatformInterface _instance = AnylineTireTreadScannerMethodChannel();

  /// The default instance of [AnylineTireTreadScannerPlatformInterface] to use.
  ///
  /// Defaults to [AnylineTireTreadScannerMethodChannel].
  static AnylineTireTreadScannerPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AnylineTireTreadScannerPlatformInterface] when
  /// they register themselves.
  static set instance(AnylineTireTreadScannerPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<ScanningEvent> get onScanningEvent {
    throw UnimplementedError('onEvent has not been implemented.');
  }

  Future<void> setup({
    required String licenseKey,
  }) {
    throw UnimplementedError('setup() has not been implemented.');
  }

  Future<void> open({
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) {
    throw UnimplementedError('open() has not been implemented.');
  }

  Future<TreadDepthResult?> getTreadDepthResult({
    required String uuid,
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) {
    throw UnimplementedError('open() has not been implemented.');
  }
}
