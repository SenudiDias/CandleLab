// lib/models/candle_data.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Map<String, dynamic> toJson() => {
    'waxType': waxType,
    'product': product,
    'supplier': supplier,
    'weight': weight,
    'percentage': percentage,
    'costPerKg': costPerKg,
    'cost': cost,
  };

  factory WaxDetail.fromJson(Map<String, dynamic> json) => WaxDetail(
    waxType: json['waxType'],
    product: json['product'] ?? '',
    supplier: json['supplier'] ?? '',
    weight: json['weight']?.toDouble() ?? 0.0,
    percentage: json['percentage']?.toDouble() ?? 0.0,
    costPerKg: json['costPerKg']?.toDouble() ?? 0.0,
    cost: json['cost']?.toDouble() ?? 0.0,
  );
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

  Map<String, dynamic> toJson() => {
    'numberOfContainers': numberOfContainers,
    'weightPerCandle': weightPerCandle,
    'waxDepth': waxDepth,
    'containerDiameter': containerDiameter,
    'cost': cost,
    'containerHeated': containerHeated,
    'supplier': supplier,
  };

  factory ContainerDetail.fromJson(Map<String, dynamic> json) =>
      ContainerDetail(
        numberOfContainers: json['numberOfContainers'] ?? 0,
        weightPerCandle: json['weightPerCandle']?.toDouble() ?? 0.0,
        waxDepth: json['waxDepth']?.toDouble() ?? 0.0,
        containerDiameter: json['containerDiameter']?.toDouble() ?? 0.0,
        cost: json['cost']?.toDouble() ?? 0.0,
        containerHeated: json['containerHeated'] ?? false,
        supplier: json['supplier'] ?? '',
      );
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

  Map<String, dynamic> toJson() => {
    'numberOfPillars': numberOfPillars,
    'waxWeight': waxWeight,
    'height': height,
    'largestWidth': largestWidth,
    'smallestWidth': smallestWidth,
  };

  factory PillarDetail.fromJson(Map<String, dynamic> json) => PillarDetail(
    numberOfPillars: json['numberOfPillars'] ?? 0,
    waxWeight: json['waxWeight']?.toDouble() ?? 0.0,
    height: json['height']?.toDouble() ?? 0.0,
    largestWidth: json['largestWidth']?.toDouble() ?? 0.0,
    smallestWidth: json['smallestWidth']?.toDouble() ?? 0.0,
  );
}

class MouldDetail {
  String type; // Melt or Wicked
  int number;

  MouldDetail({this.type = 'Melt', this.number = 0});

  Map<String, dynamic> toJson() => {'type': type, 'number': number};

  factory MouldDetail.fromJson(Map<String, dynamic> json) =>
      MouldDetail(type: json['type'] ?? 'Melt', number: json['number'] ?? 0);
}

class WickDetail {
  int numberOfWicks;
  String wickType;
  double wickCost;
  double stickerCost;

  WickDetail({
    this.numberOfWicks = 0,
    this.wickType = 'Cotton',
    this.wickCost = 0.0,
    this.stickerCost = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'numberOfWicks': numberOfWicks,
    'wickType': wickType,
    'wickCost': wickCost,
    'stickerCost': stickerCost,
  };

  factory WickDetail.fromJson(Map<String, dynamic> json) => WickDetail(
    numberOfWicks: json['numberOfWicks'] ?? 0,
    wickType: json['wickType'] ?? 'Cotton',
    wickCost: json['wickCost']?.toDouble() ?? 0.0,
    stickerCost: json['stickerCost']?.toDouble() ?? 0.0,
  );
}

class ScentDetail {
  String scentType;
  String supplier;
  double weight;
  double percentage;
  double volume;
  double cost;

  ScentDetail({
    this.scentType = 'Seasalt and Driftwood',
    this.supplier = '',
    this.weight = 0.0,
    this.percentage = 0.0,
    this.volume = 0.0,
    this.cost = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'scentType': scentType,
    'supplier': supplier,
    'weight': weight,
    'percentage': percentage,
    'volume': volume,
    'cost': cost,
  };

  factory ScentDetail.fromJson(Map<String, dynamic> json) => ScentDetail(
    scentType: json['scentType'] ?? 'Seasalt and Driftwood',
    supplier: json['supplier'] ?? '',
    weight: json['weight']?.toDouble() ?? 0.0,
    percentage: json['percentage']?.toDouble() ?? 0.0,
    volume: json['volume']?.toDouble() ?? 0.0,
    cost: json['cost']?.toDouble() ?? 0.0,
  );
}

class ColourDetail {
  String colour;
  String supplier;
  double weight;
  double percentage;
  double cost;

