# Architecture – 2 Truths & 1 Lie Networking Game

## Tech Stack
- **Frontend**: Flutter 3+ (Web, iOS, Android)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Hosting, Analytics)
- **QR**: qr_flutter + mobile_scanner

## Project Structure
```
lib/
├── main.dart                      # Entry point
├── app.dart                       # MaterialApp.router setup
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Color palette & gradients
│   │   └── app_theme.dart         # Dark & light Material 3 themes
│   ├── constants/
│   │   └── app_constants.dart     # Breakpoints, game rules, rank tiers
│   ├── extensions/
│   │   └── context_extensions.dart
│   ├── router/
│   │   └── app_router.dart        # GoRouter configuration
│   └── widgets/                   # Reusable UI components
│       ├── animated_button.dart
│       ├── animated_gradient_background.dart
│       ├── glassmorphism_card.dart
│       ├── loading_overlay.dart
│       ├── responsive_layout.dart
│       └── stat_card.dart
├── models/
│   ├── user_profile.dart
│   ├── scan_record.dart
│   ├── game_answer.dart
│   ├── achievement.dart
│   └── leaderboard_entry.dart
├── services/
│   ├── auth_service.dart          # Firebase Auth
│   ├── firestore_service.dart     # All Firestore CRUD
│   └── qr_service.dart            # QR encode/decode
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── game_provider.dart         # Game state machine
│   ├── leaderboard_provider.dart
│   ├── connections_provider.dart
│   └── theme_provider.dart
└── features/
    ├── splash/
    ├── onboarding/
    ├── profile/                   # Setup + QR view
    ├── scanner/                   # QR camera scanner
    ├── game/                      # Guessing game
    ├── connections/               # Contact list
    ├── leaderboard/               # Rankings (desktop)
    ├── dashboard/                 # Admin dashboard (desktop)
    └── home/                      # Mobile + Desktop shells
```

## Responsive Strategy
- **< 900px (Mobile)**: Full game experience with bottom nav (QR Profile, Scanner, Connections, Profile Edit)
- **>= 900px (Desktop)**: Dashboard with sidebar nav (Dashboard, Leaderboard, Participants)

## Game Flow
1. User creates profile with 2 truths + 1 lie
2. Profile generates a unique QR code
3. Another user scans the QR code
4. System checks: not self-scan, not duplicate scan
5. Scanned user's 3 statements are shuffled and displayed
6. Scanner selects which they think is the lie
7. Answer revealed: +1 for correct, -1 for wrong
8. Both users become mutual connections

## Scoring & Rank Tiers
| Rank | Score Range |
|------|-------------|
| Beginner | 0-10 |
| Detective | 11-25 |
| Investigator | 26-50 |
| Mastermind | 51+ |

## Anti-Cheat Measures
- Prevent self-scanning (QR contains userId, compared to current user)
- Prevent duplicate scans (Firestore query before allowing game)
- Score updates tied to answer submission (not standalone)
- Firestore security rules enforce ownership on writes
- Scan records are immutable (no updates/deletes)

## Deployment
```bash
# 1. Configure Firebase
flutterfire configure

# 2. Build for web
flutter build web --release --web-renderer html

# 3. Deploy
firebase deploy
```
