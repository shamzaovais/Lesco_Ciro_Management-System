// ============================================================
// grid_simulator.dart
// LESCO Crisis Command Center — Centralized Simulation Engine
// Drives all real-time panel updates across the entire app.
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────
// 1. DATA MODELS
// ─────────────────────────────────────────────────────────────

class GridCrisisModel {
  final String gridId;
  final String locationName;
  final double latitude;
  final double longitude;
  int systemHealth;       // 0–100
  int temperature;        // °C
  String socialComplaint; // Raw complaint log text
  String sourcePlatform;  // 'X', 'Facebook', 'Call-Centre', 'WhatsApp'
  String status;          // 'NORMAL' | 'WARNING' | 'CRITICAL'
  bool dispatchAssigned;

  GridCrisisModel({
    required this.gridId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.systemHealth,
    required this.temperature,
    required this.socialComplaint,
    required this.sourcePlatform,
    required this.status,
    required this.dispatchAssigned,
  });

  /// Returns a copy with updated mutable fields (for simulation ticks).
  GridCrisisModel copyWith({
    int? systemHealth,
    int? temperature,
    String? socialComplaint,
    String? sourcePlatform,
    String? status,
    bool? dispatchAssigned,
  }) {
    return GridCrisisModel(
      gridId: gridId,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      systemHealth: systemHealth ?? this.systemHealth,
      temperature: temperature ?? this.temperature,
      socialComplaint: socialComplaint ?? this.socialComplaint,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      status: status ?? this.status,
      dispatchAssigned: dispatchAssigned ?? this.dispatchAssigned,
    );
  }
}

class LescoTollTicket {
  final String ticketId;
  final String referenceNo;
  final String consumerName;
  final String subdivision;
  final String description;
  final String status;
  final DateTime timestamp;

  LescoTollTicket({
    required this.ticketId,
    required this.referenceNo,
    required this.consumerName,
    required this.subdivision,
    required this.description,
    required this.status,
    required this.timestamp,
  });
}

// ─────────────────────────────────────────────────────────────
// 2. HARDCODED LAHORE GRID PROFILES  (baseline / NORMAL state)
// ─────────────────────────────────────────────────────────────

