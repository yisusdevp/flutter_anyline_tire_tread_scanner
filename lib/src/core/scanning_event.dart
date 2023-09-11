abstract class ScanningEvent {
  const ScanningEvent({
    required this.uuid,
  });

  final String? uuid;

  Map<String, dynamic> toMap() => {
        "uuid": uuid,
      };
}

class ScanningAborted extends ScanningEvent {
  const ScanningAborted({
    required super.uuid,
  });

  factory ScanningAborted.fromMap(dynamic map) => ScanningAborted(
        uuid: map["uuid"],
      );
}

class UploadAbortedEvent extends ScanningEvent {
  const UploadAbortedEvent({
    required super.uuid,
  });

  factory UploadAbortedEvent.fromMap(dynamic map) => UploadAbortedEvent(
        uuid: map["uuid"],
      );
}

class UploadCompletedEvent extends ScanningEvent {
  const UploadCompletedEvent({
    required super.uuid,
  });

  factory UploadCompletedEvent.fromMap(dynamic map) => UploadCompletedEvent(
        uuid: map["uuid"],
      );
}

class UploadFailedEvent extends ScanningEvent {
  const UploadFailedEvent({
    required super.uuid,
    required this.error,
  });

  final String error;

  factory UploadFailedEvent.fromMap(dynamic map) => UploadFailedEvent(
        uuid: map["uuid"],
        error: map["error"],
      );
}
