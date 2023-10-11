abstract class AnylineTireTreadScannerException {
  const AnylineTireTreadScannerException({
    required this.code,
    required this.message,
    required this.stackTrace,
  });

  final String code;
  final String message;
  final StackTrace stackTrace;
}

class GetTreadDepthReportResultFailed extends AnylineTireTreadScannerException {
  const GetTreadDepthReportResultFailed({
    required super.code,
    required super.message,
    required super.stackTrace,
  });

  @override
  String toString() =>
      "GetTreadDepthReportResultFailed(\ncode: $code,\nmessage: $message,\nstackTrace: ${stackTrace.toString()}\n)";
}
