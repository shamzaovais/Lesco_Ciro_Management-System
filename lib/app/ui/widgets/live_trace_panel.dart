import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/incident_feed_controller.dart';
import '../theme/app_colors.dart';
import 'incident_card.dart';

class LiveTracePanel extends GetView<IncidentFeedController> {
  const LiveTracePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        border: const Border(
          left: BorderSide(color: AppColors.surface, width: 2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surface)),
            ),
            child: Row(
              children: [
                const Icon(Icons.memory, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'LIVE AGENT TRACE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 2.0,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.incidents.length,
                itemBuilder: (context, index) {
                  final incident = controller.incidents[index];
                  return IncidentCard(incident: incident);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
