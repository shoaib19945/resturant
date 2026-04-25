# Restaurant Finder App

A Flutter application that lets users browse and search restaurants, view details, menus, working hours and nutrition info.

## Features

- **Restaurant Search** — Real-time search with debounced input to avoid excessive API calls
- **Infinite Scroll** — Lazy loading pagination as you scroll down the list
- **Restaurant Details** — Detailed view with cover image, info, working hours, and categorized menu
- **Hero Animations** — Smooth image transitions between listing and detail screens
- **Error Handling** — Custom error fallback UI with retry button
- **Responsive Layout** — Adapts to different screen sizes using LayoutBuilder and MediaQuery
- **Material 3** — Modern Material You theming with light/dark mode support
- **Pull to Refresh** — Swipe down on the list to reload data

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── api_client.dart          # HTTP client using dart:io HttpClient
│   ├── exception_handler.dart   # Custom exceptions and error messages
│   └── app_config.dart          # InheritedWidget for shared config
├── models/
│   ├── restaurant.dart          # Restaurant listing model
│   └── restaurant_detail.dart   # Detail model with menu items
├── screens/
│   ├── restaurant_list_screen.dart   # Search + listing page
│   └── restaurant_detail_screen.dart # Detail page
└── widgets/
    ├── restaurant_card.dart     # Card widget for list items
    └── error_fallback.dart      # Error state widget
```

## Technical Notes

- Uses `dart:convert` for JSON parsing (no json_serializable)
- Uses `HttpClient` from `dart:io` (no Dio or other HTTP packages)
- `InheritedWidget` for sharing API configuration across the widget tree
- `setState` for local state management
- `Timer` for search debouncing
- `Navigator.push` for screen routing
- Exception handling with `try/catch` and custom exception classes

## Environment Specs

- **Flutter SDK**: 3.29.3
- **Dart SDK**: 3.10.0
- **Gradle**: 8.12
- **Android Gradle Plugin**: 8.9.1
- **JDK**: 21
- **Min SDK**: 23
- **Target SDK**: 34
- **Build Variant**: release

## Getting Started

```bash
flutter pub get
flutter run
```

## Building Release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.
