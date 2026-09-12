import 'package:flutter/foundation.dart';

import '../models/entities.dart';

class DemoRepository extends ChangeNotifier {
  DemoRepository() {
    _seed();
  }

  late Farmer farmer;
  final farms = <Farm>[];
  final cropHistory = <CropHistory>[];
  final yieldRecords = <YieldRecord>[];
  final chat = <ChatMessage>[];
  final listings = <MarketListing>[];
  final groups = <CooperativeGroup>[];
  final notifications = <AgroNotification>[];

  final marketPrices = const [
    MarketPrice('Tomato', 'Nashik APMC', 24, 8.4),
    MarketPrice('Tomato', 'Pune Market', 22.7, 3.1),
    MarketPrice('Tomato', 'Mumbai Market', 26.2, 5.7),
    MarketPrice('Onion', 'Nashik APMC', 18.4, -1.2),
  ];

  final buyers = const [
    Buyer(name: 'FreshKart Foods', crop: 'Tomato', quantityTonnes: 12, offerPerKg: 24, distanceKm: 22, verified: true, status: 'Available'),
    Buyer(name: 'Sahyadri Retail', crop: 'Tomato', quantityTonnes: 7.5, offerPerKg: 23.2, distanceKm: 34, verified: true, status: 'Negotiating'),
    Buyer(name: 'Green Basket Co.', crop: 'Onion', quantityTonnes: 9, offerPerKg: 19, distanceKm: 28, verified: false, status: 'Available'),
  ];

  final trucks = const [
    Truck(name: 'Tata 407', capacityTonnes: 2.5, price: 3500, status: 'Available'),
    Truck(name: 'Eicher Pro', capacityTonnes: 6, price: 6900, status: 'Partially Booked'),
    Truck(name: 'BharatBenz', capacityTonnes: 9, price: 9000, status: 'Available'),
  ];

  final schemes = const [
    Scheme(
      name: 'PM-KISAN',
      category: 'Central Government',
      eligibility: 'Small and marginal farmer families with cultivable land.',
      benefit: 'Income support of Rs 6,000 per year.',
      deadline: 'Open',
      documents: ['Aadhaar', 'Bank passbook', 'Land record'],
      website: 'https://pmkisan.gov.in',
    ),
    Scheme(
      name: 'PM Fasal Bima Yojana',
      category: 'Insurance',
      eligibility: 'Farmers growing notified crops in notified areas.',
      benefit: 'Crop insurance against weather, pest, and yield losses.',
      deadline: 'Seasonal',
      documents: ['Aadhaar', 'Bank details', 'Crop sowing certificate'],
      website: 'https://pmfby.gov.in',
    ),
    Scheme(
      name: 'Maharashtra Drip Irrigation Subsidy',
      category: 'Irrigation',
      eligibility: 'Eligible farmers installing approved drip irrigation systems.',
      benefit: 'Subsidy support for water-efficient irrigation.',
      deadline: 'Check state portal',
      documents: ['7/12 extract', 'Quotation', 'Bank details'],
      website: 'https://mahadbt.maharashtra.gov.in',
    ),
    Scheme(
      name: 'Kisan Credit Card',
      category: 'Loans',
      eligibility: 'Farmers needing short-term crop credit and working capital.',
      benefit: 'Flexible crop loan with interest subvention for eligible repayment.',
      deadline: 'Open through banks',
      documents: ['Aadhaar', 'Land record', 'Bank account', 'Crop details'],
      website: 'https://www.myscheme.gov.in',
    ),
    Scheme(
      name: 'Soil Health Card Scheme',
      category: 'Central Government',
      eligibility: 'Farmers requiring soil nutrient testing and recommendations.',
      benefit: 'Soil test report with crop-wise nutrient and fertilizer guidance.',
      deadline: 'Open',
      documents: ['Farmer ID', 'Land details', 'Soil sample'],
      website: 'https://soilhealth.dac.gov.in',
    ),
    Scheme(
      name: 'Farm Mechanization Subsidy',
      category: 'Equipment',
      eligibility: 'Farmers purchasing approved farm machinery and tools.',
      benefit: 'Subsidy assistance for equipment such as sprayers, seeders, and harvest tools.',
      deadline: 'State portal window',
      documents: ['Aadhaar', 'Quotation', 'Land record', 'Bank details'],
      website: 'https://mahadbt.maharashtra.gov.in',
    ),
  ];

