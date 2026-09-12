import 'dart:math';

enum FarmStatus { healthy, attention, critical }
enum NotificationCategory { ai, weather, market, harvest, transport, payment, cooperative, scheme }

class Farmer {
  const Farmer({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.village,
    required this.district,
    required this.state,
    required this.language,
    required this.totalLand,
    required this.cooperativeStatus,
  });

  final String id;
  final String fullName;
  final String mobile;
  final String email;
  final String village;
  final String district;
  final String state;
  final String language;
  final double totalLand;
  final String cooperativeStatus;

  Farmer copyWith({
    String? fullName,
    String? mobile,
    String? email,
    String? village,
    String? district,
    String? state,
    String? language,
    double? totalLand,
    String? cooperativeStatus,
  }) {
    return Farmer(
      id: id,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      language: language ?? this.language,
      totalLand: totalLand ?? this.totalLand,
      cooperativeStatus: cooperativeStatus ?? this.cooperativeStatus,
    );
  }
}

class Farm {
  const Farm({
    required this.id,
    required this.userId,
    required this.name,
    required this.landSize,
    required this.unit,
    required this.village,
    required this.location,
    required this.soilType,
    required this.waterSource,
    required this.irrigationType,
    required this.currentCrop,
    required this.plantingDate,
    required this.expectedHarvest,
    required this.soilHealth,
    required this.cropHealth,
    required this.predictedYieldTonnes,
    required this.status,
  });

  final String id;
  final String userId;
  final String name;
  final double landSize;
  final String unit;
  final String village;
  final String location;
  final String soilType;
  final String waterSource;
  final String irrigationType;
  final String currentCrop;
  final DateTime plantingDate;
  final DateTime expectedHarvest;
  final int soilHealth;
  final int cropHealth;
  final double predictedYieldTonnes;
  final FarmStatus status;

  int get cropDay => DateTime.now().difference(plantingDate).inDays.clamp(0, 999).toInt();
  int get cropDuration => expectedHarvest.difference(plantingDate).inDays.clamp(1, 999).toInt();
  double get progress => min(1, cropDay / cropDuration);

  Farm copyWith({
    String? name,
    double? landSize,
    String? unit,
    String? village,
    String? location,
    String? soilType,
    String? waterSource,
    String? irrigationType,
    String? currentCrop,
    DateTime? plantingDate,
    DateTime? expectedHarvest,
    int? soilHealth,
    int? cropHealth,
    double? predictedYieldTonnes,
    FarmStatus? status,
  }) {
    return Farm(
      id: id,
      userId: userId,
      name: name ?? this.name,
      landSize: landSize ?? this.landSize,
      unit: unit ?? this.unit,
      village: village ?? this.village,
      location: location ?? this.location,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      irrigationType: irrigationType ?? this.irrigationType,
      currentCrop: currentCrop ?? this.currentCrop,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvest: expectedHarvest ?? this.expectedHarvest,
      soilHealth: soilHealth ?? this.soilHealth,
      cropHealth: cropHealth ?? this.cropHealth,
      predictedYieldTonnes: predictedYieldTonnes ?? this.predictedYieldTonnes,
      status: status ?? this.status,
    );
  }
}

class CropHistory {
  const CropHistory({
    required this.year,
    required this.crop,
    required this.farm,
    required this.season,
    required this.area,
    required this.yieldTonnes,
    required this.revenue,
  });

  final int year;
  final String crop;
  final String farm;
  final String season;
  final double area;
  final double yieldTonnes;
  final double revenue;
}

class SoilMetric {
  const SoilMetric(this.name, this.value, this.unit, this.status);

  final String name;
  final double value;
  final String unit;
  final String status;
}

class YieldRecord {
  const YieldRecord({
    required this.crop,
    required this.farm,
    required this.harvestDate,
    required this.quantityKg,
    required this.sellingPricePerKg,
    required this.buyer,
    required this.transportationCost,
    required this.labourCost,
    required this.otherExpenses,
  });

  final String crop;
  final String farm;
  final DateTime harvestDate;
  final double quantityKg;
  final double sellingPricePerKg;
  final String buyer;
  final double transportationCost;
  final double labourCost;
  final double otherExpenses;

  double get grossRevenue => quantityKg * sellingPricePerKg;
  double get totalExpenses => transportationCost + labourCost + otherExpenses;
  double get netProfit => grossRevenue - totalExpenses;
  double get profitMargin => grossRevenue == 0 ? 0 : (netProfit / grossRevenue) * 100;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.cards = const [],
    this.warning,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final List<String> cards;
  final String? warning;
}

class DiseaseReport {
  const DiseaseReport({
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.symptoms,
    required this.cause,
    required this.actions,
    required this.treatment,
    required this.prevention,
  });

  final String disease;
  final double confidence;
  final String severity;
  final List<String> symptoms;
  final String cause;
  final List<String> actions;
  final String treatment;
  final String prevention;
}

class CooperativeGroup {
  const CooperativeGroup({
    required this.id,
    required this.name,
    required this.farmers,
    required this.crop,
    required this.combinedTonnes,
    required this.harvestWindow,
    required this.destination,
    required this.saving,
    this.joined = false,
  });

  final String id;
  final String name;
  final int farmers;
  final String crop;
  final double combinedTonnes;
  final String harvestWindow;
  final String destination;
  final double saving;
  final bool joined;

  CooperativeGroup copyWith({bool? joined}) {
    return CooperativeGroup(
      id: id,
      name: name,
      farmers: farmers,
      crop: crop,
      combinedTonnes: combinedTonnes,
      harvestWindow: harvestWindow,
      destination: destination,
      saving: saving,
      joined: joined ?? this.joined,
    );
  }
}

class FarmerLoad {
  const FarmerLoad(this.name, this.loadKg);

  final String name;
  final double loadKg;
}

class CostShare {
  const CostShare(this.name, this.loadKg, this.cost);

  final String name;
  final double loadKg;
  final double cost;
}

class Truck {
  const Truck({
    required this.name,
    required this.capacityTonnes,
    required this.price,
    required this.status,
  });

  final String name;
  final double capacityTonnes;
  final double price;
  final String status;
}

class Buyer {
  const Buyer({
    required this.name,
    required this.crop,
    required this.quantityTonnes,
    required this.offerPerKg,
    required this.distanceKm,
    required this.verified,
    required this.status,
  });

  final String name;
  final String crop;
  final double quantityTonnes;
  final double offerPerKg;
  final double distanceKm;
  final bool verified;
  final String status;
}

class MarketListing {
  const MarketListing({
    required this.id,
    required this.crop,
    required this.variety,
    required this.quantityTonnes,
    required this.pricePerKg,
    required this.grade,
    required this.availableDate,
    required this.farm,
  });

  final String id;
  final String crop;
  final String variety;
  final double quantityTonnes;
  final double pricePerKg;
  final String grade;
  final DateTime availableDate;
  final String farm;
}

class MarketPrice {
  const MarketPrice(this.crop, this.market, this.price, this.changePercent);

  final String crop;
  final String market;
  final double price;
  final double changePercent;
}

class Scheme {
  const Scheme({
    required this.name,
    required this.category,
    required this.eligibility,
    required this.benefit,
    required this.deadline,
    required this.documents,
    required this.website,
  });

  final String name;
  final String category;
  final String eligibility;
  final String benefit;
  final String deadline;
  final List<String> documents;
  final String website;
}

class AgroNotification {
  const AgroNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AgroNotification copyWith({bool? read}) {
    return AgroNotification(
      id: id,
      category: category,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
