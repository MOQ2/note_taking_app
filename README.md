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
<img width="761" height="1550" alt="image" src="https://github.com/user-attachments/assets/3044b88c-f288-44b5-910d-6e74e80ff6ff" />

### Note Editor
<img width="756" height="1576" alt="image" src="https://github.com/user-attachments/assets/cedc44f2-3a57-41fd-a517-bd7d2c999f55" />


### Notes List
<img width="773" height="1542" alt="image" src="https://github.com/user-attachments/assets/97e9930c-b32d-44ec-b08b-fa3089ecaaad" />
<img width="753" height="1543" alt="image" src="https://github.com/user-attachments/assets/02f4c4a3-aa74-4c46-b31f-ab1f169999d3" />


### Search
<img width="794" height="1560" alt="image" src="https://github.com/user-attachments/assets/a787eb0e-82e0-4c65-8fa5-a6e1163ec177" />
<img width="586" height="939" alt="image" src="https://github.com/user-attachments/assets/513010bb-fa89-4d8a-b703-09548e160f86" />

### Login
<img width="784" height="1536" alt="image" src="https://github.com/user-attachments/assets/8d186bae-8946-4665-856c-deb47db2dfd2" />

### sign up 
<img width="757" height="1532" alt="image" src="https://github.com/user-attachments/assets/d4796e86-a983-4075-9f94-9bcf9b9357dc" />

## Demo Video

https://github.com/user-attachments/assets/9c670fad-5fba-48e4-91fd-9aa6559c1c02






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


