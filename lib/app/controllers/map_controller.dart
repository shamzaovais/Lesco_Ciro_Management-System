// map_controller.dart
// Reads GridSimulatorService to paint live CRITICAL/WARNING/NORMAL markers.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transformer_model.dart';
import '../data/services/grid_simulator.dart';
import '../ui/theme/app_colors.dart';

class MapController extends GetxController {
  final RxSet<Marker> markers = <Marker>{}.obs;

  // Legacy transformers list — still consumed by DispatchView / HomeView
  // for Firestore-sourced data. The sim layer adds its own markers on top.
  final RxList<TransformerModel> transformers = <TransformerModel>[].obs;

  final initialCameraPosition = const CameraPosition(
    target: LatLng(31.5204, 74.3587),
    zoom: 11.5,
  );

  GoogleMapController? mapController;

  // Worker that reacts to simulator grid changes
  late final Worker _gridWorker;

  @override
  void onInit() {
    super.onInit();
    _startFirestoreStream();

    // React to every simulator tick and rebuild markers
    _gridWorker = ever(GridSimulatorService.to.grids, (_) => _rebuildSimMarkers());
    // Build initial set right away
    _rebuildSimMarkers();
  }

  @override
  void onClose() {
    _gridWorker.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ── Firestore stream (legacy) ─────────────────────────────────
  void _startFirestoreStream() {
    FirebaseFirestore.instance.collection('transformers').snapshots().listen((snapshot) {
      transformers.value = snapshot.docs.map((doc) => TransformerModel.fromFirestore(doc)).toList();
      _rebuildSimMarkers(); // Merge after Firestore update too
    });
  }

  // ── Marker builder driven by GridSimulatorService ─────────────
  void _rebuildSimMarkers() {
    final Set<Marker> newMarkers = {};

    // --- Simulator grid markers (primary layer) ---
    final grids = GridSimulatorService.to.grids;
    for (final grid in grids) {
      final isCritical = grid.status == 'CRITICAL';
      final isWarning  = grid.status == 'WARNING';

      final double markerHue = isCritical
          ? BitmapDescriptor.hueRed
          : isWarning
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueGreen;

      newMarkers.add(
        Marker(
          markerId: MarkerId(grid.gridId),
          position: LatLng(grid.latitude, grid.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          infoWindow: InfoWindow(
            title: '${grid.locationName} [${grid.gridId}]',
            snippet:
                'Health: ${grid.systemHealth}% | Temp: ${grid.temperature}°C | ${grid.status}',
          ),
          onTap: () => _onGridMarkerTapped(grid),
          // zIndexInt elevates critical markers so they render on top
          zIndexInt: isCritical ? 2 : isWarning ? 1 : 0,
        ),
      );
    }

    // --- Legacy Firestore transformer markers (secondary layer) ---
    for (final tx in transformers) {
      // Skip if a sim marker already occupies the same logical slot
      if (grids.any((g) => g.gridId == tx.id)) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId('tx_${tx.id}'),
          position: LatLng(tx.lat, tx.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            tx.isCritical ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: tx.name,
            snippet: 'Load: ${tx.loadPercentage.toStringAsFixed(1)}% | Status: ${tx.isCritical ? 'CRITICAL' : 'Normal'}',
          ),
          onTap: () => onMarkerTapped(tx),
        ),
      );
    }

    markers.assignAll(newMarkers);
  }

  // ── Tap handlers ──────────────────────────────────────────────

  void _onGridMarkerTapped(GridCrisisModel grid) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(grid.latitude, grid.longitude),
          zoom: 15.0,
        ),
      ),
    );

    final color = grid.status == 'CRITICAL' ? AppColors.critical : AppColors.warning;
    Get.snackbar(
      '${grid.status} — ${grid.locationName}',
      'Health: ${grid.systemHealth}% | Temp: ${grid.temperature}°C\n${grid.socialComplaint}',
      backgroundColor: color.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  void onMarkerTapped(TransformerModel tx) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(tx.lat, tx.lng), zoom: 15.0),
      ),
    );
  }

  // ── Crisis resolution (legacy Firestore path) ─────────────────
  void resolveCrisis(String transformerId) {
    final index = transformers.indexWhere((t) => t.id == transformerId);
    if (index != -1) {
      final tx = transformers[index];
      transformers[index] = TransformerModel(
        id: tx.id,
        name: tx.name,
        lat: tx.lat,
        lng: tx.lng,
        loadPercentage: 40.0,
        isCritical: false,
      );
      _rebuildSimMarkers();
      Get.snackbar(
        'Action Executed',
        'Load successfully redistributed from $transformerId',
        backgroundColor: AppColors.primary,
        colorText: Colors.black,
      );
    }
  }
}