/// Each neighbourhood carries a pool of 3 authentic complaint logs.
/// The simulator will rotate through them so the Intel Feed feels live.
const List<Map<String, dynamic>> _kComplaintPools = [
  // GRD-001  Johar Town Block G
  {
    'complaints': [
      "Johar Town Block G mein 2 ghante se bijli ghul gai hai, LESCO helpline par koi jawab nahi. #LoadShedding #Lahore",
      "Transformer on G-Block main road is humming dangerously loud since morning — smell of burning plastic. Please send a team immediately!",
      "بجلی کا بریکر تین مرتبہ ٹرپ کر چکا ہے، بچوں کا امتحان کل ہے اور UPS چارج نہیں — جوہر ٹاؤن G بلاک",
    ],
    'platforms': ['X', 'WhatsApp', 'Facebook'],
  },
  // GRD-002  DHA Phase 5
  {
    'complaints': [
      "DHA Phase 5 CC block — voltage fluctuation causing inverters to trip. Fridge compressor burned out. LESCO must compensate!",
      "DHA Phase 5 mein subah se load 3 baar aaya aur gaya — completely unacceptable for an elite zone. #DHALahore",
      "ڈی ایچ اے فیز 5 میں ٹرانسفارمر سے دھواں اٹھ رہا ہے — فوری ایکشن ضروری ہے",
    ],
    'platforms': ['Facebook', 'X', 'Call-Centre'],
  },
  // GRD-003  Gulberg III
  {
    'complaints': [
      "Gulberg III M-block commercial area — power out for 90 mins, restaurants losing lakhs. @LESCOofficial please respond!",
      "گلبرگ تھری میں وولٹیج اتنا کم ہے کہ AC چل ہی نہیں رہا — یہ 45 ڈگری گرمی میں ناقابلِ برداشت ہے",
      "Entire feeder from Liberty roundabout to MM Alam Road is dark. No ETA from LESCO. Gulberg III situation critical.",
    ],
    'platforms': ['X', 'WhatsApp', 'X'],
  },
  // GRD-004  Model Town
  {
    'complaints': [
      "Model Town Extension — power cut since 11 PM last night. My elderly parents need oxygen concentrator. This is a life-safety issue!",
      "ماڈل ٹاؤن E بلاک — ٹرانسفارمر کا آئل لیک ہو رہا ہے، بچے پاس کھیل رہے تھے، خدارا فوری ٹیم بھیجیں",
      "Model Town Main Boulevard lights flickering for 2 hours — major crash risk at night. Reporting to LESCO and traffic police.",
    ],
    'platforms': ['Call-Centre', 'WhatsApp', 'Facebook'],
  },
  // GRD-005  Samanabad
  {
    'complaints': [
      "سمن آباد میں پوری رات بجلی نہیں آئی — گرمی میں بچے بیمار ہو گئے، شکایت کا کوئی جواب نہیں #LESCO",
      "Samanabad Colony Block 3 — transformer tripped at 2AM, still not restored at 8AM. 6 hours without power in scorching heat!",
      "سمن آباد مرکز کے قریب ننگی تاریں ہیں — انتہائی خطرناک، حادثہ ہونے سے پہلے ٹیم بھیجیں",
    ],
    'platforms': ['Facebook', 'Call-Centre', 'WhatsApp'],
  },
  // GRD-006  Iqbal Town
  {
    'complaints': [
      "اقبال ٹاؤن R بلاک — بجلی کا میٹر جل گیا، معاوضے کے لیے LESCO آفس گئے تو دھکے دے کر نکالا",
      "Iqbal Town sector Q — distribution box on the street corner is sparking. Someone is going to get electrocuted. Emergency!",
      "Iqbal Town, load has been shed 4 times today — 2 hours each. Businesses cannot survive on generator fuel costs alone. #LESCOFail",
    ],
    'platforms': ['X', 'Call-Centre', 'Facebook'],
  },
  // GRD-007  Walled City (Androon Lahore)
  {
    'complaints': [
      "اندرونِ لاہور — دہائیوں پرانی تاریں جو ہر بارش میں چنگاریاں پھینکتی ہیں، LESCO کو کبھی فرق نہیں پڑا #WalledCity",
      "Walled City near Delhi Gate — entire mohalla without power, wedding ceremony ruined. Groom's family threatening police report against LESCO.",
      "لوہاری دروازہ — بجلی کا پول جھک گیا ہے، کسی بھی وقت گر سکتا ہے، بچوں کا راستہ ہے — ایمرجنسی",
    ],
    'platforms': ['WhatsApp', 'Facebook', 'Call-Centre'],
  },
  // GRD-008  Badami Bagh
  {
    'complaints': [
      "بادامی باغ صنعتی علاقہ — فیکٹری کی مشینیں وولٹیج ڈراپ سے جل گئیں، لاکھوں کا نقصان — LESCO ذمہ دار ہے",
      "Badami Bagh — transformer oil spill on main road near timber market. Fire hazard in a dense residential + commercial zone. Act NOW.",
      "Badami Bagh industrial feeder offline since morning shift. Hundreds of daily-wage workers sitting idle. @LESCOofficial respond!",
    ],
    'platforms': ['Call-Centre', 'WhatsApp', 'X'],
  },
  // GRD-009  Faisal Town
  {
    'complaints': [
      "Faisal Town F-block — voltage so low that water motor won't start. Family of 8 without water in this heat. Disgraceful!",
      "فیصل ٹاؤن اے بلاک — پچھلے ہفتے سے روزانہ 6 گھنٹے لوڈشیڈنگ، LESCO کا شیڈول بھی نہیں milta",
      "Faisal Town near Thokar Niaz Baig — underground cable fault causing random power cuts. Third time this month. Fix it properly!",
    ],
    'platforms': ['Facebook', 'X', 'Call-Centre'],
  },
  // GRD-010  Cavalry Ground
  {
    'complaints': [
      "Cavalry Ground main chowk — LESCO feeder pillar door is open, live wires exposed. Kids are playing nearby. Urgent safety hazard!",
      "کیولری گراونڈ — ٹرانسفارمر کی آواز اتنی تیز ہے کہ رات کو نیند نہیں آتی، کئی گھنٹوں سے بجلی بھی غائب ہے",
      "Cavalry Ground Cantt area — repeated power outages affecting hospital backup systems. This is beyond inconvenience — it's dangerous. #LESCOCrisis",
    ],
    'platforms': ['Call-Centre', 'WhatsApp', 'Facebook'],
  },
];

