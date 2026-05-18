# Step Tracker

A modern, production-ready step tracker application built with Flutter. It features a beautiful user interface, real-time pedometer integration, and a clean, feature-based architecture.

## Features

- **Real-time Step Tracking**: Utilizes the device's hardware pedometer sensor for accurate, real-time step counting.
- **Beautiful UI & Animations**: Premium responsive design with fluid animations using `flutter_animate` and `Lottie`.
- **Data Visualization**: Interactive and visually appealing charts for step statistics using `fl_chart`.
- **Goal Management**: Set and track daily step goals with a visually engaging progress indicator.
- **Local Storage**: Fast and reliable local data persistence using `Hive`.
- **Notifications**: Local notifications to alert you when you achieve your daily goals using `flutter_local_notifications`.
- **Clean Architecture**: Built with a feature-first architecture for maintainability and scalability.

## Tech Stack

- **Framework**: Flutter (>=3.3.0)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage**: [Hive](https://docs.hivedb.dev/)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate), [lottie](https://pub.dev/packages/lottie)
- **Hardware Sensor**: [pedometer](https://pub.dev/packages/pedometer)

## Architecture Structure

The project follows a modular, feature-based architecture to keep the code organized and scalable:

```
lib/
├── core/            # Core configuration, themes, routing, and utilities
├── features/        # Feature modules
│   ├── dashboard/   # Main dashboard displaying today's progress
│   ├── goals/       # Goal setting and management
│   ├── profile/     # User profile
│   ├── settings/    # App settings and preferences
│   ├── statistics/  # Historical data and charts
│   └── steps/       # Step tracking logic and pedometer integration
├── shared/          # Reusable UI components, widgets, and helpers
└── main.dart        # Application entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK
- iOS: Xcode (for iOS deployment)
- Android: Android Studio (for Android deployment)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd step_tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (for Riverpod & Hive):**
   ```bash
   dart run build_runner build -d
   ```

### Running the App

To run the application on an attached device or emulator:
```bash
flutter run
```

## iOS Setup (Important)

For the pedometer and notifications to work correctly on iOS, ensure you have the following permissions in your `ios/Runner/Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app requires access to the pedometer to track your daily steps.</string>
```

## Android Setup (Important)

For Android 10 (API level 29) and above, ensure the following permission is declared in your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

## License

This project is licensed under the MIT License.
