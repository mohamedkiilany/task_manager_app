# 📋 Task Manager App

A Flutter mobile application built as a technical assessment, demonstrating Clean Architecture, state management with Riverpod, and RESTful API integration.

---

## 📸 Screenshots

> _Add screenshots here after running the app_

| Login | Projects | Task Details | Profile |
|-------|----------|--------------|---------|
| ![Login](screenshots/login.png) | ![Projects](screenshots/projects.png) | ![Details](screenshots/details.png) | ![Profile](screenshots/profile.png) |

---

## ✨ Features

- **Authentication** — Simulated login/register flow with secure JWT token storage
- **Projects Screen** — Browse all projects with pull-to-refresh support
- **Task Management** — View, add, and mark tasks as done per project
- **Profile Screen** — View user info and logout securely
- **Error Handling** — Graceful error states with retry on all screens
- **Loading States** — Consistent loading indicators throughout the app
- **Route Guarding** — Auto-redirect based on token existence via GoRouter

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (latest stable) |
| State Management | Riverpod 2.x (`AsyncNotifier`, `AsyncNotifierProvider`) |
| HTTP Client | Dio 5.x with interceptors |
| Navigation | GoRouter 13.x with redirect guards |
| Secure Storage | flutter_secure_storage (JWT token) |
| Mock API | JSONPlaceholder |

---

## 🏗️ Architecture

The app follows **Clean Architecture** with a **feature-based folder structure**:

```
lib/
├── core/               # Shared infrastructure
│   ├── constants/      # API endpoints, app strings
│   ├── errors/         # Custom exception classes
│   ├── network/        # Dio client + auth interceptor
│   └── utils/          # Secure storage helpers
│
├── features/
│   ├── auth/           # Login, Register
│   ├── projects/       # Projects list (Home)
│   ├── tasks/          # Project details + task CRUD
│   └── profile/        # User profile + logout
│
└── shared/
    └── widgets/        # LoadingWidget, ErrorWidget, CustomButton
```

Each feature is organized into three layers:

- **`data/`** — Remote data sources and repository implementations
- **`domain/`** — Abstract repository interfaces and data models
- **`presentation/`** — Screens, widgets, and Riverpod providers

---

## 🔌 API

Uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) as a mock REST API.

| Endpoint | Usage in App |
|----------|-------------|
| `GET /users` | Simulate login (match by email) |
| `POST /users` | Simulate registration |
| `GET /posts` | Fetch projects list |
| `GET /todos?userId={id}` | Fetch tasks for a project |
| `POST /todos` | Add a new task |
| `PUT /todos/{id}` | Update task completion status |

> **Note:** JSONPlaceholder has no real authentication. Login is simulated client-side: the app searches `/users` for a matching email, then generates and stores a fake JWT token locally.

---

## 📐 State Management Pattern

All providers follow the same Riverpod `AsyncNotifier` pattern:

```dart
// States handled: initial → loading → data / error
ref.watch(projectsProvider).when(
  data: (projects) => ProjectsList(projects),
  loading: () => const LoadingWidget(),
  error: (e, _) => AppErrorWidget(
    message: e.toString(),
    onRetry: () => ref.refresh(projectsProvider),
  ),
);
```

---

## 🧭 Navigation

Routes are defined in `lib/app.dart` using GoRouter:

| Route | Path | Screen |
|-------|------|--------|
| Splash / Redirect | `/` | Auto-redirect based on token |
| Login | `/login` | `LoginScreen` |
| Register | `/register` | `RegisterScreen` |
| Home | `/home` | `ProjectsScreen` |
| Project Details | `/home/project/:id` | `ProjectDetailsScreen` |
| Profile | `/profile` | `ProfileScreen` |

A `redirect` callback automatically sends unauthenticated users to `/login` and authenticated users away from auth screens.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- An Android emulator, iOS simulator, or physical device

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/task_manager_app.git
cd task_manager_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Login Credentials

Since JSONPlaceholder is used as a mock API, use any email from the `/users` endpoint with **any password**:

```
Email: Sincere@april.biz
Password: anypassword
```

> Full list of valid emails: https://jsonplaceholder.typicode.com/users

---

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.5.1      # State management
riverpod_annotation: ^2.3.5   # Code generation
dio: ^5.4.3+1                 # HTTP client
go_router: ^13.2.4            # Navigation
flutter_secure_storage: ^9.0.0 # Secure token storage
shared_preferences: ^2.2.3    # Local preferences
flutter_spinkit: ^5.2.1       # Loading animations
cached_network_image: ^3.3.1  # Image caching
```

---

## 📝 Notes

- Task **status** is derived from the `completed` field: `true` → Done, `false` → Pending
- Task **priority** is derived from `id % 3`: `0` → High, `1` → Medium, `2` → Low
- Project **status** is derived from `id`: odd → Active, even → Completed
- The auth token is a fake JWT generated client-side and stored securely on the device
- All API write operations (POST/PUT) are accepted by JSONPlaceholder but not actually persisted

---

## 🌟 Bonus Features

- [ ] Dark mode with `ThemeMode.system`
- [ ] Offline cache with Hive (stale-while-revalidate)
- [ ] Hero animations on project card navigation
- [ ] Fade route transitions via GoRouter
- [ ] Unit tests with `mocktail`