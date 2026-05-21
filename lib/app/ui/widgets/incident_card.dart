import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/agent_decision_model.dart';
import '../theme/app_colors.dart';

class IncidentCard extends StatelessWidget {
  final AgentDecisionModel incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final borderColor = incident.isEmergency ? AppColors.critical : AppColors.secondary;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        leading: Icon(incident.isEmergency ? Icons.warning_amber_rounded : Icons.info_outline, color: borderColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(incident.transformerId, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Text(
                'AI Confidence: ${incident.confidenceScore}%',
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(DateFormat('HH:mm:ss').format(incident.timestamp)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('OBSERVATION', incident.observation),
                _buildSection('INFERENCE', incident.inference),
                const Divider(color: AppColors.textSecondary),
                const Text("AGENT REASONING TRACE:", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                // This loops through your reasoningSteps list
                ...incident.reasoningSteps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("• $step", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                )),
                const SizedBox(height: 10),
                if (incident.isEmergency)
                  ElevatedButton(
                    onPressed: () => Get.find<MapController>().resolveCrisis(incident.transformerId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                    child: const Text("EXECUTE DISPATCH"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
      Text(content, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 8),
    ],
  );
}
