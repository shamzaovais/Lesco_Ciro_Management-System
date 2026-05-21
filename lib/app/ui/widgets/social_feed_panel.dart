import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/social_feed_controller.dart';
import '../theme/app_colors.dart';

class SocialFeedPanel extends GetView<SocialFeedController> {
  const SocialFeedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        border: const Border(
          right: BorderSide(color: AppColors.surface, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Section 1: Social Insights
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surface)),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'SOCIAL INSIGHTS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 2.0,
                    color: Colors.blueAccent,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(
              () => ListView.builder(
                itemCount: controller.updates.length,
                itemBuilder: (context, index) {
                  final update = controller.updates[index];
                  final isNegative = update.sentiment == 'Negative' || update.sentiment == 'Critical';
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isNegative ? AppColors.critical.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              update.source == 'X' ? Icons.chat_bubble : Icons.facebook,
                              color: isNegative ? AppColors.critical : AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              update.source,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isNegative ? AppColors.critical : AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(update.timestamp),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          update.content,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.surface),

          // Section 2: LESCO Toll Call-Centre Tickets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surface)),
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.cyan),
                const SizedBox(width: 8),
                Text(
                  'TOLL CALL-CENTRE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 2.0,
                    color: Colors.cyan,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Obx(
              () => ListView.builder(
                itemCount: controller.tollTickets.length,
                itemBuilder: (context, index) {
                  final ticket = controller.tollTickets[index];
                  final parts = ticket.content.split('\n');
                  final header = parts.isNotEmpty ? parts[0] : '';
                  final description = parts.length > 1 ? parts.sublist(1).join('\n') : '';

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                header,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.cyan),
                              ),
                              child: const Text(
                                'TOLL CALL-CENTRE',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
