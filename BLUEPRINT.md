
# 🚀 Flutter Task Manager App — Assessment Blueprint

> **Goal:** This file is a complete, step-by-step build guide for an AI agent.
> Follow every section in order. Each section has clear inputs, outputs, and acceptance criteria.

---

## 📦 Project Setup

### Step 1 — Create Flutter Project

```bash
flutter create task_manager_app --org com.electrpi
cd task_manager_app
flutter pub get
```

### Step 2 — Add Dependencies to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # HTTP Client
  dio: ^5.4.3+1

  # Navigation
  go_router: ^13.2.4

  # Local Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0

  # UI Helpers
  flutter_spinkit: ^5.2.1
  cached_network_image: ^3.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  flutter_lints: ^3.0.0
```

---

## 🗂️ Folder Structure

Create this EXACT folder structure inside `lib/`:

```
lib/
├── main.dart
├── app.dart                          # App root widget + GoRouter setup
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart        # Base URL, endpoints
│   │   └── app_strings.dart          # All UI text strings
│   ├── errors/
│   │   └── app_exception.dart        # Custom exception classes
│   ├── network/
│   │   ├── dio_client.dart           # Dio singleton + interceptors
│   │   └── network_interceptor.dart  # Auth token injection
│   └── utils/
│       └── secure_storage.dart       # JWT read/write/delete helpers
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── auth_repository.dart  # Abstract interface
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   │           └── auth_text_field.dart
│   │
│   ├── projects/
│   │   ├── data/
│   │   │   ├── projects_remote_datasource.dart
│   │   │   └── projects_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── projects_repository.dart
│   │   │   └── models/
│   │   │       └── project_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── projects_provider.dart
│   │       ├── screens/
│   │       │   └── projects_screen.dart
│   │       └── widgets/
│   │           ├── project_card.dart
│   │           └── empty_state_widget.dart
│   │
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── tasks_remote_datasource.dart
│   │   │   └── tasks_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── tasks_repository.dart
│   │   │   └── models/
│   │   │       └── task_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── tasks_provider.dart
│   │       ├── screens/
│   │       │   └── project_details_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           └── add_task_bottom_sheet.dart
│   │
│   └── profile/
│       └── presentation/
│           └── screens/
│               └── profile_screen.dart
│
└── shared/
    └── widgets/
        ├── loading_widget.dart
        ├── error_widget.dart
        └── custom_button.dart
```

---

## 🔌 API Setup (Mock with JSONPlaceholder)

### `lib/core/constants/api_constants.dart`

```dart
// Use JSONPlaceholder as mock API
// Map their endpoints to our app:
//   /users        → auth (register/login simulation)
//   /todos        → tasks (title, completed)
//   /posts        → projects (title, body as description)

class ApiConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Auth (simulated — JSONPlaceholder has no real auth)
  static const String users = '/users';

  // Projects
  static const String posts = '/posts';

  // Tasks
  static const String todos = '/todos';
}
```

> ⚠️ **Important for AI agent:** JSONPlaceholder has NO real auth. Simulate login by:
> 1. `GET /users` → find user where email matches
> 2. If found → generate a fake JWT string and store it
> 3. Registration → `POST /users` (returns 201 but doesn't persist)

---

## 🔐 Feature 1: Authentication

### Files to create:

**`lib/core/utils/secure_storage.dart`**
- Use `flutter_secure_storage`
- Methods: `saveToken(String token)`, `getToken()`, `deleteToken()`

**`lib/core/network/network_interceptor.dart`**
- Dio interceptor that reads token from secure storage
- Adds `Authorization: Bearer <token>` header to every request
- On 401 response → clear token → redirect to login

**`lib/features/auth/domain/models/user_model.dart`**
```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  // constructor, fromJson, toJson
}
```

**`lib/features/auth/data/auth_remote_datasource.dart`**
- `login(String email, String password)` → GET /users, find match, return fake token
- `register(String name, String email, String password)` → POST /users

**`lib/features/auth/presentation/providers/auth_provider.dart`**
- Riverpod `AsyncNotifier` or `StateNotifier`
- States: `initial`, `loading`, `authenticated`, `error`
- Methods: `login()`, `register()`, `logout()`, `checkAuthStatus()`

**`lib/features/auth/presentation/screens/login_screen.dart`**
- Email `TextFormField` with email validation
- Password `TextFormField` with obscure text toggle
- Login button → calls provider → shows loading spinner → navigates to home on success
- "Don't have an account? Register" link
- Show error `SnackBar` on failure

**`lib/features/auth/presentation/screens/register_screen.dart`**
- Name, Email, Password fields
- Same pattern as login screen

### Acceptance Criteria ✅
- [ ] Token is saved in secure storage after login
- [ ] App starts directly on Home if token exists
- [ ] All fields validated before API call
- [ ] Loading indicator shown during API call
- [ ] Error message shown on failure

---

## 📋 Feature 2: Projects Screen (Home)

**`lib/features/projects/domain/models/project_model.dart`**
```dart
class ProjectModel {
  final int id;
  final String title;
  final String description; // use 'body' from /posts
  final String status;      // derive from id: odd='Active', even='Completed'
  // constructor, fromJson
}
```

**`lib/features/projects/data/projects_remote_datasource.dart`**
- `getProjects()` → GET /posts → map to `ProjectModel`

**`lib/features/projects/presentation/providers/projects_provider.dart`**
- Riverpod `AsyncNotifierProvider`
- `fetchProjects()` method
- `refresh()` method for pull-to-refresh

**`lib/features/projects/presentation/screens/projects_screen.dart`**
- `RefreshIndicator` wrapping a `ListView.builder`
- Each item → `ProjectCard` widget
- Show `LoadingWidget` while loading
- Show `EmptyStateWidget` if list is empty
- Show `ErrorWidget` on failure with retry button

**`lib/features/projects/presentation/widgets/project_card.dart`**
- Displays: title, description (max 2 lines), status badge
- Status badge: green for "Active", grey for "Completed"
- Tap → navigate to Project Details screen

**`lib/features/projects/presentation/widgets/empty_state_widget.dart`**
- Icon + "No projects found" text + optional refresh button

### Acceptance Criteria ✅
- [ ] Projects load from API on screen open
- [ ] Pull-to-refresh works
- [ ] Each card shows title, description, status
- [ ] Tapping a card navigates to details
- [ ] Empty state shown when list is empty
- [ ] Error state shown with retry option

---

## ✅ Feature 3: Project Details Screen

**`lib/features/tasks/domain/models/task_model.dart`**
```dart
class TaskModel {
  final int id;
  final String title;
  final bool completed;       // from /todos completed field
  final String status;        // derive: completed=Done, else=Pending
  final String priority;      // derive from id: %3==0=High, %3==1=Medium, else=Low
  // constructor, fromJson, copyWith
}
```

**`lib/features/tasks/data/tasks_remote_datasource.dart`**
- `getTasksByProject(int projectId)` → GET /todos?postId={projectId}
  > JSONPlaceholder doesn't support postId filter on todos. Use userId instead: `GET /todos?userId={projectId}` or just `GET /todos` and filter client-side by taking the first 5-10 items.
- `updateTask(int taskId, bool completed)` → PUT /todos/{id}
- `createTask(String title, int projectId)` → POST /todos

**`lib/features/tasks/presentation/providers/tasks_provider.dart`**
- `AsyncNotifierProvider` with projectId as argument
- Methods: `fetchTasks()`, `markAsDone(int taskId)`, `addTask(String title)`

**`lib/features/tasks/presentation/screens/project_details_screen.dart`**
- AppBar with project title
- `ListView` of `TaskCard` widgets
- Floating action button → opens `AddTaskBottomSheet`
- Loading / error / empty states

**`lib/features/tasks/presentation/widgets/task_card.dart`**
- Shows: title, status chip, priority badge
- Checkbox or button to mark as Done
- Priority colors: High=red, Medium=orange, Low=green

**`lib/features/tasks/presentation/widgets/add_task_bottom_sheet.dart`**
- `TextField` for task title
- Submit button → calls `addTask` → closes sheet → refreshes list

### Acceptance Criteria ✅
- [ ] Tasks load for the selected project
- [ ] Each task shows title, status, priority
- [ ] Marking a task as done updates the UI immediately
- [ ] New tasks can be added via bottom sheet
- [ ] Loading/error/empty states handled

---

## 👤 Feature 4: Profile Screen

**`lib/features/profile/presentation/screens/profile_screen.dart`**
- Display user name and email (read from secure storage or provider)
- Logout button → calls `auth_provider.logout()` → clear token → navigate to Login
- Use `GoRouter` redirect so token check happens automatically

### Acceptance Criteria ✅
- [ ] Name and email displayed correctly
- [ ] Logout clears token
- [ ] User is redirected to login after logout

---

## 🧭 Navigation Setup

**`lib/app.dart`**

Use `GoRouter` with these named routes:

| Route Name    | Path                      | Screen                    |
|---------------|---------------------------|---------------------------|
| `splash`      | `/`                       | Auto-redirect based on token |
| `login`       | `/login`                  | `LoginScreen`             |
| `register`    | `/register`               | `RegisterScreen`          |
| `home`        | `/home`                   | `ProjectsScreen`          |
| `details`     | `/home/project/:id`       | `ProjectDetailsScreen`    |
| `profile`     | `/profile`                | `ProfileScreen`           |

Add a `redirect` callback:
```dart
redirect: (context, state) async {
  final token = await SecureStorage.getToken();
  final isLoggedIn = token != null;
  final isOnAuth = state.matchedLocation.startsWith('/login') ||
                   state.matchedLocation.startsWith('/register');
  if (!isLoggedIn && !isOnAuth) return '/login';
  if (isLoggedIn && isOnAuth) return '/home';
  return null;
}
```

---

## 🎨 UI/UX Requirements

### Theme (`lib/main.dart` or `lib/app.dart`)
- Use `MaterialApp.router`
- Define a `ThemeData` with a primary color (e.g., deep blue `#1A237E`)
- **Bonus:** Add dark mode with `ThemeMode.system`