  ColourDetail({
    this.colour = '',
    this.supplier = '',
    this.weight = 0.0,
    this.percentage = 0.0,
    this.cost = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'colour': colour,
    'supplier': supplier,
    'weight': weight,
    'percentage': percentage,
    'cost': cost,
  };

  factory ColourDetail.fromJson(Map<String, dynamic> json) => ColourDetail(
    colour: json['colour'] ?? '',
    supplier: json['supplier'] ?? '',
    weight: json['weight']?.toDouble() ?? 0.0,
    percentage: json['percentage']?.toDouble() ?? 0.0,
    cost: json['cost']?.toDouble() ?? 0.0,
  );
}

class TemperatureDetail {
  double maxHeatedC;
  double maxHeatedF;
  double fragranceMixingC;
  double fragranceMixingF;
  double pouringC;
  double pouringF;
  double ambientTempC;
  double ambientTempF;
  List<String> photoPaths;

  TemperatureDetail({
    this.maxHeatedC = 0.0,
    this.maxHeatedF = 0.0,
    this.fragranceMixingC = 0.0,
    this.fragranceMixingF = 0.0,
    this.pouringC = 0.0,
    this.pouringF = 0.0,
    this.ambientTempC = 0.0,
    this.ambientTempF = 0.0,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toJson() => {
    'maxHeatedC': maxHeatedC,
    'maxHeatedF': maxHeatedF,
    'fragranceMixingC': fragranceMixingC,
    'fragranceMixingF': fragranceMixingF,
    'pouringC': pouringC,
    'pouringF': pouringF,
    'ambientTempC': ambientTempC,
    'ambientTempF': ambientTempF,
    'photoPaths': photoPaths,
  };

  factory TemperatureDetail.fromJson(Map<String, dynamic> json) =>
      TemperatureDetail(
        maxHeatedC: json['maxHeatedC']?.toDouble() ?? 0.0,
        maxHeatedF: json['maxHeatedF']?.toDouble() ?? 0.0,
        fragranceMixingC: json['fragranceMixingC']?.toDouble() ?? 0.0,
        fragranceMixingF: json['fragranceMixingF']?.toDouble() ?? 0.0,
        pouringC: json['pouringC']?.toDouble() ?? 0.0,
        pouringF: json['pouringF']?.toDouble() ?? 0.0,
        ambientTempC: json['ambientTempC']?.toDouble() ?? 0.0,
        ambientTempF: json['ambientTempF']?.toDouble() ?? 0.0,
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
      );
}

class CoolingCuringDetail {
  double coolDownTime;
  int curingDays;
  DateTime? burningDay;
  TimeOfDay? reminderTime;
  List<String> photoPaths;

  CoolingCuringDetail({
    this.coolDownTime = 0.0,
    this.curingDays = 0,
    this.burningDay,
    this.reminderTime,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toJson() => {
    'coolDownTime': coolDownTime,
    'curingDays': curingDays,
    'burningDay': burningDay?.toIso8601String(),
    'reminderTime': reminderTime != null
        ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
        : null,
    'photoPaths': photoPaths,
  };

  factory CoolingCuringDetail.fromJson(Map<String, dynamic> json) =>
      CoolingCuringDetail(
        coolDownTime: json['coolDownTime']?.toDouble() ?? 0.0,
        curingDays: json['curingDays'] ?? 0,
        burningDay: json['burningDay'] != null
            ? DateTime.parse(json['burningDay'])
            : null,
        reminderTime: json['reminderTime'] != null
            ? TimeOfDay(
                hour: json['reminderTime']['hour'],
                minute: json['reminderTime']['minute'],
              )
            : null,
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
      );
}

class CandleData {
  String? id;
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
  WickDetail? wickDetail;
  ScentDetail? scentDetail;
  ColourDetail? colourDetail;
  TemperatureDetail? temperatureDetail;
  CoolingCuringDetail? coolingCuringDetail;
  DateTime? createdAt;
  double? totalCost; // Added total cost field
  static List<String> availableScentTypes = ['Seasalt', 'Driftwood'];

  CandleData({
    this.id,
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
    this.wickDetail,
    this.scentDetail,
    this.colourDetail,
    this.temperatureDetail,
    this.coolingCuringDetail,
    this.createdAt,
    this.totalCost,
  }) : waxTypes = waxTypes != null
           ? List<String>.from(waxTypes)
           : List<String>.empty(growable: true),
       waxDetails = waxDetails != null
           ? List<WaxDetail>.from(waxDetails)
           : List<WaxDetail>.empty(growable: true);

  // Calculate total cost per candle
  double calculateTotalCost() {
    double total = 0.0;
    int numberOfCandles = 1;

    // Determine number of candles based on candle type
    if (candleType == 'Container' && containerDetail != null) {
      numberOfCandles = containerDetail!.numberOfContainers;
    } else if (candleType == 'Pillar' && pillarDetail != null) {
      numberOfCandles = pillarDetail!.numberOfPillars;
    } else if (candleType == 'Mould' && mouldDetail != null) {
      numberOfCandles = mouldDetail!.number;
    }

    if (numberOfCandles == 0) numberOfCandles = 1; // Avoid division by zero

    // Add Wax cost
    for (var wax in waxDetails) {
      total += wax.cost;
    }

    // Add Container cost
    if (candleType == 'Container' && containerDetail != null) {
      total += containerDetail!.cost;
    }

    // Add Wick and Wick Sticker costs
    if ((isWicked == true ||
            candleType == 'Container' ||
            candleType == 'Pillar') &&
        wickDetail != null) {
      total += wickDetail!.wickCost + wickDetail!.stickerCost;
    }

    // Add Scent cost
    if (isScented && scentDetail != null) {
      total += scentDetail!.cost;
    }

    // Add Colour cost
    if (isColoured && colourDetail != null) {
      total += colourDetail!.cost;
    }

    // Calculate cost per candle
    return numberOfCandles > 0 ? total / numberOfCandles : total;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sampleName': sampleName,
    'candleType': candleType,
    'waxTypes': waxTypes,
    'isWicked': isWicked,
    'isScented': isScented,
    'isColoured': isColoured,
    'waxDetails': waxDetails.map((detail) => detail.toJson()).toList(),
    'containerDetail': containerDetail?.toJson(),
    'pillarDetail': pillarDetail?.toJson(),
    'mouldDetail': mouldDetail?.toJson(),
    'wickDetail': wickDetail?.toJson(),
    'scentDetail': scentDetail?.toJson(),
    'colourDetail': colourDetail?.toJson(),
    'temperatureDetail': temperatureDetail?.toJson(),
    'coolingCuringDetail': coolingCuringDetail?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
    'totalCost': totalCost,
  };

  factory CandleData.fromJson(Map<String, dynamic> json) => CandleData(
    id: json['id'],
    sampleName: json['sampleName'],
    candleType: json['candleType'],
    waxTypes: List<String>.from(json['waxTypes'] ?? []),
    isWicked: json['isWicked'],
    isScented: json['isScented'] ?? false,
    isColoured: json['isColoured'] ?? false,
    waxDetails:
        (json['waxDetails'] as List<dynamic>?)
            ?.map((item) => WaxDetail.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [],
    containerDetail: json['containerDetail'] != null
        ? ContainerDetail.fromJson(json['containerDetail'])
        : null,
    pillarDetail: json['pillarDetail'] != null
        ? PillarDetail.fromJson(json['pillarDetail'])
        : null,
    mouldDetail: json['mouldDetail'] != null
        ? MouldDetail.fromJson(json['mouldDetail'])
        : null,
    wickDetail: json['wickDetail'] != null
        ? WickDetail.fromJson(json['wickDetail'])
        : null,
    scentDetail: json['scentDetail'] != null
        ? ScentDetail.fromJson(json['scentDetail'])
        : null,
    colourDetail: json['colourDetail'] != null
        ? ColourDetail.fromJson(json['colourDetail'])
        : null,
    temperatureDetail: json['temperatureDetail'] != null
        ? TemperatureDetail.fromJson(json['temperatureDetail'])
        : null,
    coolingCuringDetail: json['coolingCuringDetail'] != null
        ? CoolingCuringDetail.fromJson(json['coolingCuringDetail'])
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    totalCost: json['totalCost']?.toDouble(),
  );
}
