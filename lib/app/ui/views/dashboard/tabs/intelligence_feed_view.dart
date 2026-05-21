import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../../controllers/incident_feed_controller.dart';
import '../../../widgets/incident_card.dart';
import '../../../widgets/social_feed_panel.dart';

class IntelligenceFeedView extends StatelessWidget {
  const IntelligenceFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final IncidentFeedController controller = Get.find<IncidentFeedController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('INTELLIGENCE FEED', style: TextStyle(color: AppColors.primary, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          
          final incidentList = Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.incidents.length,
              itemBuilder: (context, index) {
                final incident = controller.incidents[index];
                return IncidentCard(incident: incident);
              },
            );
          });

          if (isWideScreen) {
            return Row(
              children: [
                Expanded(flex: 3, child: incidentList),
                const Expanded(flex: 2, child: SocialFeedPanel()),
              ],
            );
          } else {
            return Column(
              children: [
                const Expanded(flex: 2, child: SocialFeedPanel()),
                const Divider(height: 1, color: AppColors.surface),
                Expanded(flex: 3, child: incidentList),
              ],
            );
          }
        },
      ),
    );
  }
}
