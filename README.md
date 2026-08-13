# DueDay

> A calm, iOS-first personal bill due-date and repayment reminder app built with Flutter.

[简体中文](README.zh-CN.md)

DueDay helps people stay ahead of recurring payments such as credit cards, loans, mortgages, insurance policies, and subscriptions. It is designed as a payment reminder assistant—not a traditional bookkeeping app.

The current release focuses on validating the iOS experience, information architecture, and core interactions with local mock data. Login, production APIs, persistence, and notifications are intentionally left as TODOs for the next phase.

## Current experience

- Opens directly into the app without a login flow.
- Home dashboard with the next payment, overdue treatment, monthly progress, and upcoming payments.
- Calendar view for browsing payment plans by due date.
- Bill list with all, pending, completed, and paused filters.
- Create and edit recurring bill plans.
- Support for credit cards, mortgages, loans, insurance, subscriptions, and other fixed payments.
- Configurable amount, billing cycle, due date, auto-debit flag, and reminder offsets.
- Mark a payment as completed or restore it to pending.
- Bill details with pause, resume, edit, and delete interactions.
- Monthly statistics, category distribution, and six-month projection.
- UI placeholders for local notifications, cloud sync, and data export.

## Product direction

DueDay is built around one question: **what payment needs my attention next?**

The product intentionally prioritizes:

- Actionable due-date awareness over transaction bookkeeping.
- A lightweight daily check-in over a complex finance dashboard.
- Clear overdue, pending, completed, and paused states.
- A local-first experience before cloud sync and account features.

## Tech stack

- Flutter / Dart
- iOS-first client
- Mock repository for the prototype
- Planned backend: Spring Boot based on a RuoYi `app-api` branch
- Planned database: MySQL
- Planned cache: Redis
- Planned job scheduler: XXL-JOB
- Planned notification channel: iOS local notifications first, WeChat subscription messages later

## Project structure

```text
lib/
├── core/              # Theme and formatting utilities
├── data/              # Repository abstractions, mock data, and API TODOs
├── domain/            # Bill plan model
├── features/          # App shell and product screens
├── shared/            # Reusable widgets
└── state/             # In-memory bill state

test/                  # Widget and state tests
tool/                  # Visual capture test and golden screenshots
ios/                   # Flutter iOS host project
```

## Run locally

```bash
flutter pub get
flutter test
flutter run -d <ios-simulator-id>
```

For iOS development, install Xcode and at least one iOS Simulator Runtime. CocoaPods is only required when native Flutter plugins are introduced.

## Data and API status

The prototype uses `MockBillRepository`. Data is held in memory and resets when the app restarts. No account data or bill data is uploaded.

The future RuoYi `app-api` integration boundary is documented in [`lib/data/remote_bill_repository.dart`](lib/data/remote_bill_repository.dart), including TODOs for:

- `GET /app-api/bill/plan/page`
- `POST /app-api/bill/plan/create`
- `PUT /app-api/bill/plan/update`
- `DELETE /app-api/bill/plan/delete`
- `PUT /app-api/bill/period/mark-paid`
- `PUT /app-api/bill/period/unmark-paid`
- `PUT /app-api/bill/plan/update-status`

The planned integration sequence is:

1. Connect RuoYi `app-api` login and token refresh.
2. Add bill-plan persistence and server-side user isolation.
3. Replace the mock repository with the remote repository.
4. Add local notification permissions and scheduling.
5. Add sync conflict handling and optional cloud backup.

## Roadmap

- [x] iOS-first UI prototype
- [x] Core bill-plan interactions with mock data
- [x] Calendar and statistics views
- [ ] RuoYi `app-api` authentication
- [ ] Remote bill-plan APIs
- [ ] Local persistence
- [ ] iOS local notifications
- [ ] Cloud sync and conflict handling
- [ ] Flutter Android and WeChat Mini Program clients

## Status

Early-stage personal-use prototype. The UI and interaction model are still evolving.

## License

License to be decided.
