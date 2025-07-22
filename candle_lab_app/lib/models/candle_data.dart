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
    waxType: json['waxType'] ?? 'Unknown',
    product: json['product'] ?? '',
    supplier: json['supplier'] ?? '',
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    costPerKg: (json['costPerKg'] as num?)?.toDouble() ?? 0.0,
    cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
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
        numberOfContainers: (json['numberOfContainers'] as num?)?.toInt() ?? 0,
        weightPerCandle: (json['weightPerCandle'] as num?)?.toDouble() ?? 0.0,
        waxDepth: (json['waxDepth'] as num?)?.toDouble() ?? 0.0,
        containerDiameter:
            (json['containerDiameter'] as num?)?.toDouble() ?? 0.0,
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        containerHeated: json['containerHeated'] as bool? ?? false,
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
    numberOfPillars: (json['numberOfPillars'] as num?)?.toInt() ?? 0,
    waxWeight: (json['waxWeight'] as num?)?.toDouble() ?? 0.0,
    height: (json['height'] as num?)?.toDouble() ?? 0.0,
    largestWidth: (json['largestWidth'] as num?)?.toDouble() ?? 0.0,
    smallestWidth: (json['smallestWidth'] as num?)?.toDouble() ?? 0.0,
  );
}

class MouldDetail {
  String type; // Melt or Wicked
  int number;

  MouldDetail({this.type = 'Melt', this.number = 0});

  Map<String, dynamic> toJson() => {'type': type, 'number': number};

  factory MouldDetail.fromJson(Map<String, dynamic> json) => MouldDetail(
    type: json['type'] ?? 'Melt',
    number: (json['number'] as num?)?.toInt() ?? 0,
  );
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
    numberOfWicks: (json['numberOfWicks'] as num?)?.toInt() ?? 0,
    wickType: json['wickType'] ?? 'Cotton',
    wickCost: (json['wickCost'] as num?)?.toDouble() ?? 0.0,
    stickerCost: (json['stickerCost'] as num?)?.toDouble() ?? 0.0,
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
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
    cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
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
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
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
        maxHeatedC: (json['maxHeatedC'] as num?)?.toDouble() ?? 0.0,
        maxHeatedF: (json['maxHeatedF'] as num?)?.toDouble() ?? 0.0,
        fragranceMixingC: (json['fragranceMixingC'] as num?)?.toDouble() ?? 0.0,
        fragranceMixingF: (json['fragranceMixingF'] as num?)?.toDouble() ?? 0.0,
        pouringC: (json['pouringC'] as num?)?.toDouble() ?? 0.0,
        pouringF: (json['pouringF'] as num?)?.toDouble() ?? 0.0,
        ambientTempC: (json['ambientTempC'] as num?)?.toDouble() ?? 0.0,
        ambientTempF: (json['ambientTempF'] as num?)?.toDouble() ?? 0.0,
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
        coolDownTime: (json['coolDownTime'] as num?)?.toDouble() ?? 0.0,
        curingDays: (json['curingDays'] as num?)?.toInt() ?? 0,
        burningDay: json['burningDay'] != null
            ? DateTime.tryParse(json['burningDay'] as String) ?? null
            : null,
        reminderTime: json['reminderTime'] != null
            ? TimeOfDay(
                hour: (json['reminderTime']['hour'] as num?)?.toInt() ?? 0,
                minute: (json['reminderTime']['minute'] as num?)?.toInt() ?? 0,
              )
            : null,
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
      );
}

class ScentThrow {
  String coldThrow; // Strong, Moderate, Weak, No scent
  Map<double, String>
  hotThrow; // Key: distance (0.5, 1, 2, 4), Value: Strong, Moderate, Weak, No scent

  ScentThrow({this.coldThrow = '', Map<double, String>? hotThrow})
    : hotThrow = hotThrow ?? {0.5: '', 1: '', 2: '', 4: ''};

  Map<String, dynamic> toJson() => {
    'coldThrow': coldThrow,
    'hotThrow': hotThrow.map((key, value) => MapEntry(key.toString(), value)),
  };

