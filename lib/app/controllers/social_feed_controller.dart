// social_feed_controller.dart
// Merges GridSimulatorService intel feed with Firestore social_updates
// so the Social Insights panel always shows live simulator complaints.
// Also exposes Toll Call-Centre tickets reactively from GridSimulatorService.

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/social_update_model.dart';
import '../data/services/grid_simulator.dart';

class SocialFeedController extends GetxController {
  final RxList<SocialUpdateModel> updates = <SocialUpdateModel>[].obs;
  final RxList<SocialUpdateModel> tollTickets = <SocialUpdateModel>[].obs;

  late final Worker _simWorker;
  late final Worker _ticketWorker;

  @override
  void onInit() {
    super.onInit();
    _startFirestoreStream();

    // React to every simulator intel feed change
    _simWorker = ever(GridSimulatorService.to.intelFeed, (_) => _mergeSimFeed());
    _mergeSimFeed(); // Populate immediately

    // React to Toll Call-Centre ticket updates
    _ticketWorker = ever(GridSimulatorService.to.tollTickets, (_) => _updateTollTickets());
    _updateTollTickets(); // Populate immediately
  }

  @override
  void onClose() {
    _simWorker.dispose();
    _ticketWorker.dispose();
    super.onClose();
  }

  // ── Firestore stream (keeps existing Firestore data flowing) ──
  void _startFirestoreStream() {
    print('Starting social_updates listener...');
    FirebaseFirestore.instance
        .collection('social_updates')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      print('Social feed snapshot received: ${snapshot.docs.length} documents');
      // Merge Firestore results then re-apply simulator on top
      final firestoreItems = snapshot.docs
          .map((doc) => SocialUpdateModel.fromFirestore(doc))
          .toList();
      _mergeAll(firestoreItems);
    }, onError: (error) {
      print('Error in social feed stream: $error');
    });
  }

  // ── Merge simulator intel feed entries into SocialUpdateModel list ──

  void _mergeSimFeed() => _mergeAll([]);

  void _mergeAll(List<SocialUpdateModel> firestoreItems) {
    final simEntries = GridSimulatorService.to.intelFeed
        .take(30)
        .map(
          (e) => SocialUpdateModel(
            id: '${e.gridId}_${e.timestamp.millisecondsSinceEpoch}',
            source: e.platform,
            content: '[${e.locationName}] ${e.complaint}',
            timestamp: e.timestamp.toIso8601String(),
            sentiment: 'Critical',
          ),
        )
        .toList();

    // Combine: simulator entries first (newest), then Firestore entries
    final combined = [...simEntries, ...firestoreItems];
    updates.assignAll(combined);
  }

  // ── Map Toll Call-Centre tickets to SocialUpdateModel ──
  void _updateTollTickets() {
    final simTickets = GridSimulatorService.to.tollTickets.map((t) => SocialUpdateModel(
      id: t.ticketId,
      source: 'Call-Centre',
      content: '[${t.ticketId} - ${t.consumerName}] | ${t.subdivision}\n${t.description}',
      timestamp: t.timestamp.toIso8601String(),
      sentiment: 'Critical',
    )).toList();
    
    tollTickets.assignAll(simTickets);
  }
}
