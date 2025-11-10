# Notely - Note Taking App

A feature-rich Flutter note-taking application with rich text editing, categorization, and local storage capabilities.

## Features

- 📝 Rich text editing with Flutter Quill
- 🏷️ Organize notes with categories and tags
- 📌 Pin important notes
- 🔍 Search and filter functionality
- 📎 File attachments support
- 💾 Local storage with Isar database
- 🎨 Clean and intuitive Material Design 3 UI
- 🔐 Authentication 

## Screenshots



### Home Screen
<!-- ![Home Screen](screenshots/home_screen.png) -->
*Coming soon - Upload screenshot showing the home screen with categories and recent notes*

### Note Editor
<!-- ![Note Editor](screenshots/note_editor.png) -->
*Coming soon - Upload screenshot showing the rich text editor interface*

### Notes List
<!-- ![Notes List](screenshots/notes_list.png) -->
*Coming soon - Upload screenshot showing the notes list view*

### Search
<!-- ![Search Screen](screenshots/search_screen.png) -->
*Coming soon - Upload screenshot showing the search functionality*

## Demo Video





## Architecture

This project follows clean architecture principles with:

- **BLoC Pattern**: For state management (flutter_bloc)
- **Repository Pattern**: For data access abstraction
- **Service Layer**: For business logic
- **Model Layer**: With Isar for local persistence

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **Isar**: High-performance local database
- **Flutter Quill**: Rich text editor
- **BLoC**: State management
- **Firebase**: Authentication (ready for integration)
- **Material Design 3**: Modern UI components

## Project Structure

```
lib/
├── cubits/          # BLoC state management
├── models/          # Data models
├── repositories/    # Data access layer
├── services/        # Business logic
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/           # Helper functions
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/MOQ2/note_taking_app.git
cd note_taking_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Isar database files:
```bash
dart run build_runner build
```

4. Run the app:
```bash
flutter run
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```


