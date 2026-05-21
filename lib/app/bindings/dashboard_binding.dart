import 'package:get/get.dart';
import '../controllers/map_controller.dart';
import '../controllers/incident_feed_controller.dart';
import '../controllers/social_feed_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/chatbot_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<IncidentFeedController>(() => IncidentFeedController());
    Get.lazyPut<SocialFeedController>(() => SocialFeedController());
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}

