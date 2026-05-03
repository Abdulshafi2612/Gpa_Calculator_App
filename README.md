# GPA Calculator — Flutter (Backend-Integrated)

A beautiful, modern Flutter application for calculating and tracking college GPAs. It acts as the frontend for the **GPA Calculator REST API** (built with Spring Boot) and replaces the legacy Firebase architecture with a secure, backend-driven system using JWT authentication and server-side calculation.

---

## ✨ Key Features

- **Robust Authentication:** Secure JWT-based registration, login, and automated session management with proactive token refresh.
- **Dynamic Dashboard:** Live tracking of your CGPA, total completed credits, and total semesters directly calculated by the backend.
- **Semester Management:** Seamlessly add, edit, and delete semesters with up to 10 subjects per term.
- **Semester Toggling (Active/Inactive):** Exclude specific semesters from your overall CGPA calculation with a single tap, while preserving their data.
- **Modern UI & Animations:** Fluid page transitions, staggered list animations, and a sleek glassmorphic aesthetic using the signature **BauhausStd** typography.
- **Form Validation:** Comprehensive client-side validation ensuring robust data integrity (e.g., proper email formats, credit hour constraints).
- **Target GPA Tool:** A localized planning utility to estimate the grades needed in upcoming semesters to reach a specific CGPA goal.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.3.4 <4.0.0`)
- An active instance of the **GPA Calculator REST API** (Backend)

### Installation

1. Clone the repository and navigate to the project directory:
   ```bash
   cd Flutter
   ```
2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## ⚙️ Configuration

The application is configured to point to the production Azure backend by default. If you need to test against a local backend, modify the `baseUrl` in `lib/core/constants/api_constants.dart`.

```dart
class ApiConstants {
  // Production
  static const String baseUrl = 'https://gpa-calculator-api-mohamed-d5e8gqcgcffcg9gj.germanywestcentral-01.azurewebsites.net';

  // Local Development (Android Emulator)
  // static const String baseUrl = 'http://10.0.2.2:8080';
}
```

---

## 🏗️ Project Architecture

```text
lib/
├── core/
│   ├── constants/api_constants.dart   # API Routes
│   ├── network/api_client.dart        # Dio Client & Interceptors (401 Fallback)
│   └── storage/token_storage.dart     # Secure JWT Persistence
├── models/                            # Serialization Models (Request/Response)
├── screens/                           # UI Views (Auth, Home, Semesters, Target)
├── services/                          # API Service abstraction
├── utils/                             # Error Handling & Utilities
├── widgets/                           # Reusable UI Components
└── main.dart                          # App Entry & Routing
```

---

## 📡 API Endpoints Consumed

| Method | Endpoint                             | Description                                  |
| ------ | ------------------------------------ | -------------------------------------------- |
| POST   | `/api/auth/register`                 | Register a new user account                  |
| POST   | `/api/auth/login`                    | Authenticate user and retrieve JWT tokens    |
| POST   | `/api/auth/refresh`                  | Refresh expired access tokens                |
| GET    | `/api/users/me`                      | Retrieve authenticated user profile          |
| POST   | `/api/semesters`                     | Create a new semester                        |
| GET    | `/api/semesters`                     | Fetch all semesters                          |
| GET    | `/api/semesters/{id}`                | Fetch detailed subjects of a semester        |
| PUT    | `/api/semesters/{id}`                | Update an existing semester                  |
| DELETE | `/api/semesters/{id}`                | Delete a semester                            |
| PATCH  | `/api/semesters/{id}/toggle-active`  | Toggle a semester's contribution to CGPA     |
| GET    | `/api/cgpa`                          | Retrieve aggregated CGPA metrics             |

---

## 👨‍💻 Author

**Mohamed Abdul Shafi**
