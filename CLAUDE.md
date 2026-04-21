# House of Tales — Flutter App

## Project Overview

Children's storybook reader app (ages 2-10) with illustrated, bilingual stories (English + Bahasa Indonesia). Built with Flutter, backed by a Go API.

- **PRD**: `PRD.md` — full product requirements, backend API contracts, screen inventory
- **Design System**: `house-of-tales-mobile.pen` — 52+ tokens, 27 components
- **Backend repo**: Separate Go repo (Gin / MySQL 8 / Redis / Clerk auth)

## Tech Stack

| Concern | Choice |
|---|---|
| State Management | Riverpod |
| Navigation | GoRouter |
| HTTP Client | Dio + Clerk token interceptor |
| Secure Storage | flutter_secure_storage |
| Fonts | google_fonts (Fraunces + Nunito) |
| Localization | flutter_localizations + intl (EN + ID) |
| IAP | in_app_purchase |

## Architecture

Follow **feature-first** structure with clean separation:

```
lib/
├── app/                     # App-level config (theme, router, providers)
├── core/                    # Shared utilities, constants, extensions
│   ├── api/                 # Dio client, interceptors, API exceptions
│   ├── theme/               # Design tokens, ThemeData, text styles
│   ├── l10n/                # Localization (ARB files)
│   └── utils/               # Helpers, formatters
├── features/
│   ├── auth/                # Login, Clerk integration
│   ├── onboarding/          # Child name, birthday, avatar, PIN setup
│   ├── home/                # Home tab
│   ├── explore/             # Explore tab
│   ├── library/             # Library tab (reading history)
│   ├── profile/             # Profile tab, settings
│   ├── story/               # Book detail, story reader, categories
│   ├── subscription/        # Plans, paywall, IAP
│   ├── talecoins/           # Store, gifting, rewards
│   └── search/              # Search screen
└── shared/                  # Shared widgets, models used across features
    ├── widgets/             # Reusable UI components (from design system)
    └── models/              # Shared data models
```

Each feature folder follows:
```
feature/
├── data/                    # Repository implementations, DTOs
├── domain/                  # Models, repository interfaces
├── presentation/            # Screens, widgets, controllers/providers
└── providers/               # Riverpod providers for this feature
```

## Design Tokens & Theme

Palette (from design system):
- Off-white background: `#FDFBF7`
- Mint green: `#A8E6CF`
- Sunny orange (brand CTA): `#FF8B3D`
- Dark teal: `#1A3C40`

Typography:
- Headings: **Fraunces** (serif)
- Body: **Nunito** (sans-serif)

All design tokens should be defined in `lib/core/theme/` and referenced via the app's `ThemeData`. Never hardcode colors or text styles in widgets.

## Coding Conventions

### Dart/Flutter

- Use `dart format` — no manual formatting
- Prefer `const` constructors wherever possible
- Use `final` for local variables that don't change
- Name files in `snake_case`, classes in `PascalCase`
- Suffix screens with `Screen` (e.g., `HomeScreen`), widgets with descriptive names
- Suffix providers with `Provider` or `NotifierProvider`
- Keep widget `build()` methods lean — extract sub-widgets as private methods or separate widgets when they exceed ~50 lines
- Use `sealed class` or `freezed` for state classes

### API Integration

- All API calls go through the Dio client in `lib/core/api/`
- Map API responses to domain models in the `data/` layer — never pass raw JSON to UI
- Handle errors at the repository level; surface typed exceptions to the UI
- Base URL and endpoints should be configurable (environment-based)

### State Management (Riverpod)

- Use `@riverpod` code generation (riverpod_generator)
- Prefer `AsyncNotifierProvider` for stateful async operations
- Prefer `FutureProvider` for simple one-shot data fetches
- Keep providers focused — one concern per provider
- Avoid `StateProvider` for complex state; use `Notifier` instead

### Navigation (GoRouter)

- Define all routes in `lib/app/router.dart`
- Use named routes with type-safe path parameters
- Guard routes with redirect logic (auth state, onboarding status, subscription)

### Localization

- All user-facing strings go in ARB files — never hardcode strings in widgets
- Support `en` (English) and `id` (Bahasa Indonesia)
- Access via `context.l10n.keyName`

## Key Business Rules

- **Subscription-first model**: no per-story purchases, no ad unlocks
- **3-day free trial**: no credit card required, full catalog access
- **Post-trial paywall**: pages 1-2 readable, page 3 shows top half with frosted glass CTA overlay, pages 4+ blocked
- **PIN required**: for subscribing, cancelling, buying Talecoins, gifting, changing settings
- **COPPA compliance**: minimal child PII, no third-party analytics on child-facing screens
- **Legacy access**: honor existing per-story purchases and active ad unlocks from pre-subscription era

## Testing

- Write widget tests for screens with business logic
- Write unit tests for providers/notifiers and repository logic
- Use `mocktail` for mocking
- Run tests: `flutter test`
- Run with coverage: `flutter test --coverage`

## Commands

```bash
# Run the app
flutter run

# Build
flutter build apk          # Android
flutter build ios           # iOS

# Code generation (freezed, riverpod_generator, etc.)
dart run build_runner build --delete-conflicting-outputs

# Analyze
dart analyze

# Format
dart format .

# Tests
flutter test
```

## Git Conventions

- Branch naming: `feature/<name>`, `fix/<name>`, `chore/<name>`
- Commit messages: imperative mood, lowercase, concise (e.g., "add story reader paywall overlay")
- Keep commits atomic — one logical change per commit