  int get farmHealthScore {
    if (farms.isEmpty) return 0;
    final total = farms.fold<int>(0, (sum, farm) => sum + farm.soilHealth + farm.cropHealth);
    return (total / (farms.length * 2)).round();
  }

  double get revenue {
    if (yieldRecords.isEmpty) return 482000;
    return yieldRecords.fold(0.0, (sum, record) => sum + record.grossRevenue);
  }

  double get expenses {
    if (yieldRecords.isEmpty) return 291000;
    return yieldRecords.fold(0.0, (sum, record) => sum + record.totalExpenses);
  }

  double get profit => revenue - expenses;
  double get margin => revenue == 0 ? 0 : profit / revenue * 100;

  void login(String email, String password) {
    if (email.trim().isEmpty || password.length < 6) {
      throw ArgumentError('Enter a valid email and a password with at least 6 characters.');
    }
    notifyListeners();
  }

  void register(Farmer nextFarmer) {
    farmer = nextFarmer;
    notifyListeners();
  }

  void registerWithDigitalTwin({
    required Farmer nextFarmer,
    required Farm primaryFarm,
    required CropHistory firstCropHistory,
    required YieldRecord firstYieldRecord,
  }) {
    farmer = nextFarmer;
    farms
      ..clear()
      ..add(primaryFarm);
    cropHistory
      ..clear()
      ..add(firstCropHistory);
    yieldRecords
      ..clear()
      ..add(firstYieldRecord);
    chat.clear();
    listings.clear();
    notifications
      ..clear()
      ..addAll([
        AgroNotification(
          id: 'welcome_${DateTime.now().microsecondsSinceEpoch}',
          category: NotificationCategory.ai,
          title: 'Digital twin created',
          body: '${primaryFarm.name} is ready with crop, soil, irrigation, yield and analytics data.',
          createdAt: DateTime.now(),
          read: false,
        ),
      ]);
    notifyListeners();
  }

  void updateFarmer(Farmer nextFarmer) {
    farmer = nextFarmer;
    notifyListeners();
  }

  void addFarm(Farm farm) {
    farms.add(farm);
    notifyListeners();
  }

  void updateFarm(Farm farm) {
    final index = farms.indexWhere((item) => item.id == farm.id);
    if (index != -1) farms[index] = farm;
    notifyListeners();
  }

  void deleteFarm(String id) {
    farms.removeWhere((farm) => farm.id == id);
    notifyListeners();
  }

  void addChat(ChatMessage message) {
    chat.add(message);
    notifyListeners();
  }

  void createListing(MarketListing listing) {
    listings.add(listing);
    notifyListeners();
  }

  void joinGroup(String id) {
    final index = groups.indexWhere((item) => item.id == id);
    if (index != -1) groups[index] = groups[index].copyWith(joined: true);
    notifyListeners();
  }

