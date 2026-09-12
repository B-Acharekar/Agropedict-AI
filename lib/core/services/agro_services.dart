import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_config.dart';
import '../../models/entities.dart';

class FinanceService {
  const FinanceService();

  YieldRecord createYieldRecord({
    required String crop,
    required String farm,
    required DateTime harvestDate,
    required double quantityKg,
    required double sellingPricePerKg,
    required String buyer,
    required double transportationCost,
    required double labourCost,
    required double otherExpenses,
  }) {
    return YieldRecord(
      crop: crop,
      farm: farm,
      harvestDate: harvestDate,
      quantityKg: quantityKg,
      sellingPricePerKg: sellingPricePerKg,
      buyer: buyer,
      transportationCost: transportationCost,
      labourCost: labourCost,
      otherExpenses: otherExpenses,
    );
  }
}

class LogisticsService {
  const LogisticsService();

  List<CostShare> splitTransportCost({
    required double totalCost,
    required List<FarmerLoad> loads,
  }) {
    final totalLoad = loads.fold<double>(0, (sum, item) => sum + item.loadKg);
    if (totalLoad <= 0) return [];
    return loads
        .map((load) => CostShare(load.name, load.loadKg, totalCost * load.loadKg / totalLoad))
        .toList();
  }

  List<Truck> allocateTrucks(double requiredTonnes, List<Truck> trucks) {
    final available = trucks.where((truck) => truck.status != 'Booked').toList()
      ..sort((a, b) => b.capacityTonnes.compareTo(a.capacityTonnes));
    final selected = <Truck>[];
    var remaining = requiredTonnes;
    for (final truck in available) {
      if (remaining <= 0) break;
      selected.add(truck);
      remaining -= truck.capacityTonnes;
    }
    return selected;
  }

  List<RouteStop> optimizeRoute(List<RouteStop> stops) {
    if (stops.length <= 2) return stops;
    final remaining = stops.skip(1).toList();
    final ordered = <RouteStop>[stops.first];
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = ordered.last.distanceTo(a);
        final db = ordered.last.distanceTo(b);
        return da.compareTo(db);
      });
      ordered.add(remaining.removeAt(0));
    }
    return ordered;
  }
}

class RouteStop {
  const RouteStop(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;

  double distanceTo(RouteStop other) {
    final dx = lat - other.lat;
    final dy = lng - other.lng;
    return sqrt(dx * dx + dy * dy);
  }
}

class CooperativeService {
  const CooperativeService();

  double compatibilityScore({
    required String crop,
    required String otherCrop,
    required DateTime harvestDate,
    required DateTime otherHarvestDate,
    required double distanceKm,
    required String market,
    required String otherMarket,
  }) {
    final cropScore = crop.toLowerCase() == otherCrop.toLowerCase() ? 35 : 5;
    final dateGap = harvestDate.difference(otherHarvestDate).inDays.abs();
    final dateScore = max(0, 30 - (dateGap * 4));
    final distanceScore = max(0, 20 - distanceKm);
    final marketScore = market == otherMarket ? 15 : 3;
    return (cropScore + dateScore + distanceScore + marketScore).clamp(0, 100).toDouble();
  }
}

class HarvestService {
  const HarvestService();

