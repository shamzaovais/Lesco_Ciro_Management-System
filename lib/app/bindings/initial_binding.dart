import 'package:get/get.dart';
import '../data/services/firebase_service.dart';
import '../data/services/grid_simulator.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // GridSimulatorService boots immediately and lives for the app lifetime.
    // permanent: true ensures GetX never disposes it between route changes.
    Get.put(GridSimulatorService(), permanent: true);
  }
}
