class TreadDepthResult {
  const TreadDepthResult({
    required this.uuid,
    required this.measurementResult,
  });

  final String uuid;
  final MeasurementResult measurementResult;

  factory TreadDepthResult.fromMap(dynamic map) {
    return TreadDepthResult(
      uuid: map["uuid"],
      measurementResult: MeasurementResult.fromMap(map["measurementResult"]),
    );
  }

  @override
  int get hashCode => Object.hash(uuid, measurementResult);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;

    return other is TreadDepthResult && other.uuid == uuid && other.measurementResult == measurementResult;
  }

  @override
  String toString() {
    return "TreadDepthResult(\nuuid: $uuid, measurementResult: $measurementResult\n)";
  }
}

class MeasurementResult {
  const MeasurementResult({
    required this.topTire,
    required this.leftTire,
    required this.middleTire,
    required this.rightTire,
  });

  final double topTire;
  final double? leftTire;
  final double? middleTire;
  final double? rightTire;

  factory MeasurementResult.fromMap(dynamic map) {
    return MeasurementResult(
      topTire: map["topTire"],
      leftTire: map["leftTire"],
      middleTire: map["middleTire"],
      rightTire: map["rightTire"],
    );
  }

  @override
  String toString() {
    return "MeasurementResult(\ntopTire: $topTire,\nleftTire: $leftTire,\nmiddleTire: $middleTire,\nrightTire: $rightTire\n)";
  }

  @override
  int get hashCode => Object.hash(topTire, leftTire, middleTire, rightTire);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;

    return other is MeasurementResult &&
        other.topTire == topTire &&
        other.leftTire == leftTire &&
        other.middleTire == middleTire &&
        other.rightTire == rightTire;
  }
}
