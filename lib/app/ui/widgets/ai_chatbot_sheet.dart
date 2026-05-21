import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chatbot_controller.dart';
import '../theme/app_colors.dart';

class AIChatbotSheet extends StatefulWidget {
  const AIChatbotSheet({super.key});

  @override
  State<AIChatbotSheet> createState() => _AIChatbotSheetState();
}

class _AIChatbotSheetState extends State<AIChatbotSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 1. Inject controller tracking instance using Get.find()
    final ChatbotController controller = Get.find<ChatbotController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.smart_toy, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'LESCO Alphabot',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Get.back(),
              )
            ],
          ),
          const Divider(color: AppColors.textSecondary),
          
          // 2. Wrap the chat conversation container inside an Obx observer
          Expanded(
            child: Obx(
              () => ListView.builder(
                // 3. Target controller.messages.length and support loading indicators
                itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3539), // Slate Grey look
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomLeft: const Radius.circular(0),
                          ),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "LESCO Alphabot is thinking...",
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = controller.messages[index];
                  final isUser = msg['sender'] == 'user';
                  final text = msg['text'] ?? '';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    // Align user to the right, LESCO Alphabot to the left
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        // User: deep cyan/teal background decoration accent
                        // LESCO Alphabot: slate grey custom background card look
                        color: isUser 
                            ? const Color(0xFF005F73).withValues(alpha: 0.4) // Deep cyan/teal
                            : const Color(0xFF2F4F4F).withValues(alpha: 0.3), // Slate grey / Dark slate grey
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                          bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                        ),
                        border: Border.all(
                          color: isUser 
                              ? const Color(0xFF0A9396) 
                              : const Color(0xFF708090).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Ask LESCO Alphabot...",
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onSubmitted: (_) {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      controller.sendChatMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.background),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      controller.sendChatMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
