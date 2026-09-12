import 'package:agropredict_ai/core/services/agro_services.dart';
import 'package:agropredict_ai/models/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogisticsService', () {
    const service = LogisticsService();

    test('splits transportation cost by produce weight', () {
      final shares = service.splitTransportCost(
        totalCost: 9000,
        loads: const [FarmerLoad('Ramesh', 3000), FarmerLoad('Suresh', 2000), FarmerLoad('Mahesh', 4000)],
      );

      expect(shares.map((e) => e.cost).toList(), [3000.0, 2000.0, 4000.0]);
    });

    test('allocates available trucks until capacity is covered', () {
      final trucks = service.allocateTrucks(8.7, const [
        Truck(name: 'Tata 407', capacityTonnes: 2.5, price: 3500, status: 'Available'),
        Truck(name: 'Eicher Pro', capacityTonnes: 6, price: 6900, status: 'Booked'),
        Truck(name: 'BharatBenz', capacityTonnes: 9, price: 9000, status: 'Available'),
      ]);

      expect(trucks.single.name, 'BharatBenz');
    });

    test('route optimization starts with the first stop', () {
      final route = service.optimizeRoute(const [
        RouteStop('Depot', 0, 0),
        RouteStop('Far', 10, 10),
        RouteStop('Near', 1, 1),
      ]);

      expect(route.first.name, 'Depot');
      expect(route[1].name, 'Near');
    });
  });

  test('yield record calculates profit metrics', () {
    final record = const FinanceService().createYieldRecord(
      crop: 'Tomato',
      farm: 'Green Valley Farm',
      harvestDate: nullSafeDate,
      quantityKg: 3000,
      sellingPricePerKg: 24,
      buyer: 'FreshKart',
      transportationCost: 3000,
      labourCost: 8500,
      otherExpenses: 1200,
    );

    expect(record.grossRevenue, 72000);
    expect(record.totalExpenses, 12700);
    expect(record.netProfit, 59300);
    expect(record.profitMargin.toStringAsFixed(1), '82.4');
  });

  test('cooperative score rewards matching crop, market and harvest window', () {
    final score = const CooperativeService().compatibilityScore(
      crop: 'Tomato',
      otherCrop: 'Tomato',
      harvestDate: DateTime(2026, 3, 23),
      otherHarvestDate: DateTime(2026, 3, 24),
      distanceKm: 4,
      market: 'Nashik APMC',
      otherMarket: 'Nashik APMC',
    );

    expect(score, greaterThanOrEqualTo(90));
  });

  test('harvest recommendation avoids heavy rain when better dates exist', () {
    final rec = const HarvestService().recommend(
      weather: [
        WeatherDay(DateTime(2026, 3, 22), 'Clear', 'Best'),
        WeatherDay(DateTime(2026, 3, 24), 'Heavy Rain', 'Avoid'),
      ],
      prices: [
        MarketForecast(DateTime(2026, 3, 22), 23),
        MarketForecast(DateTime(2026, 3, 24), 24),
      ],
      labourAvailable: true,
      truckAvailable: true,
      buyerAvailable: true,
    );

    expect(rec.date, DateTime(2026, 3, 22));
  });
}

final nullSafeDate = DateTime(2026, 3, 23);
