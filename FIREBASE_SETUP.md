# Firebase Setup Guide

## Prerequisites
- [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) installed (`dart pub global activate flutterfire_cli`)
- A Google account

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name it (e.g., `networking-game`)
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Enable Authentication
1. In Firebase Console → Authentication → Sign-in method
2. Enable **Anonymous** authentication

## Step 3: Create Firestore Database
1. Firebase Console → Firestore Database → Create database
2. Choose **Start in test mode** (we'll deploy proper rules next)
3. Select your preferred region

## Step 4: Configure Flutter App
```bash
# Login to Firebase
firebase login

# Configure FlutterFire (run from project root)
flutterfire configure --project=YOUR_PROJECT_ID
```

This generates `lib/firebase_options.dart`. Then update `lib/main.dart`:

```dart
import 'package:networking_game/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: NetworkingGameApp()));
}
```

## Step 5: Deploy Security Rules & Indexes
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## Step 6: Run the App
```bash
# Web (development)
flutter run -d chrome

# Web (production build)
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Firestore Schema

### `users` collection
| Field | Type | Description |
|-------|------|-------------|
| name | string | Display name |
| phone | string? | Phone number (optional) |
| email | string? | Email (optional) |
| linkedInUrl | string | LinkedIn profile URL |
| truth1 | string | First true statement |
| truth2 | string | Second true statement |
| lie | string | The lie statement |
| score | number | Current score |
| totalScans | number | Total QR scans made |
| correctGuesses | number | Correct guess count |
| wrongGuesses | number | Wrong guess count |
| connections | array | List of connected user IDs |
| createdAt | timestamp | Profile creation time |

### `scans` collection
| Field | Type | Description |
|-------|------|-------------|
| scannerId | string | User who scanned |
| scannedId | string | User who was scanned |
| timestamp | timestamp | When the scan happened |
| answered | boolean | Whether the game was played |
| correct | boolean? | Whether the guess was correct |

### `answers` collection
| Field | Type | Description |
|-------|------|-------------|
| guesserId | string | User who guessed |
| targetId | string | User whose profile was guessed |
| selectedStatement | string | The statement selected as the lie |
| isCorrect | boolean | Whether the guess was correct |
| timestamp | timestamp | When the answer was submitted |
| pointsAwarded | number | Points given (+1 or -1) |