/// Builds the canonical baseline list of all 10 Lahore grid profiles.
List<GridCrisisModel> _buildBaselineGrids() {
  return [
    GridCrisisModel(
      gridId: 'GRD-001',
      locationName: 'Johar Town Block G',
      latitude: 31.4697,
      longitude: 74.2728,
      systemHealth: 82,
      temperature: 61,
      socialComplaint: _kComplaintPools[0]['complaints'][0],
      sourcePlatform: _kComplaintPools[0]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-002',
      locationName: 'DHA Phase 5',
      latitude: 31.4762,
      longitude: 74.3988,
      systemHealth: 79,
      temperature: 58,
      socialComplaint: _kComplaintPools[1]['complaints'][0],
      sourcePlatform: _kComplaintPools[1]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-003',
      locationName: 'Gulberg III',
      latitude: 31.5082,
      longitude: 74.3404,
      systemHealth: 86,
      temperature: 55,
      socialComplaint: _kComplaintPools[2]['complaints'][0],
      sourcePlatform: _kComplaintPools[2]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-004',
      locationName: 'Model Town',
      latitude: 31.4820,
      longitude: 74.3179,
      systemHealth: 88,
      temperature: 52,
      socialComplaint: _kComplaintPools[3]['complaints'][0],
      sourcePlatform: _kComplaintPools[3]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-005',
      locationName: 'Samanabad',
      latitude: 31.5301,
      longitude: 74.3126,
      systemHealth: 75,
      temperature: 63,
      socialComplaint: _kComplaintPools[4]['complaints'][0],
      sourcePlatform: _kComplaintPools[4]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-006',
      locationName: 'Iqbal Town',
      latitude: 31.4977,
      longitude: 74.3041,
      systemHealth: 81,
      temperature: 59,
      socialComplaint: _kComplaintPools[5]['complaints'][0],
      sourcePlatform: _kComplaintPools[5]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-007',
      locationName: 'Walled City (Androon Lahore)',
      latitude: 31.5822,
      longitude: 74.3126,
      systemHealth: 68,
      temperature: 67,
      socialComplaint: _kComplaintPools[6]['complaints'][0],
      sourcePlatform: _kComplaintPools[6]['platforms'][0],
      status: 'WARNING',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-008',
      locationName: 'Badami Bagh',
      latitude: 31.5751,
      longitude: 74.3284,
      systemHealth: 71,
      temperature: 64,
      socialComplaint: _kComplaintPools[7]['complaints'][0],
      sourcePlatform: _kComplaintPools[7]['platforms'][0],
      status: 'WARNING',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-009',
      locationName: 'Faisal Town',
      latitude: 31.4665,
      longitude: 74.2958,
      systemHealth: 84,
      temperature: 57,
      socialComplaint: _kComplaintPools[8]['complaints'][0],
      sourcePlatform: _kComplaintPools[8]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
    GridCrisisModel(
      gridId: 'GRD-010',
      locationName: 'Cavalry Ground',
      latitude: 31.5489,
      longitude: 74.3722,
      systemHealth: 78,
      temperature: 61,
      socialComplaint: _kComplaintPools[9]['complaints'][0],
      sourcePlatform: _kComplaintPools[9]['platforms'][0],
      status: 'NORMAL',
      dispatchAssigned: false,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────
// 3. TOLL CALL-CENTRE TICKET DATASET
// ─────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _kTicketDataset = [
  {
    'ticketId': 'LE-842910-09',
    'referenceNo': '14251627384950',
    'consumerName': 'Muhammad Bilal',
    'subdivision': 'Johar Town II',
    'description': 'Transformer oil leakage & low voltage fluctuation sparking heavily since sunset. Requesting team.',
    'status': 'ASSIGNED_TO_FIELD',
  },
  {
    'ticketId': 'LE-391827-02',
    'referenceNo': '12345678901234',
    'consumerName': 'Ayesha Khan',
    'subdivision': 'Gulberg III',
    'description': 'Oil leaking from transformer. Power has cut off multiple times in the last hour.',
    'status': 'PENDING',
  },
  {
    'ticketId': 'LE-582910-04',
    'referenceNo': '98765432109876',
    'consumerName': 'Kamran Shah',
    'subdivision': 'DHA Phase 5 CC',
    'description': 'Feeder main breaker tripped. Phase missing B causing low voltage.',
    'status': 'ASSIGNED_TO_FIELD',
  },
  {
    'ticketId': 'LE-281903-01',
    'referenceNo': '45678901234567',
    'consumerName': 'Zainab Bibi',
    'subdivision': 'Model Town Block E',
    'description': 'Severe voltage fluctuations since morning. AC compressor not turning on.',
    'status': 'PENDING',
  },
  {
    'ticketId': 'LE-482019-07',
    'referenceNo': '78901234567890',
    'consumerName': 'Tariq Mahmood',
    'subdivision': 'Samanabad Colony',
    'description': 'High tension wire hanging low over residential street. Immediate emergency response needed.',
    'status': 'ASSIGNED_TO_FIELD',
  },
];

// ─────────────────────────────────────────────────────────────
// 4. SIMULATION SERVICE  (GetxService — singleton, always alive)
// ─────────────────────────────────────────────────────────────

class GridSimulatorService extends GetxService {
  static GridSimulatorService get to => Get.find<GridSimulatorService>();

  // ── Reactive state ──────────────────────────────────────────
  final RxList<GridCrisisModel> grids = <GridCrisisModel>[].obs;
  final RxList<LescoTollTicket> tollTickets = <LescoTollTicket>[].obs;

  // Derived reactive values consumed by specific panels
  final RxInt criticalCount = 0.obs;

  // Intel Feed: chronological log of critical complaint entries
  final RxList<IntelEntry> intelFeed = <IntelEntry>[].obs;

  // ── Internals ───────────────────────────────────────────────
  Timer? _simulationTimer;
  Timer? _ticketTimer;
  final Random _rng = Random();

  // Tracks complaint rotation index per grid
  final Map<String, int> _complaintIndex = {};

  @override
  Future<void> onInit() async {
    super.onInit();
    grids.assignAll(_buildBaselineGrids());
    for (final g in grids) {
      _complaintIndex[g.gridId] = 0;
    }
    startGlobalSimulationLoop();
  }

  @override
  void onClose() {
    _simulationTimer?.cancel();
    _ticketTimer?.cancel();
    super.onClose();
  }

  // ── Public API ───────────────────────────────────────────────

  /// Starts (or restarts) the global simulation loops.
  void startGlobalSimulationLoop() {
    _simulationTimer?.cancel();
    _ticketTimer?.cancel();

    // 4-second loop: Grids and Social Insights
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _tick();
    });

    // 6-second loop: LESCO Toll Call-Centre Tickets
    _ticketTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _tickTicket();
    });
  }

  /// Stops all simulation loops.
  void stopLoop() {
    _simulationTimer?.cancel();
    _ticketTimer?.cancel();
  }

  /// Resolves the crisis for a specific grid by ID
  void resolveSimCrisis(String gridId) {
    final idx = grids.indexWhere((g) => g.gridId == gridId);
    if (idx != -1) {
      grids[idx] = grids[idx].copyWith(
        systemHealth: 85,
        temperature: 55,
        status: 'NORMAL',
        dispatchAssigned: true,
      );
      // Recompute criticalCount
      criticalCount.value = grids.where((g) => g.status == 'CRITICAL').length;
    }
  }

  // ── Private simulation logic ─────────────────────────────────

  void _tick() {
    // 1. First, heal any previously-critical grids back toward NORMAL
    for (int i = 0; i < grids.length; i++) {
      if (grids[i].status == 'CRITICAL') {
        final healed = grids[i].copyWith(
          systemHealth: 70 + _rng.nextInt(18),
          temperature: 55 + _rng.nextInt(12),
          status: 'WARNING',
          dispatchAssigned: false,
        );
        grids[i] = healed;
      }
    }

    // 2. Randomly spike 2–3 grids to CRITICAL this tick
    final int spikeCnt = 2 + _rng.nextInt(2); // 2 or 3
    final List<int> allIndices = List.generate(grids.length, (i) => i)..shuffle(_rng);
    final List<int> spikedIndices = allIndices.take(spikeCnt).toList();

    for (final idx in spikedIndices) {
      final grid = grids[idx];
      final poolIdx = grids.indexWhere((g) => g.gridId == grid.gridId);

      // Advance complaint rotation
      final currentComplaint = _complaintIndex[grid.gridId] ?? 0;
      final nextComplaint = (currentComplaint + 1) % 3;
      _complaintIndex[grid.gridId] = nextComplaint;

      final pool = _kComplaintPools[poolIdx];
      final complaint = pool['complaints'][nextComplaint] as String;
      final platform = pool['platforms'][nextComplaint] as String;

      final spiked = grid.copyWith(
        systemHealth: 20 + _rng.nextInt(36),   // 20–55
        temperature:  85 + _rng.nextInt(21),   // 85–105
        status: 'CRITICAL',
        socialComplaint: complaint,
        sourcePlatform: platform,
        dispatchAssigned: false,
      );
      grids[idx] = spiked;

      // Append to intel feed (newest first)
      intelFeed.insert(
        0,
        IntelEntry(
          gridId: grid.gridId,
          locationName: grid.locationName,
          complaint: complaint,
          platform: platform,
          timestamp: DateTime.now(),
          systemHealth: spiked.systemHealth,
          temperature: spiked.temperature,
        ),
      );

      // Keep feed from growing unbounded
      if (intelFeed.length > 50) {
        intelFeed.removeRange(50, intelFeed.length);
      }
    }

    // 3. Update derived critical count
    criticalCount.value = grids.where((g) => g.status == 'CRITICAL').length;
  }

  void _tickTicket() {
    // Select a random profile from the 5 hardcoded tickets
    final Map<String, dynamic> rawTicket = _kTicketDataset[_rng.nextInt(_kTicketDataset.length)];
    
    // Create ticket instance with current timestamp
    final ticket = LescoTollTicket(
      ticketId: rawTicket['ticketId']!,
      referenceNo: rawTicket['referenceNo']!,
      consumerName: rawTicket['consumerName']!,
      subdivision: rawTicket['subdivision']!,
      description: rawTicket['description']!,
      status: rawTicket['status']!,
      timestamp: DateTime.now(),
    );

    // Insert at top of list (newest first)
    tollTickets.insert(0, ticket);

    // Maintain max 30 items
    if (tollTickets.length > 30) {
      tollTickets.removeRange(30, tollTickets.length);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// 5. INTEL FEED ENTRY  (immutable value object for the feed list)
// ─────────────────────────────────────────────────────────────

class IntelEntry {
  final String gridId;
  final String locationName;
  final String complaint;
  final String platform;
  final DateTime timestamp;
  final int systemHealth;
  final int temperature;

  IntelEntry({
    required this.gridId,
    required this.locationName,
    required this.complaint,
    required this.platform,
    required this.timestamp,
    required this.systemHealth,
    required this.temperature,
  });
}