  factory ScentThrow.fromJson(Map<String, dynamic> json) => ScentThrow(
    coldThrow: json['coldThrow'] as String? ?? '',
    hotThrow: Map<double, String>.from(
      (json['hotThrow'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(double.tryParse(key) ?? 0.0, value as String),
          ) ??
          {0.5: '', 1: '', 2: '', 4: ''},
    ),
  );
}

class MeltMeasure {
  double time;
  double meltDiameter;
  double meltDepth;
  double fullMelt;
  List<String> photoPaths;

  MeltMeasure({
    required this.time,
    this.meltDiameter = 0.0,
    this.meltDepth = 0.0,
    this.fullMelt = 0.0,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? [];

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'meltDiameter': meltDiameter,
      'meltDepth': meltDepth,
      'fullMelt': fullMelt,
      'photoPaths': photoPaths,
    };
  }

  factory MeltMeasure.fromJson(Map<String, dynamic> json) {
    return MeltMeasure(
      time: (json['time'] as num).toDouble(),
      meltDiameter: (json['meltDiameter'] as num?)?.toDouble() ?? 0.0,
      meltDepth: (json['meltDepth'] as num?)?.toDouble() ?? 0.0,
      fullMelt: (json['fullMelt'] as num?)?.toDouble() ?? 0.0,
      photoPaths: (json['photoPaths'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class FlameRecord {
  Map<double, String>
  flameSizes; // Key: hours (0, 0.5, 1, etc.), Value: Too Big, Perfect, Too Small
  bool flickering;
  bool mushrooming;
  bool sooting;
  Duration? fullBurningTime;
  String records;
  List<String> photoPaths;
  ScentThrow? scentThrow;
  List<MeltMeasure> meltMeasures;

  FlameRecord({
    Map<double, String>? flameSizes,
    this.flickering = false,
    this.mushrooming = false,
    this.sooting = false,
    this.fullBurningTime,
    this.records = '',
    this.photoPaths = const [],
    this.scentThrow,
    List<MeltMeasure>? meltMeasures,
  }) : flameSizes = flameSizes ?? {0: '', 0.5: '', 1: ''},
       meltMeasures =
           meltMeasures ??
           [
             MeltMeasure(time: 0.5),
             MeltMeasure(time: 1.0),
             MeltMeasure(time: 1.5),
           ];

  Map<String, dynamic> toJson() => {
    'flameSizes': flameSizes.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    'flickering': flickering,
    'mushrooming': mushrooming,
    'sooting': sooting,
    'fullBurningTime': fullBurningTime?.inMinutes,
    'records': records,
    'photoPaths': photoPaths,
    'scentThrow': scentThrow?.toJson(),
    'meltMeasures': meltMeasures.map((measure) => measure.toJson()).toList(),
  };

  factory FlameRecord.fromJson(Map<String, dynamic> json) => FlameRecord(
    flameSizes: Map<double, String>.from(
      (json['flameSizes'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(double.tryParse(key) ?? 0.0, value as String),
          ) ??
          {0: '', 0.5: '', 1: ''},
    ),
    flickering: json['flickering'] as bool? ?? false,
    mushrooming: json['mushrooming'] as bool? ?? false,
    sooting: json['sooting'] as bool? ?? false,
    fullBurningTime: json['fullBurningTime'] != null
        ? Duration(minutes: (json['fullBurningTime'] as num).toInt())
        : null,
    records: json['records'] as String? ?? '',
    photoPaths: List<String>.from(json['photoPaths'] ?? []),
    scentThrow: json['scentThrow'] != null
        ? ScentThrow.fromJson(json['scentThrow'] as Map<String, dynamic>)
        : null,
    meltMeasures:
        (json['meltMeasures'] as List<dynamic>?)
            ?.map((item) => MeltMeasure.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [
          MeltMeasure(time: 0.5),
          MeltMeasure(time: 1.0),
          MeltMeasure(time: 1.5),
        ],
  );
}

class CandleData {
  String? id;
  String? userId; // Added userId field
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
  double? totalCost;
  DateTime? flameDate;
  TimeOfDay? flameTime;
  FlameRecord? flameRecord;
  bool isFlamed;
  static List<String> availableScentTypes = ['Seasalt', 'Driftwood'];

  CandleData({
    this.id,
    this.userId,
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
    this.flameDate,
    this.flameTime,
    this.flameRecord,
    this.isFlamed = false,
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

  // Reset all fields to initial state
  void reset() {
    id = null;
    userId = null;
    sampleName = null;
    candleType = null;
    waxTypes.clear();
    isWicked = null;
    isScented = false;
    isColoured = false;
    waxDetails.clear();
    containerDetail = null;
    pillarDetail = null;
    mouldDetail = null;
    wickDetail = null;
    scentDetail = null;
    colourDetail = null;
    temperatureDetail = null;
    coolingCuringDetail = null;
    createdAt = null;
    totalCost = null;
    flameDate = null;
    flameTime = null;
    flameRecord = null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
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
    'flameDate': flameDate?.toIso8601String(),
    'flameTime': flameTime != null
        ? {'hour': flameTime!.hour, 'minute': flameTime!.minute}
        : null,
    'flameRecord': flameRecord?.toJson(),
    'isFlamed': isFlamed,
  };

  factory CandleData.fromJson(Map<String, dynamic> json) {
    try {
      return CandleData(
        id: json['id'] as String?,
        userId: json['userId'] as String?,
        sampleName: json['sampleName'] as String?,
        candleType: json['candleType'] as String?,
        waxTypes: List<String>.from(json['waxTypes'] ?? []),
        isWicked: json['isWicked'] as bool?,
        isScented: json['isScented'] as bool? ?? false,
        isColoured: json['isColoured'] as bool? ?? false,
        waxDetails:
            (json['waxDetails'] as List<dynamic>?)
                ?.map(
                  (item) => WaxDetail.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [],
        containerDetail: json['containerDetail'] != null
            ? ContainerDetail.fromJson(
                json['containerDetail'] as Map<String, dynamic>,
              )
            : null,
        pillarDetail: json['pillarDetail'] != null
            ? PillarDetail.fromJson(
                json['pillarDetail'] as Map<String, dynamic>,
              )
            : null,
        mouldDetail: json['mouldDetail'] != null
            ? MouldDetail.fromJson(json['mouldDetail'] as Map<String, dynamic>)
            : null,
        wickDetail: json['wickDetail'] != null
            ? WickDetail.fromJson(json['wickDetail'] as Map<String, dynamic>)
            : null,
        scentDetail: json['scentDetail'] != null
            ? ScentDetail.fromJson(json['scentDetail'] as Map<String, dynamic>)
            : null,
        colourDetail: json['colourDetail'] != null
            ? ColourDetail.fromJson(
                json['colourDetail'] as Map<String, dynamic>,
              )
            : null,
        temperatureDetail: json['temperatureDetail'] != null
            ? TemperatureDetail.fromJson(
                json['temperatureDetail'] as Map<String, dynamic>,
              )
            : null,
        coolingCuringDetail: json['coolingCuringDetail'] != null
            ? CoolingCuringDetail.fromJson(
                json['coolingCuringDetail'] as Map<String, dynamic>,
              )
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? null
            : null,
        totalCost: (json['totalCost'] as num?)?.toDouble(),
        flameDate: json['flameDate'] != null
            ? DateTime.tryParse(json['flameDate'] as String) ?? null
            : null,
        flameTime: json['flameTime'] != null
            ? TimeOfDay(
                hour: (json['flameTime']['hour'] as num?)?.toInt() ?? 0,
                minute: (json['flameTime']['minute'] as num?)?.toInt() ?? 0,
              )
            : null,
        flameRecord: json['flameRecord'] != null
            ? FlameRecord.fromJson(json['flameRecord'] as Map<String, dynamic>)
            : null,
        isFlamed: json['isFlamed'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing CandleData: $e');
      rethrow;
    }
  }
}
