import '../../models/entities.dart';

abstract class AuthGateway {
  Future<String> signIn(String email, String password);
  Future<String> register(Farmer farmer, String password);
  Future<void> sendPasswordOtp(String emailOrMobile);
  Future<void> signOut();
}

abstract class FarmerStore {
  Future<Farmer> loadFarmer(String userId);
  Future<void> saveFarmer(Farmer farmer);
  Future<List<Farm>> loadFarms(String userId);
  Future<void> saveFarm(Farm farm);
  Future<void> deleteFarm(String farmId);
}

abstract class NotificationGateway {
  Future<void> registerDeviceToken(String userId);
  Future<List<AgroNotification>> loadNotifications(String userId);
  Future<void> markRead(String notificationId);
}

abstract class MediaStorageGateway {
  Future<String> uploadCropImage(String userId, Object imageFile);
}

abstract class AiGateway {
  Future<ChatMessage> askFarmingQuestion(String userId, String prompt);
  Future<DiseaseReport> analyseCropImage(String userId, String imageUrl);
}

class FirebaseCollectionNames {
  const FirebaseCollectionNames._();

  static const users = 'users';
  static const farms = 'farms';
  static const crops = 'crops';
  static const cropHistory = 'crop_history';
  static const soilReports = 'soil_reports';
  static const irrigationRecords = 'irrigation_records';
  static const yieldRecords = 'yield_records';
  static const aiConversations = 'ai_conversations';
  static const diseaseReports = 'disease_reports';
  static const cooperatives = 'cooperatives';
  static const cooperativeMembers = 'cooperative_members';
  static const transportJobs = 'transport_jobs';
  static const trucks = 'trucks';
  static const pickupSchedules = 'pickup_schedules';
  static const harvestPlans = 'harvest_plans';
  static const buyers = 'buyers';
  static const marketListings = 'market_listings';
  static const orders = 'orders';
  static const marketPrices = 'market_prices';
  static const transactions = 'transactions';
  static const notifications = 'notifications';
  static const governmentSchemes = 'government_schemes';
}
