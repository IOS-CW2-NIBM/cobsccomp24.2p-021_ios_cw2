# Supportives iOS App

> A production-quality mobile platform connecting users with nearby household service providers — built with SwiftUI + MVVM.

---

## Overview

**Supportives** lets customers browse and book trusted, verified professionals for home services (cleaning, gardening, repairs, painting, moving, pet care) and gives those professionals a provider-mode dashboard to manage their bookings and earnings.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI 5 |
| Architecture | MVVM + Repository |
| Persistence | CoreData + UserDefaults |
| Location | CoreLocation / MapKit |
| Calendar | EventKit |
| Notifications | UserNotifications (Local) |
| Backend | Simulated (MockDataService) |
| Min iOS | 17.0 |

---

## Folder Structure

```
IOS_CW2_Supportives/
├── App/
│   ├── AppState.swift              # Root ObservableObject (auth, user, mode, services)
│   └── IOS_CW2_SupportivesApp.swift
│
├── Models/
│   ├── User.swift                  # AuthState, VerificationState, User
│   ├── ServiceCategory.swift       # 6 categories with colors & icons
│   ├── Worker.swift                # Worker + distance computation
│   ├── Booking.swift               # BookingStatus, Booking
│   ├── Review.swift                # Review, WorkerReport
│   └── AppNotification.swift       # AppNotificationType, AppNotification
│
├── Services/
│   ├── AuthService.swift           # Simulated OTP (60s expiry, dev code: 123456)
│   ├── MockDataService.swift       # 15 workers, filtering, sorting, search
│   ├── LocationService.swift       # CLLocationManager wrapper
│   ├── NotificationService.swift   # UNUserNotificationCenter wrapper
│   ├── CalendarService.swift       # EventKit wrapper
│   └── BookingService.swift        # In-memory + UserDefaults CRUD
│
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── HomeViewModel.swift
│   ├── SearchViewModel.swift       # Combine debounce pipeline
│   ├── WorkerProfileViewModel.swift
│   ├── BookingViewModel.swift      # Multi-step flow
│   ├── MapViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── VerificationViewModel.swift # (inside ProfileViewModel.swift)
│   ├── NotificationsViewModel.swift# (inside ProfileViewModel.swift)
│   └── ProviderDashboardViewModel.swift
│
├── Components/                     # 10 reusable UI components
│   ├── PrimaryButton.swift         # filled / outlined / ghost + loading
│   ├── OTPInputField.swift         # custom digit boxes + blinking cursor
│   ├── StarRatingView.swift        # display + interactive
│   ├── VerifiedBadge.swift         # small / medium / large / pill
│   ├── CategoryCard.swift          # card + horizontal CategoryStrip
│   ├── WorkerAvatarView.swift      # gradient initials + availability dot
│   ├── SafetyNoticeCard.swift      # safety disclaimer + report trigger
│   ├── BookingStatusBadge.swift    # colour-coded status pill
│   ├── EmptyStateView.swift        # icon + message + optional CTA
│   └── LoadingOverlay.swift        # full-screen blur + ShimmerBox skeleton
│
├── Views/
│   ├── Auth/           SplashView, OnboardingView, PhoneEntryView, OTPVerificationView
│   ├── Home/           HomeView (hero, category strip, featured, nearby)
│   ├── Search/         SearchView (reactive), WorkerCardView
│   ├── Worker/         WorkerProfileView, ReportWorkerView
│   ├── Booking/        BookingFormView (3-step), BookingConfirmationView, MyBookingsView
│   ├── Map/            MapView (MapKit + custom pins)
│   ├── Profile/        ProfileView, EditProfileView, VerificationView
│   ├── Provider/       ProviderDashboardView
│   ├── Notifications/  NotificationsView
│   └── Root/           MainTabView, ContentView
│
└── Utilities/
    ├── Theme.swift       # Colors, fonts, spacing, radius, gradients
    ├── Constants.swift   # AppConstants, ReportReason, WorkerSortOption, UserMode
    └── Extensions.swift  # Date, Double, String, View, HapticFeedback
```

---

## Navigation Flow

```
SplashView (2s)
  └─► OnboardingView (first launch)
       └─► PhoneEntryView
            └─► OTPVerificationView  [dev OTP: 123456]
                 └─► MainTabView (TabView)
                      ├── [1] Home → Search / WorkerProfile → Booking
                      ├── [2] Search → WorkerProfile → Booking
                      ├── [3] Map → WorkerProfile sheet
                      ├── [4] My Bookings
                      └── [5] Profile → Edit / Verify / Provider Dashboard
```

---

## Key Features

| Feature | Implementation |
|---|---|
| OTP Login | `AuthService` — simulated 6-digit OTP, 60s expiry, dev shortcut `123456` |
| Service Categories | 6 categories (Cleaning, Gardening, Repairs, Painting, Moving, Pet Care) |
| Worker Profiles | Rating, reviews, verified badge, categories, bio, distance |
| Booking System | 3-step form → datetime picker → pricing review → confirmation |
| Map View | MapKit with custom animated pins, category filter, locate-me |
| Calendar Integration | EventKit — saves booking as EKEvent with 1h alarm |
| Local Notifications | Booking confirmed, 1hr reminder, status change, report receipt |
| Provider Mode | Toggle in Profile → Dashboard with accept/decline/complete |
| Identity Verification | NIC + selfie via PhotosPicker, simulated 2s processing |
| Verified Badge | Emerald checkmark on worker cards and profiles |
| Safety & Report | Safety card on every profile + report sheet with reason picker |

---

## State Management

- **`AppState`** (`@EnvironmentObject`) — auth, current user, mode, service singletons
- **Per-screen ViewModels** (`@StateObject`) — receive injected services via initializer DI
- **Reactive search** — `Combine` `CombineLatest4` + `debounce` in `SearchViewModel`
- **Booking persistence** — `BookingService` writes to `UserDefaults` as JSON

---

## Development Notes

- Map is centred on **Colombo, Sri Lanka** (6.9271°N, 79.8612°E)
- All 15 mock workers have realistic Sri Lankan names and bios
- Use OTP `123456` in development to skip the real OTP
- Firebase is **not** a hard dependency — auth is fully simulated
- CoreData schema still has the default `Item` entity (untouched)

---

## Author

**COBSCCOMP24.2P-021** — IOS CW2, NIBM