  void addYield(YieldRecord record) {
    yieldRecords.add(record);
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1) notifications[index] = notifications[index].copyWith(read: true);
    notifyListeners();
  }

  List<Object> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return [
      ...farms.where((farm) => '${farm.name} ${farm.currentCrop} ${farm.village}'.toLowerCase().contains(q)),
      ...buyers.where((buyer) => '${buyer.name} ${buyer.crop}'.toLowerCase().contains(q)),
      ...schemes.where((scheme) => '${scheme.name} ${scheme.category}'.toLowerCase().contains(q)),
      ...marketPrices.where((price) => '${price.crop} ${price.market}'.toLowerCase().contains(q)),
      ...listings.where((listing) => '${listing.crop} ${listing.variety} ${listing.farm}'.toLowerCase().contains(q)),
      ...chat.where((message) => message.text.toLowerCase().contains(q)),
    ];
  }

  void _seed() {
    farmer = const Farmer(
      id: 'farmer_ramesh',
      fullName: 'Ramesh Patil',
      mobile: '+91 98765 43210',
      email: 'ramesh.patil@example.com',
      village: 'Nashik',
      district: 'Nashik',
      state: 'Maharashtra',
      language: 'Marathi',
      totalLand: 5.5,
      cooperativeStatus: 'Member',
    );
    farms.addAll([
      Farm(
        id: 'farm_green_valley',
        userId: farmer.id,
        name: 'Green Valley Farm',
        landSize: 3.4,
        unit: 'acre',
        village: 'Nashik',
        location: '20.0059, 73.7916',
        soilType: 'Black cotton soil',
        waterSource: 'Borewell',
        irrigationType: 'Drip',
        currentCrop: 'Tomato',
        plantingDate: DateTime(2026, 6, 12),
        expectedHarvest: DateTime(2026, 9, 24),
        soilHealth: 78,
        cropHealth: 86,
        predictedYieldTonnes: 26,
        status: FarmStatus.healthy,
      ),
      Farm(
        id: 'farm_sai',
        userId: farmer.id,
        name: 'Sai Farm',
        landSize: 2.1,
        unit: 'acre',
        village: 'Sinnar',
        location: '19.8453, 74.0000',
        soilType: 'Loamy soil',
        waterSource: 'Well',
        irrigationType: 'Sprinkler',
        currentCrop: 'Onion',
        plantingDate: DateTime(2026, 7, 5),
        expectedHarvest: DateTime(2026, 10, 20),
        soilHealth: 64,
        cropHealth: 72,
        predictedYieldTonnes: 19,
        status: FarmStatus.attention,
      ),
    ]);
    cropHistory.addAll(const [
      CropHistory(year: 2026, crop: 'Tomato', farm: 'Green Valley Farm', season: 'Kharif', area: 3.4, yieldTonnes: 26, revenue: 480000),
      CropHistory(year: 2025, crop: 'Onion', farm: 'Green Valley Farm', season: 'Rabi', area: 3.4, yieldTonnes: 19, revenue: 310000),
      CropHistory(year: 2024, crop: 'Grapes', farm: 'Sai Farm', season: 'Annual', area: 2.1, yieldTonnes: 14, revenue: 520000),
    ]);
    groups.addAll(const [
      CooperativeGroup(id: 'group_nashik_tomato', name: 'Nashik Tomato Group', farmers: 8, crop: 'Tomato', combinedTonnes: 12.4, harvestWindow: '22-25 March', destination: 'Nashik APMC', saving: 12800),
      CooperativeGroup(id: 'group_sinnar_onion', name: 'Sinnar Onion Cluster', farmers: 4, crop: 'Onion', combinedTonnes: 6.3, harvestWindow: '28-30 March', destination: 'Pune Market', saving: 5650),
    ]);
    notifications.addAll([
      AgroNotification(id: 'n1', category: NotificationCategory.weather, title: 'Rain alert', body: 'Heavy rainfall predicted tomorrow. Delay irrigation.', createdAt: DateTime.now(), read: false),
      AgroNotification(id: 'n2', category: NotificationCategory.market, title: 'Tomato price up', body: 'Tomato price increased 8.4% in Nashik APMC.', createdAt: DateTime.now(), read: false),
      AgroNotification(id: 'n3', category: NotificationCategory.transport, title: 'Pickup scheduled', body: 'Your cooperative truck is scheduled for 6:30 AM.', createdAt: DateTime.now(), read: true),
    ]);
  }
}
