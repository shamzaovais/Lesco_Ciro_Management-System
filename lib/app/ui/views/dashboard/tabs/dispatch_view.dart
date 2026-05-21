import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../../controllers/incident_feed_controller.dart';
import '../../../../controllers/map_controller.dart';
import '../../../../data/models/agent_decision_model.dart';
import '../../../../data/services/grid_simulator.dart';

class DispatchView extends StatelessWidget {
  const DispatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final IncidentFeedController incidentController = Get.find<IncidentFeedController>();
    final MapController mapController = Get.find<MapController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('DISPATCH CONSOLE', style: TextStyle(color: AppColors.primary, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        final tickets = incidentController.dispatchTickets;

        if (tickets.isEmpty) {
          return const Center(
            child: Text(
              "No AI-Generated Actions Pending",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final action = tickets[index];
            return _buildDispatchCard(action, mapController, incidentController);
          },
        );
      }),
    );
  }

  Widget _buildDispatchCard(
    AgentDecisionModel action,
    MapController mapController,
    IncidentFeedController incidentController,
  ) {
    return Card(
      color: AppColors.surfaceTransparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.critical.withValues(alpha: 0.5)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    action.transformerId,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: const Text(
                    'PENDING APPROVAL',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AI Recommended Action:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              action.decision,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              action.observation,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _handleDeny(action, incidentController);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.critical,
                      side: const BorderSide(color: AppColors.critical),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('DENY'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _handleApprove(action, mapController, incidentController);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'APPROVE & EXECUTE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleApprove(
    AgentDecisionModel action,
    MapController mapController,
    IncidentFeedController incidentController,
  ) {
    // Resolve in simulator (gridId is stored in action.id)
    GridSimulatorService.to.resolveSimCrisis(action.id);

    // Also resolve on the map
    mapController.resolveCrisis(action.id);

    Get.snackbar(
      'Action Executed',
      'Grid crisis stabilized successfully.',
      backgroundColor: AppColors.success,
      colorText: AppColors.background,
    );
  }

  void _handleDeny(
    AgentDecisionModel action,
    IncidentFeedController incidentController,
  ) {
    // Resolve in simulator to remove from list
    GridSimulatorService.to.resolveSimCrisis(action.id);

    Get.snackbar(
      'Action Denied',
      'AI recommendation rejected by Admin.',
      backgroundColor: AppColors.critical,
      colorText: AppColors.textPrimary,
    );
  }
}
