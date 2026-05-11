# Flutter MVP Implementation Notes

Branch: `claire/flutter-mvp-scaffold`

Covers Trello child cards:
- HOT-M0 — baseline preserved at `b85c978f247414df34ed487268b68228e421df79`; existing docs/design assets kept.
- HOT-M1 — first buildable Flutter scaffold in this repo.
- HOT-M2 — Maya token-led Material 3 theme and core components.
- HOT-M4 — mock-auth and child onboarding flow behind environment boundaries.
- HOT-M5 — story shelf/catalog and story detail using normalized mock contracts.
- HOT-M6 — reader with bilingual toggle and preview/paywall behavior.
- HOT-M7 — profile/trust/subscription explainer draft with payment action disabled unless env-gated.
- HOT-M10 — analyze/test gates and widget smoke coverage.

## Environment modes

`AppEnvironment` supports `mock`, `localApi`, and `api` via Dart defines:

```bash
flutter run --dart-define=APP_ENV=mock
flutter run --dart-define=APP_ENV=localApi --dart-define=API_BASE_URL=http://localhost:8080/api/v1
flutter run --dart-define=APP_ENV=api --dart-define=API_BASE_URL=https://example.com/api/v1
```

Payments remain disabled by default and require `--dart-define=PAYMENTS_ENABLED=true`.

## Gates run

- `flutter pub get`
- `dart format .` — 0 changed on final run
- `flutter analyze` — no issues
- `flutter test` — 3 widget tests passed
