import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/agent_decision_model.dart';
import '../data/services/grid_simulator.dart';

class IncidentFeedController extends GetxController {
  final RxList<AgentDecisionModel> incidents = <AgentDecisionModel>[].obs;

  List<AgentDecisionModel> get dispatchTickets {
    // Filter grids where status is CRITICAL and not yet dispatched
    final criticalGrids = GridSimulatorService.to.grids
        .where((g) => g.status == 'CRITICAL' && !g.dispatchAssigned);
    
    // Map them to AgentDecisionModel
    return criticalGrids.map((grid) {
      return AgentDecisionModel(
        id: grid.gridId,
        transformerId: "${grid.locationName} Repair [${grid.gridId}]",
        timestamp: DateTime.now(),
        observation: "Grid status: ${grid.status}. Health is ${grid.systemHealth}% and temperature is ${grid.temperature}°C.",
        inference: "Extreme load spike detected at ${grid.locationName} distribution line.",
        decision: "Deploy field technicians for circuit maintenance and cooling.",
        isEmergency: true,
        confidenceScore: 95,
        source: 'iot',
        status: 'pending',
      );
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _startLiveStream();
  }

  void _startLiveStream() {
    print('Starting incidents listener...');
    FirebaseFirestore.instance
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      print('Incident feed snapshot received: ${snapshot.docs.length} documents');
      incidents.value = snapshot.docs
          .map((doc) => AgentDecisionModel.fromFirestore(doc))
          .toList();
    }, onError: (error) {
      print('Error in incident feed stream: $error');
    });
  }

  void runAgenticPipeline(String incidentReport) {
    // 1. SENTINEL AGENT: Observes the signal
    String observation = "Detected load surge at $incidentReport";
    
    // 2. STRATEGIST AGENT: Plans based on observation
    List<String> reasoning = [
      "Analyzing weather impact: 42C degrees (Critical Heat).",
      "Checking grid capacity: Adjacent node TX-5 has 35% spare.",
      "Formulating plan: Trigger load shift to avoid transformer melt."
    ];
    
    // 3. EXECUTOR AGENT: Decides and acts
    String decision = "Initiating automated load redirection to TX-5.";

    // Push this to your UI
    incidents.insert(0, AgentDecisionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transformerId: incidentReport,
      timestamp: DateTime.now(),
      observation: observation,
      inference: "Grid overload imminent.",
      decision: decision,
      reasoningSteps: reasoning, // THIS IS YOUR AGENT TRACE
      isEmergency: true,
      confidenceScore: 94,
    ));
  }
}
