# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Development
flutter run -d chrome                    # Run web app
flutter run -d chrome --web-port 5000    # Run on specific port

# Analysis & Tests
flutter analyze                          # Lint/static analysis
flutter test                             # Run all tests
flutter test test/widget_test.dart       # Run single test

# Build
flutter build web --release              # Production web build (renderer auto-selected)

# Firebase
firebase deploy --only hosting           # Deploy web app
firebase deploy --only firestore:rules   # Deploy security rules
firebase deploy --only firestore:indexes # Deploy indexes

# Dependencies
flutter pub get                          # Install packages
```

Note: `--web-renderer` flag was removed in Flutter 3.41+. The renderer is auto-selected. Do not use `window.flutterConfiguration` in index.html — it causes assertion errors.

## Architecture

**Networking Game** — a "2 Truths & 1 Lie" gamified networking app. Players create profiles with 2 truths + 1 lie, generate QR codes, scan others, and guess which statement is the lie. +1 point correct, -1 wrong.

### Responsive Split

The app behaves differently based on screen width (breakpoint: 900px):
- **Mobile (<900px)**: Full game — onboarding, profile setup, QR display, scanner, guessing game, connections list. Bottom nav with 4 tabs (QR, Scan, Contacts, Profile).
- **Desktop (>=900px)**: Dashboard console only — leaderboard, stats, charts, participant table. Sidebar nav with 3 tabs. No profile creation. Redirects mobile-only routes (`/onboarding`, `/profile-setup`, `/home`) to `/dashboard`.

This routing logic lives in `lib/core/router/app_router.dart` (GoRouter global redirect). The splash screen also checks screen width to decide the initial route.

### State Management — Riverpod

All state flows through providers in `lib/providers/`:
- `auth_provider.dart` — Firebase Auth state, `authStateProvider` (StreamProvider), `currentUserIdProvider`
- `user_provider.dart` — `currentUserProfileProvider` (StreamProvider from Firestore), `firestoreServiceProvider`
- `game_provider.dart` — `GameNotifier` (StateNotifier) handles the full scan→guess→score→connect flow. Has `debugPrint` logging for each Firestore operation to diagnose permission errors.
- `leaderboard_provider.dart` — streams, **depends on `isAuthenticatedProvider`** to avoid permission-denied errors before auth completes
- `connections_provider.dart` — filtered/sorted connections with search

Key pattern: **all Firestore stream providers gate on `isAuthenticatedProvider`** — they return empty data until auth is ready, then auto-fire. The `DesktopHomeScreen` also watches `authStateProvider` and shows a loading state until authenticated.

### Firebase

- **Auth**: Anonymous sign-in only. Pre-warmed in `main()` via `preWarmAuthFuture` global (a top-level `late final Future<User?>`) — splash screen awaits this instead of doing sequential auth.
- **Firestore collections**: `users`, `scans`, `answers`, `events`
- **Security rules** (`firestore.rules`): Users can only write their own profile. Scans/answers are immutable (no update/delete). All collections readable by any authenticated user. `addConnection` only updates the current user's doc (no reverse connection write — that would fail permission checks).
- **Project ID**: `networking-app-2ae68`

### Performance Decisions

- `GlassmorphismCard` skips `BackdropFilter` on web (`kIsWeb` check) — uses solid background with shadow instead. Supports `hoverable: true` for desktop hover effects (scale + glow).
- `AnimatedGradientBackground` uses static gradient by default, animated only with `animate: true`
- Theme objects are cached as `static final` (not recreated per build)
- Scanner screen is only built when its tab is active (conditional in `IndexedStack` — returns `SizedBox.shrink()` when not selected)
- Auth session restore timeout is 2 seconds
- Unused packages were removed to reduce bundle size (no lottie, flutter_animate, animated_text_kit, font_awesome_flutter, encrypt, firebase_analytics, cupertino_icons)
- MaterialIcons tree-shaken (1.6MB → 13KB)

### QR Encoding

QR data is simply `TTL_GAME:<userId>` (defined in `lib/services/qr_service.dart`). Short payload = larger QR modules = easier scanning. Error correction level H. Size scales responsively with screen width.

### Web Download

QR download uses conditional imports: `download_service.dart` → `download_service_web.dart` (dart:html blob) / `download_service_stub.dart` (no-op on native). The `dart:html` deprecation warning is expected and harmless.

### Responsive UI Pattern

All mobile screens check `context.isSmallScreen` (< 375px) from `lib/core/extensions/context_extensions.dart` and scale fonts, padding, and icon sizes accordingly. Use `context.responsivePadding` for consistent adaptive padding. All text has `maxLines` + `overflow: TextOverflow.ellipsis` where needed. `FittedBox` wraps titles that could overflow.

### Dashboard UI Pattern

Desktop dashboard components use:
- Shimmer skeleton loading states (not plain spinners)
- Staggered entrance animations on leaderboard tiles and activity feed items
- Hover effects on cards, sidebar items, table rows, and leaderboard entries
- Section headers with colored icon containers + borders
- `fl_chart` with tooltips and animated transitions

### Game Scoring

Defined in `lib/core/constants/app_constants.dart`:
- Correct guess: +1, Wrong: -1
- Rank tiers: Beginner (0-10), Detective (11-25), Investigator (26-50), Mastermind (51+)
- Anti-cheat: self-scan blocked, duplicate scans blocked (Firestore query), scan records immutable
- LinkedIn deep linking: tries `linkedin://in/<slug>` first, falls back to web URL

### Known Info Warnings (not errors)

`flutter analyze` will show 3 info-level warnings that are expected:
- `use_build_context_synchronously` in onboarding and scanner (async gaps with mounted checks)
- `deprecated_member_use` for `dart:html` in download_service_web.dart
