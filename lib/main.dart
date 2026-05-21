import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/bindings/dashboard_binding.dart';
import 'app/ui/theme/dark_theme.dart';
import 'app/ui/views/dashboard/dashboard_view.dart';
import 'app/ui/views/splash_view.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/data/services/firebase_service.dart' as my_firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() => my_firebase.FirebaseService().init());
  runApp(const CommandCenterApp());
}

class CommandCenterApp extends StatelessWidget {
  const CommandCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LESCO Command Center',
      theme: darkTheme,
      initialBinding: InitialBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/dashboard',
          page: () => const DashboardView(),
          binding: DashboardBinding(),
        ),
        GetPage(
          name: '/splash',
          page: () => SplashView(),
          binding: InitialBinding(), // Splash doesn't need heavy binding
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}


