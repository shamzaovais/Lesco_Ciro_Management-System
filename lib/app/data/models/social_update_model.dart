import 'package:cloud_firestore/cloud_firestore.dart';

class SocialUpdateModel {
  final String id;
  final String source; // 'X' or 'Meta'
  final String content;
  final String timestamp;
  final String sentiment; // 'Negative', 'Neutral', 'Critical'

  SocialUpdateModel({
    required this.id,
    required this.source,
    required this.content,
    required this.timestamp,
    required this.sentiment,
  });

  factory SocialUpdateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return SocialUpdateModel(
      id: doc.id,
      source: data?['source'] ?? 'Unknown',
      content: data?['content'] ?? '',
      timestamp: data?['timestamp'] ?? '',
      sentiment: data?['sentiment'] ?? 'Neutral',
    );
  }
}
