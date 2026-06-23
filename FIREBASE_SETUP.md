# Firebase Setup Checklist

Use this checklist to connect the `Anuka` MVP to Firebase with the identifiers already configured in the project.

## App identifiers

- Android application ID: `com.anuka.app`
- Android namespace: `com.anuka.app`
- iOS bundle ID: `com.anuka.app`
- App name: `Anuka`

## 1. Create the Firebase project

Create a Firebase project named `Anuka`.

## 2. Register the Android app

In Firebase Console:

1. Add app
2. Choose `Android`
3. Android package name: `com.anuka.app`
4. App nickname: `Anuka Android`
5. SHA-1:
   Add this when you are ready to test phone auth properly on Android

After registration:

- Download `google-services.json`
- Put it at `anuka/android/app/google-services.json`
- The Android project is already wired for the Google Services plugin

## 3. Register the iOS app

In Firebase Console:

1. Add app
2. Choose `iOS`
3. Apple bundle ID: `com.anuka.app`
4. App nickname: `Anuka iOS`

After registration:

- Download `GoogleService-Info.plist`
- Put it in `anuka/ios/Runner/GoogleService-Info.plist`
- The iOS project now includes a standard Flutter `Podfile`

## 4. Enable authentication

In Firebase Console -> Authentication -> Sign-in method:

- Enable `Email/Password`
- Enable `Phone`

For early testing:

- Add Firebase test phone numbers for OTP-based sign-in

## 5. Enable Firestore

In Firebase Console -> Firestore Database:

1. Create database
2. Start in production mode
3. Publish the rules from [firestore.rules](C:/Users/Aviral/OneDrive/Documents/New%20project/anuka/firestore.rules)

## 6. Replace FlutterFire options

Preferred:

```bash
flutterfire configure
```

If doing it manually, replace the placeholder values in [lib/firebase_options.dart](C:/Users/Aviral/OneDrive/Documents/New%20project/anuka/lib/firebase_options.dart):

- `YOUR_ANDROID_API_KEY`
- `YOUR_ANDROID_APP_ID`
- `YOUR_IOS_API_KEY`
- `YOUR_IOS_APP_ID`
- `YOUR_PROJECT_ID`
- `YOUR_SENDER_ID`
- `YOUR_STORAGE_BUCKET`

## 7. Android build setup

Install:

- Android Studio
- Android SDK
- A device or emulator
- On Windows, enable Developer Mode if Flutter asks for symlink support

If phone auth is not working on Android:

- confirm SHA-1 was added in Firebase
- confirm `google-services.json` matches `com.anuka.app`

## 8. Run the app

From the project folder:

```bash
C:\Users\Aviral\OneDrive\Documents\New project\flutter\bin\flutter.bat pub get
C:\Users\Aviral\OneDrive\Documents\New project\flutter\bin\flutter.bat run
```

## Pilot readiness check

Before inviting test users, confirm:

- user can sign in with email/password
- user can sign in with phone
- onboarding saves name in `users`
- posting creates docs in `needs`
- second user can tap `I Can Help`
- a claimed need cannot be claimed again
- creator or helper can mark the need completed
