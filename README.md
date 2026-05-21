# LESCO Command Center (CIRO Core): An AI-agentic tactical control panel for localized power grid crisis management in Lahore.

## The Problem Statement

Extreme heatwaves in Lahore cause localized transformer failures, critical load imbalances, and chaotic consumer complaints across social media and toll lines. 

## The Agentic AI Solution (Your Star Feature!)

CIRO Core acts as an autonomous grid agent using a multi-agent architecture trace:
- **Observation**: Monitors live telemetry data, incoming complaints, and grid stress factors.
- **Inference**: Analyzes the data to detect anomalies, predict transformer failures, and correlate social media sentiment with actual grid events.
- **Decision**: Executes autonomous decisions to mitigate failures, reroute power, and dispatch field units efficiently.

We've custom-tailored a **Gemini 2.5 Flash** integration that parses live telemetry to assist engineers in real-time, concise Roman Urdu/English conversations, ensuring rapid response without language barriers.

## Technical Stack Architecture

- **Frontend Mobile Core**: Flutter & GetX state architecture.
- **Database Infrastructure**: Google Firebase Firestore.
- **AI Orchestration Layer**: Official `google_generative_ai` Flutter SDK.

## How to Set Up & Run

```bash
cd command_center
flutter pub get
flutter run
```
