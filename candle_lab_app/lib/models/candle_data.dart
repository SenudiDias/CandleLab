// lib/models/candle_data.dart
class WaxDetail {
  String waxType;
  String product;
  String supplier;
  double weight; // in grams
  double percentage; // auto-calculated
  double costPerKg;
  double cost; // auto-calculated

  WaxDetail({
    required this.waxType,
    this.product = '',
    this.supplier = '',
    this.weight = 0.0,
    this.percentage = 0.0,
    this.costPerKg = 0.0,
    this.cost = 0.0,
  });
}

class ContainerDetail {
  int numberOfContainers;
  double weightPerCandle;
  double waxDepth;
  double containerDiameter;
  double cost;
  bool containerHeated;
  String supplier;

  ContainerDetail({
    this.numberOfContainers = 0,
    this.weightPerCandle = 0.0,
    this.waxDepth = 0.0,
    this.containerDiameter = 0.0,
    this.cost = 0.0,
    this.containerHeated = false,
    this.supplier = '',
  });
}

class PillarDetail {
  int numberOfPillars;
  double waxWeight;
  double height;
  double largestWidth;
  double smallestWidth;

  PillarDetail({
    this.numberOfPillars = 0,
    this.waxWeight = 0.0,
    this.height = 0.0,
    this.largestWidth = 0.0,
    this.smallestWidth = 0.0,
  });
}

class MouldDetail {
  String type; // Melt or Wicked
  int number;

  MouldDetail({this.type = 'Melt', this.number = 0});
}

class CandleData {
  String? sampleName;
  String? candleType;
  List<String> waxTypes;
  bool? isWicked;
  bool isScented;
  bool isColoured;
  List<WaxDetail> waxDetails;
  ContainerDetail? containerDetail;
  PillarDetail? pillarDetail;
  MouldDetail? mouldDetail;

  CandleData({
    this.sampleName,
    this.candleType,
    List<String>? waxTypes,
    this.isWicked,
    this.isScented = false,
    this.isColoured = false,
    List<WaxDetail>? waxDetails,
    this.containerDetail,
    this.pillarDetail,
    this.mouldDetail,
  }) : waxTypes = waxTypes != null
           ? List<String>.from(waxTypes)
           : List<String>.empty(growable: true),
       waxDetails = waxDetails != null
           ? List<WaxDetail>.from(waxDetails)
           : List<WaxDetail>.empty(growable: true);
}
