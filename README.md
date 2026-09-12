# AgroPredict AI

## 🎯 Project Name & SIH Problem Statement ID

**Project Name:** AgroPredict AI  
**SIH Problem Statement ID:** **TODO: Add official SIH Problem Statement ID**

AgroPredict AI is a Smart India Hackathon mobile solution focused on making agriculture decisions simpler, faster, and more data-driven for Indian farmers.

## 💡 The Solution (Brief 2-sentence value proposition)

AgroPredict AI brings farm intelligence, crop planning, market discovery, logistics, government schemes, and AI assistance into one farmer-friendly Android app. It helps farmers make better decisions from sowing to selling by combining localized insights, demo-ready AI workflows, and practical marketplace features.

## 🛠️ Tech Stack & Architecture

- **Frontend / Mobile:** Flutter, Dart, Material Design
- **Android Build:** Gradle, Android SDK, Kotlin Android entry point
- **State Management:** Flutter Riverpod
- **Navigation:** GoRouter
- **Backend-ready Services:** Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Messaging
- **Networking:** Dio
- **Maps & Location:** Google Maps Flutter, Geolocator
- **AI / Smart Features:** Demo AI recommendation service, mock crop disease vision flow, voice input with `speech_to_text`, text-to-speech with `flutter_tts`
- **Data Visualization:** FL Chart
- **Local Storage:** Shared Preferences
- **Architecture Pattern:** Feature-first Flutter structure with `core`, `models`, `repositories`, and `features` layers

```text
Presentation Screens
  -> Riverpod Providers
  -> Repository Layer
  -> Platform / Agro Services
  -> Demo Data, Firebase-ready integrations, REST-ready integrations
```

## 🚀 Key Features

- Farmer onboarding, authentication screens, and profile setup
- Home dashboard with farm health, weather, crop progress, insights, market prices, and tasks
- Digital farm management with farms, crop history, soil, irrigation, yield, and profit calculations
- AI assistant for agriculture queries and actionable farm recommendations
- Crop disease detection flow with image-based mock diagnosis
- Marketplace for produce listings, buyers, orders, and pricing insights
- Smart cooperative grouping for joint selling, cost sharing, and truck allocation
- Logistics planner with route optimization, pickup schedule, and delivery coordination
- Harvest planner using weather, market, and resource signals
- Analytics dashboard with market trends, P&L, risk indicators, demand heatmaps, buyer and finance summaries
- Government schemes, notifications, multilingual-ready app structure, and global search
- Demo mode with realistic Indian farmer data for SIH judging and offline walkthroughs

## 📦 Direct APK Download Link

**APK Download:** **TODO: Add GitHub Release URL here after uploading the final APK**

Temporary repository APK path after running the build script:

```text
apk/AgroPredict-AI-debug.apk
```

## ⚙️ Installation & Setup Instructions

1. Clone the repository:

```bash
git clone https://github.com/B-Acharekar/Agropedict-AI.git
cd Agropedict-AI
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Run static analysis and tests:

```bash
flutter analyze
flutter test
```

4. Run the app on an Android emulator or physical device:

```bash
flutter run
```

5. Build the debug APK:

```bash
cd android
./gradlew clean assembleDebug
cd ..
```

6. Copy the generated APK into the repository `apk/` folder:

```bash
mkdir -p apk
cp build/app/outputs/flutter-apk/app-debug.apk apk/AgroPredict-AI-debug.apk
```

7. Automated build, APK copy, commit, and push:

```bash
bash scripts/build_apk_and_push.sh
```

## 👥 Team Members & Roles

- **Rutuja Mohite** - Team Leader
- **Kimaya Waghere** - Team Member
- **Rakhi Jamdade** - Team Member
- **Pranjali Thosar** - Team Member
- **Bhushan Acharekar** - Team Member
- **Kalpesh Dandekar** - Team Member
