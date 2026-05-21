import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../../controllers/incident_feed_controller.dart';
import '../../../../data/services/grid_simulator.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final IncidentFeedController incidentController = Get.find<IncidentFeedController>();
    final GridSimulatorService simulator = GridSimulatorService.to;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMMAND DASHBOARD',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),
              _buildHealthIndex(simulator),
              const SizedBox(height: 24),
              const Text(
                'ACTIVE CRITICAL GRIDS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // ── Live Simulator Critical Grid Cards ──────────────────
              Expanded(
                child: Obx(() {
                  final criticalGrids = simulator.grids
                      .where((g) => g.status == 'CRITICAL')
                      .toList();

                  if (criticalGrids.isEmpty) {
                    return const Center(
                      child: Text(
                        'ALL GRIDS STABLE',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: criticalGrids.length,
                    itemBuilder: (context, index) {
                      final grid = criticalGrids[index];
                      return _buildSimCriticalCard(grid, incidentController);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimCriticalCard(
      GridCrisisModel grid, IncidentFeedController incidentController) {
    return Card(
      color: AppColors.surfaceTransparent,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.critical.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${grid.gridId} — ${grid.locationName}',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.critical),
                  ),
                  child: const Text(
                    'CRITICAL',
                    style: TextStyle(
                        color: AppColors.critical,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _metricPill('Health', '${grid.systemHealth}%', AppColors.critical),
                const SizedBox(width: 8),
                _metricPill('Temp', '${grid.temperature}°C', AppColors.warning),
                const SizedBox(width: 8),
                _metricPill('Src', grid.sourcePlatform, AppColors.primary),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              grid.socialComplaint,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  incidentController.runAgenticPipeline(grid.gridId);
                },
                icon: const Icon(Icons.smart_toy, size: 14),
                label: const Text('RUN AI TRIAGE', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
          TextSpan(
              text: value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildHealthIndex(GridSimulatorService simulator) {
    return Obx(() {
      // Compute live average health from simulator grids
      final grids = simulator.grids;
      final avgHealth = grids.isEmpty
          ? 100
          : (grids.map((g) => g.systemHealth).reduce((a, b) => a + b) /
                  grids.length)
              .round();

      final criticalCount = simulator.criticalCount.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceTransparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              'GRID HEALTH',
              '$avgHealth%',
              avgHealth < 60
                  ? AppColors.critical
                  : avgHealth < 80
                      ? AppColors.warning
                      : AppColors.success,
            ),
            _buildStatCard('MONITORED', '${grids.length}', AppColors.primary),
            _buildStatCard(
              'CRITICAL NODES',
              '$criticalCount',
              criticalCount > 0 ? AppColors.critical : AppColors.success,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.2)),
      ],
    );
  }
}
