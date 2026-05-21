import 'package:cloud_firestore/cloud_firestore.dart';

class TransformerModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double loadPercentage;
  final bool isCritical;

  TransformerModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.loadPercentage,
    required this.isCritical,
  });

  factory TransformerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransformerModel(
      id: doc.id,
      name: data['name'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      loadPercentage: (data['loadPercentage'] ?? 0.0).toDouble(),
      isCritical: data['isCritical'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'loadPercentage': loadPercentage,
      'isCritical': isCritical,
    };
  }
}
