# Anuka

Anuka is a minimal Flutter + Firebase MVP for validating one behavior loop:

`Post a need -> Someone responds`

This project intentionally includes only:

- Authentication
- Name onboarding
- Post a need
- Feed of all needs
- `I Can Help` action
- Manual completion flow

It does **not** include maps, notifications, payments, AI, delivery, dashboards, or gamification.

## Project structure

```text
anuka/
  lib/
    models/
      app_user.dart
      need_item.dart
    screens/
      auth_screen.dart
      create_need_screen.dart
      feed_screen.dart
      onboarding_screen.dart
    services/
      auth_service.dart
      need_service.dart
      user_service.dart
    widgets/
      need_card.dart
    app.dart
    firebase_options.dart
    main.dart
  test/
  analysis_options.yaml
  pubspec.yaml
  README.md
```

## Firebase setup

### 1. Create a Firebase project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project named `Anuka` or any name you prefer.

### 2. Enable Authentication

In Firebase Console -> `Authentication` -> `Sign-in method`:

- Enable `Email/Password`
- Enable `Phone`

For phone auth:

- Add your app SHA keys for Android before production testing.
- During early testing, use Firebase test phone numbers if needed.

### 3. Create Firestore database

In Firebase Console -> `Firestore Database`:

- Create database
- Start in production or test mode depending on your pilot setup
- Create the `users` and `needs` collections automatically through the app

### 4. Add Android and iOS apps

Register:

- Android app with package name `com.anuka.app`
- iOS app with bundle ID `com.anuka.app`

There is a focused setup checklist in [FIREBASE_SETUP.md](C:/Users/Aviral/OneDrive/Documents/New%20project/anuka/FIREBASE_SETUP.md) with the exact identifiers and fields to use.

### 5. Add Firebase config to Flutter

You have two options.

#### Option A: Recommended with FlutterFire CLI

After Flutter is installed:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate the correct `lib/firebase_options.dart`. Replace the placeholder file in this project with the generated one.

#### Option B: Manual replacement

Open [lib/firebase_options.dart](C:/Users/Aviral/OneDrive/Documents/New%20project/anuka/lib/firebase_options.dart) and replace all placeholder values:

- `YOUR_ANDROID_API_KEY`
- `YOUR_ANDROID_APP_ID`
- `YOUR_IOS_API_KEY`
- `YOUR_IOS_APP_ID`
- `YOUR_PROJECT_ID`
- `YOUR_SENDER_ID`
- `YOUR_STORAGE_BUCKET`
- `YOUR_IOS_BUNDLE_ID`

### 6. Firestore security rules for MVP

This project now includes a tighter rules file at [firestore.rules](C:/Users/Aviral/OneDrive/Documents/New%20project/anuka/firestore.rules).

It allows only:

- users to read and update their own user profile
- authenticated users to read needs
- creators to create their own needs
- one non-creator helper to claim an open need
- only the creator or assigned helper to mark a helping need as completed

Publish these rules from the Firebase Console or Firebase CLI. The rules are:

```javascript
// See firestore.rules in the project root
```

## How to run

### 1. Install Flutter

Install Flutter from the [official docs](https://docs.flutter.dev/get-started/install).

### 2. Generate platform folders if needed

Because this workspace did not have Flutter installed while this project was created, generate the native folders locally after installing Flutter:

```bash
cd anuka
flutter create .
```

This keeps the existing `lib/` code and adds the missing `android/`, `ios/`, and platform files.

If Flutter is still not on your PATH, open a new terminal after installation and verify with:

```bash
flutter --version
```

### 3. Install packages

```bash
flutter pub get
```

If Windows asks for symlink support during dependency setup, enable Developer Mode:

```bash
start ms-settings:developers
```

Then turn on `Developer Mode` and rerun `flutter pub get`.

### 4. Add Firebase configuration

Do either:

- `flutterfire configure`
- Or replace the placeholder values in `lib/firebase_options.dart`

### 5. Run the app

```bash
flutter run
```

## MVP test flow

1. Sign up with email/password or phone.
2. Enter name once during onboarding.
3. Post a need with title, category, and location.
4. Open the app on another test account.
5. Tap `I Can Help`.
6. Mark the need as completed manually.

## Firestore collections

### `users`

```json
{
  "userId": "uid",
  "name": "Aviral",
  "createdAt": "timestamp"
}
```

### `needs`

```json
{
  "title": "Need groceries for tonight",
  "description": "Optional details",
  "category": "Food",
  "location": "Koramangala, Bengaluru",
  "createdBy": "uid",
  "helperId": "helperUid",
  "status": "open",
  "createdAt": "timestamp"
}
```

## Notes

- The app uses a simple stream-based architecture for readability.
- Needs are sorted latest first.
- Only one helper can claim a need.
- The creator or helper can manually mark a need as completed.
