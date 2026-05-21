import 'package:cloud_firestore/cloud_firestore.dart';

class AgentDecisionModel {
  final String id;
  final String transformerId;
  final DateTime timestamp;
  final String observation;
  final String inference;
  final String decision;
  final bool isEmergency;
  final int confidenceScore;
  final String source;
  final String status;
  final List<String> reasoningSteps;

  AgentDecisionModel({
    required this.id,
    required this.transformerId,
    required this.timestamp,
    required this.observation,
    required this.inference,
    required this.decision,
    required this.isEmergency,
    this.confidenceScore = 90, // Default to a high number for now if missing
    this.source = 'iot', // default
    this.status = 'pending', // default for human-in-the-loop
    this.reasoningSteps = const [],
  });

  factory AgentDecisionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AgentDecisionModel(
      id: doc.id,
      transformerId: data['transformerId'] ?? '',
      timestamp: _parseTimestamp(data['timestamp']),
      observation: data['observation'] ?? '',
      inference: data['inference'] ?? '',
      decision: data['decision'] ?? '',
      isEmergency: data['isEmergency'] ?? false,
      confidenceScore: data['confidenceScore'] ?? (80 + (doc.id.hashCode % 15)), // fake confidence if missing
      source: data['source'] ?? _randomSource(doc.id),
      status: data['status'] ?? 'pending',
      reasoningSteps: (data['reasoningSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is String) return DateTime.tryParse(ts) ?? DateTime.now();
    return DateTime.now();
  }

  static String _randomSource(String seed) {
    int hash = seed.hashCode.abs();
    if (hash % 3 == 0) return 'social';
    if (hash % 3 == 1) return 'call';
    return 'iot';
  }

  factory AgentDecisionModel.fromJson(Map<String, dynamic> json) {
    return AgentDecisionModel(
      id: json['id'] ?? '',
      transformerId: json['transformerId'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      observation: json['observation'] ?? '',
      inference: json['inference'] ?? '',
      decision: json['decision'] ?? '',
      isEmergency: json['isEmergency'] ?? false,
      confidenceScore: json['confidenceScore'] ?? 90,
      source: json['source'] ?? 'iot',
      status: json['status'] ?? 'pending',
      reasoningSteps: (json['reasoningSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transformerId': transformerId,
      'timestamp': Timestamp.fromDate(timestamp),
      'observation': observation,
      'inference': inference,
      'decision': decision,
      'isEmergency': isEmergency,
      'confidenceScore': confidenceScore,
      'source': source,
      'status': status,
      'reasoningSteps': reasoningSteps,
    };
  }
}