  HarvestRecommendation recommend({
    required List<WeatherDay> weather,
    required List<MarketForecast> prices,
    required bool labourAvailable,
    required bool truckAvailable,
    required bool buyerAvailable,
  }) {
    final scores = <DateTime, double>{};
    for (final day in weather) {
      final price = prices.firstWhere(
        (item) => _sameDay(item.date, day.date),
        orElse: () => MarketForecast(day.date, 20),
      );
      final weatherScore = switch (day.risk) {
        'Best' => 35,
        'Good' => 25,
        'Avoid' => -20,
        _ => 10,
      };
      scores[day.date] = weatherScore + price.pricePerKg + (labourAvailable ? 12 : 0) + (truckAvailable ? 10 : 0) + (buyerAvailable ? 10 : 0);
    }
    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final confidence = best.value.clamp(45, 95).round();
    return HarvestRecommendation(
      date: best.key,
      confidence: confidence,
      reason: 'Recommended because weather risk is low, buyer demand is available, and market prices are strong.',
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class WeatherDay {
  const WeatherDay(this.date, this.condition, this.risk);

  final DateTime date;
  final String condition;
  final String risk;
}

class MarketForecast {
  const MarketForecast(this.date, this.pricePerKg);

  final DateTime date;
  final double pricePerKg;
}

class HarvestRecommendation {
  const HarvestRecommendation({
    required this.date,
    required this.confidence,
    required this.reason,
  });

  final DateTime date;
  final int confidence;
  final String reason;
}

class AgroAiService {
  AgroAiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<ChatMessage> ask(
    String prompt, {
    Farmer? farmer,
    List<Farm> farms = const [],
    List<MarketPrice> marketPrices = const [],
    List<Scheme> schemes = const [],
    String language = 'English',
  }) async {
    final key = dotenv.env['GROQ_API_KEY'] ?? const String.fromEnvironment('GROQ_API_KEY');
    if (key.trim().isEmpty) return _fallback(prompt);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.groqEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 35),
          sendTimeout: const Duration(seconds: 20),
        ),
        data: {
          'model': AppConfig.groqModel,
          'temperature': 0.45,
          'max_completion_tokens': 550,
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt(language),
            },
            {
              'role': 'user',
              'content': _farmContext(
                prompt: prompt,
                farmer: farmer,
                farms: farms,
                marketPrices: marketPrices,
                schemes: schemes,
              ),
            },
          ],
        },
      );
      final choices = response.data?['choices'] as List<dynamic>?;
      final message = choices?.isNotEmpty == true ? choices!.first['message'] as Map<String, dynamic>? : null;
      final content = (message?['content'] as String?)?.trim();
      if (content == null || content.isEmpty) return _fallback(prompt);
      return ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        createdAt: DateTime.now(),
        text: content,
        cards: _cardsFor(prompt, farms),
      );
    } catch (_) {
      return _fallback(prompt);
    }
  }

  String _systemPrompt(String language) {
    return '''
You are Agro AI, a practical farming assistant for Indian farmers.
Reply in $language when possible. If the farmer mixes languages, mirror them naturally.
Keep answers short, field-ready, and action oriented.
Cover fertilizer recommendations, crop disease guidance, crop advice, market timing, and government schemes when asked.
For pesticides, fungicides, fertilizer doses, or disease treatment, include a safety note to verify dosage with a local agriculture officer or product label.
Do not claim you inspected an image unless the user came from the crop scan flow or provided disease details.
''';
  }

  String _farmContext({
    required String prompt,
    Farmer? farmer,
    required List<Farm> farms,
    required List<MarketPrice> marketPrices,
    required List<Scheme> schemes,
  }) {
    final farmLines = farms
        .map((farm) => '${farm.name}: ${farm.landSize} ${farm.unit}, ${farm.currentCrop}, soil ${farm.soilHealth}%, crop ${farm.cropHealth}%, soil type ${farm.soilType}, irrigation ${farm.irrigationType}, water ${farm.waterSource}, predicted yield ${farm.predictedYieldTonnes} tonnes')
        .join('\n');
    final priceLines = marketPrices.map((price) => '${price.crop} at ${price.market}: Rs ${price.price}/kg, change ${price.changePercent}%').join('\n');
    final schemeLines = schemes.map((scheme) => '${scheme.name}: ${scheme.benefit}, documents ${scheme.documents.join(', ')}').join('\n');

    return '''
Farmer: ${farmer?.fullName ?? 'Unknown'}
Location: ${farmer?.village ?? 'Unknown'}, ${farmer?.district ?? 'Unknown'}, ${farmer?.state ?? 'Unknown'}
Preferred language: ${farmer?.language ?? 'English'}

Farm digital twin:
$farmLines

Market prices:
$priceLines

Relevant government schemes:
$schemeLines

Question:
$prompt
''';
  }

  ChatMessage _fallback(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('fertilizer') || lower.contains('nitrogen')) {
      return ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        createdAt: DateTime.now(),
        text: 'Your tomato crop is in flowering stage. Add nitrogen carefully and balance it with potash to support fruit setting.',
        cards: const ['Urea: 18 kg/acre split dose', 'Potash: 12 kg/acre after irrigation', 'Avoid application before heavy rain'],
        warning: 'Delay fertilizer if rainfall is expected within 24 hours.',
      );
    }
    if (lower.contains('yellow') || lower.contains('disease') || lower.contains('leaves')) {
      return ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        createdAt: DateTime.now(),
        text: 'Yellowing tomato leaves can indicate nitrogen deficiency, water stress, or early blight. Scan a leaf photo for a stronger diagnosis.',
        cards: const ['Check lower leaves first', 'Inspect for brown rings or lesions', 'Keep drip irrigation consistent'],
      );
    }
    if (lower.contains('scheme')) {
      return ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        createdAt: DateTime.now(),
        text: 'You may be eligible for PM-KISAN, PMFBY crop insurance, and Maharashtra drip irrigation subsidy.',
        cards: const ['Keep Aadhaar, land record, bank passbook ready', 'Check state agriculture portal before application'],
      );
    }
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: false,
      createdAt: DateTime.now(),
      text: 'I could not reach the live AI service, so here is offline guidance: focus on irrigation timing, disease prevention, and selling around the stronger price window this week.',
      cards: const ['Harvest window: Mar 22-23', 'Nashik APMC tomato price: Rs 24/kg', 'Farm health score: 82/100'],
    );
  }

  List<String> _cardsFor(String prompt, List<Farm> farms) {
    final crop = farms.isEmpty ? 'your crop' : farms.first.currentCrop;
    final lower = prompt.toLowerCase();
    if (lower.contains('fertilizer') || lower.contains('nitrogen')) {
      return ['Crop: $crop', 'Check soil report before final dose', 'Avoid application before heavy rain'];
    }
    if (lower.contains('scheme') || lower.contains('yojana') || lower.contains('subsidy')) {
      return const ['PM-KISAN', 'PMFBY crop insurance', 'State irrigation subsidy'];
    }
    if (lower.contains('disease') || lower.contains('leaf') || lower.contains('leaves')) {
      return const ['Check symptoms', 'Scan crop photo', 'Confirm treatment dosage locally'];
    }
    return ['Crop: $crop', 'Uses your farm digital twin', 'Live Groq AI response'];
  }
}

class VisionService {
  const VisionService();

  Future<DiseaseReport> scanMock() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return const DiseaseReport(
      disease: 'Early Blight',
      confidence: 0.92,
      severity: 'Moderate',
      symptoms: ['Brown concentric spots on older leaves', 'Yellowing around lesions', 'Lower leaves drying early'],
      cause: 'Fungal infection encouraged by humidity and leaf wetness.',
      actions: ['Remove infected leaves', 'Avoid overhead irrigation', 'Improve airflow between plants'],
      treatment: 'Apply a recommended copper-based fungicide or mancozeb as per local agronomist dosage.',
      prevention: 'Use crop rotation, mulch carefully, and avoid working in wet crop rows.',
    );
  }
}
