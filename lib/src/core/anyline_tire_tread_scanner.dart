import '../platform/flutter_anyline_tire_tread_scanner_platform_interface.dart';
import 'measurement_system.dart';
import 'scanning_event.dart';
import 'tread_depth_result.dart';

/// Provides **AnylineTireTreadScanner** drop in functionality.
class AnylineTireTreadScanner {
  static AnylineTireTreadScannerPlatformInterface get _platform => AnylineTireTreadScannerPlatformInterface.instance;

  static Stream<ScanningEvent> get onScanningEvent => _platform.onScanningEvent;

  static Future<void> setup({
    required String licenseKey,
  }) =>
      _platform.setup(
        licenseKey: licenseKey,
      );

  static Future<void> open({
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) =>
      _platform.open(
        measurementSystem: measurementSystem,
      );

  static Future<TreadDepthResult?> getTreadDepthResult({
    required String uuid,
    MeasurementSystem measurementSystem = MeasurementSystem.metric,
  }) =>
      _platform.getTreadDepthResult(
        uuid: uuid,
        measurementSystem: measurementSystem,
      );
}
