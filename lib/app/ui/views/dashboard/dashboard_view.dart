import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ai_chatbot_sheet.dart';
import 'tabs/home_view.dart';
import 'tabs/intelligence_feed_view.dart';
import 'tabs/map_view_tab.dart';
import 'tabs/dispatch_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if we should use a side navigation rail or bottom navigation bar based on screen width
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.industrialBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let gradient show through
        body: Row(
          children: [
            if (isWideScreen) _buildNavigationRail(),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    HomeView(),
                    IntelligenceFeedView(),
                    MapViewTab(),
                    DispatchView(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.bottomSheet(
              const AIChatbotSheet(),
              isScrollControlled: true,
              ignoreSafeArea: false,
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.smart_toy, color: AppColors.background),
        ),
        bottomNavigationBar: isWideScreen ? null : _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
      () => Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surface,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Intel Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Grid Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Dispatch',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Obx(
      () => NavigationRail(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        selectedIndex: controller.selectedIndex.value,
        onDestinationSelected: controller.changeTabIndex,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary),
        labelType: NavigationRailLabelType.all,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Intel Feed'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: Text('Grid Map'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: Text('Dispatch'),
          ),
        ],
      ),
    );
  }
}
