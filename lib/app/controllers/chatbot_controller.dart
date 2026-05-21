import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotController extends GetxController {
  late final GenerativeModel model;
  
  // ── Reactive State ──────────────────────────────────────────
  final RxList<Map<String, String>> messages = <Map<String, String>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // API key requested by the user
    final apiKey = "AIza.........";

    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are LESCO Alphabot, the tactical grid intelligence system for LESCO in Lahore. "
        "CRITICAL RULES: Keep your answers extremely short, concise, and professional. Do not exceed 1-3 sentences maximum. "
        "Never write long essays, bullet points, or explanations. "
        "When asked about a transformer or area status, check your knowledge of the 10 zones and reply immediately with a single direct status sentence. "
        "Maintain a natural, direct blend of English and polite Roman Urdu (e.g., 'Samanabad transformer is currently tripped due to overload. Emergency field team dispatched')."
      ),
    );

    // Initial message from the chatbot
    messages.add({
      'sender': 'LESCO_ Alphabot',
      'text': "LESCO Alphabot: Grid is stable. Monitoring operations. LESCO CIRO at your service. Aap ka kya masla hai?"
    });
  }

  /// Sends a user message to the Gemini agent and appends the response.
  Future<void> sendChatMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    messages.add({'sender': 'user', 'text': userMessage});
    isLoading.value = true;

    try {
      final response = await model.generateContent([Content.text(userMessage)]);
      messages.add({'sender': 'LESCO_ Alphabot', 'text': response.text ?? 'Error generating reply.'});
    } catch (e) {
      messages.add({
        'sender': 'LESCO_ Alphabot',
        'text': 'LESCO Alphabot: Communication link error. Please check your network connection.'
      });
    } finally {
      isLoading.value = false;
    }
  }
}