### Shared Widgets to build:

**`lib/shared/widgets/loading_widget.dart`**
```dart
// Centered CircularProgressIndicator or flutter_spinkit animation
```

**`lib/shared/widgets/custom_button.dart`**
```dart
// ElevatedButton wrapper with loading state
// Parameters: label, onPressed, isLoading
// When isLoading=true, show spinner instead of label
```

**`lib/shared/widgets/error_widget.dart`**
```dart
// Column with error icon, error message text, retry button
// Parameters: message, onRetry
```

---

## ⚠️ Error Handling Rules

Apply these rules EVERYWHERE API calls are made:

1. Wrap all datasource calls in `try/catch`
2. Catch `DioException` → throw custom `AppException` with user-friendly message
3. In providers, expose error state using `AsyncValue.error`
4. In screens, use `when(data:, loading:, error:)` pattern from Riverpod

```dart
// Standard Riverpod screen pattern
ref.watch(projectsProvider).when(
  data: (projects) => ProjectsList(projects),
  loading: () => const LoadingWidget(),
  error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.refresh(projectsProvider)),
);
```

---

## 📱 Responsive Layout Rules

- Use `LayoutBuilder` or `MediaQuery` for breakpoints
- All screens must be scrollable (no overflow on small screens)
- Use `SafeArea` on all screens
- `TextOverflow.ellipsis` on all text that might be long
- Test on: small phone (360×640), normal phone (390×844)

---

## 🌟 Bonus Features (Implement if time allows)

### Dark Mode
- Add `darkTheme` to `MaterialApp.router`
- Use `ThemeMode.system`
- All colors must use `Theme.of(context).colorScheme.*` — never hardcoded colors

### Offline Cache with Hive
- Add `hive_flutter` dependency
- Cache projects list locally
- Show cached data while loading fresh data (stale-while-revalidate)

### Animations
- Hero animation on project card → details screen (use project title or id as hero tag)
- Fade transition between routes in GoRouter

### Unit Tests (`test/` folder)
- `auth_provider_test.dart` — test login success/failure states
- `projects_provider_test.dart` — test fetch and refresh
- Use `mockito` or `mocktail` to mock repositories

---

## 📝 README.md Template

Create a `README.md` in the project root with this structure:

```markdown
# Task Manager App

A Flutter mobile application built as a technical assessment for Electro Pi.

## Screenshots
[Add screenshots here]

## Tech Stack
- Flutter (latest stable)
- Riverpod (state management)
- Dio (HTTP client)
- GoRouter (navigation)
- flutter_secure_storage (JWT storage)
- JSONPlaceholder (mock API)

## Architecture
Clean Architecture with feature-based folder structure:
- `data` layer: API calls, repository implementations
- `domain` layer: models, repository interfaces
- `presentation` layer: screens, widgets, providers

## How to Run
1. Clone the repo: `git clone <url>`
2. Install dependencies: `flutter pub get`
3. Run: `flutter run`

## API
Uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) as mock REST API.
Mapping:
- `/posts` → Projects
- `/todos` → Tasks
- `/users` → User data (login simulated client-side)

## Notes
- Login is simulated: any email from JSONPlaceholder /users works with any password
- Token is a fake JWT stored securely on device
- Task status and priority are derived from data fields for demo purposes
```

---

## 📤 Submission Checklist

Before submitting, verify:

- [ ] App runs on `flutter run` with zero errors
- [ ] All 4 screens work: Login, Home, Details, Profile
- [ ] Navigation between all screens works
- [ ] Pull-to-refresh works on Home
- [ ] Add task works from bottom sheet
- [ ] Mark task as done works
- [ ] Logout works and redirects to login
- [ ] Loading states shown on all screens
- [ ] Error states shown with retry option
- [ ] README.md is complete with screenshots
- [ ] Code pushed to public GitHub repo
- [ ] (Optional) APK or screen recording attached

---

## 🏗️ Build Order for AI Agent

Follow this exact order to avoid dependency issues:

```
1. Project setup + pubspec.yaml
2. core/constants/api_constants.dart
3. core/utils/secure_storage.dart
4. core/network/dio_client.dart + network_interceptor.dart
5. core/errors/app_exception.dart
6. shared/widgets/ (loading, error, button)
7. features/auth/ (model → datasource → repository → provider → screens)
8. app.dart (GoRouter — login + register routes only first)
9. features/projects/ (model → datasource → repository → provider → screen + widgets)
10. features/tasks/ (model → datasource → repository → provider → screen + widgets)
11. features/profile/ screen
12. app.dart update (add all remaining routes)
13. main.dart (ProviderScope + MaterialApp.router)
14. Test full flow end-to-end
15. README.md + screenshots
```
