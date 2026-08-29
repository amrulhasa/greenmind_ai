# GreenMind AI

GreenMind AI is a cross-platform Flutter application that uses Google Gemini (via Firebase AI) to identify plants from images, assess plant health, detect diseases, generate personalized care reports (including PDF export), and provide an AI chatbot for plant-care guidance. It also includes care reminders, nearby nursery discovery, user authentication, profiles, and an admin panel.

**Live Demo:** [https://greenmind-ai-app.netlify.app/](https://greenmind-ai-app.netlify.app/)

**Repository:** [https://github.com/amrulhasa/greenmind_ai](https://github.com/amrulhasa/greenmind_ai)

---

## Overview

Many plant owners struggle to correctly identify plants, diagnose visible health issues, and maintain consistent care routines. GreenMind AI addresses this by combining on-device image capture with cloud-based multimodal AI analysis. Users can upload or capture a plant image, receive identification results with confidence scores, health assessments, disease analysis, practical care recommendations, and downloadable reports. The app also supports reminders, location-based nursery discovery, and user account management.

---

## Key Features

The following features are implemented in the current codebase:

- **AI Plant Identification** – Upload or capture an image; Gemini analyzes visual characteristics and returns common name, scientific name, confidence, description, care tips, and health status.
- **Plant Disease Detection** – Image-based analysis for visible disease/pest/stress symptoms, with confidence, symptoms, treatment, and prevention guidance. Results are cached locally by image hash.
- **AI-Generated Plant Care Reports** – Structured reports combining identification, health, disease analysis, care schedule, and recommendations. PDF generation and preview/export are supported (`pdf` + `printing` packages).
- **AI Chatbot** – Conversational plant-care assistant powered by Gemini with system instructions focused on identification, care, disease, and gardening topics.
- **Care Reminders** – Create and manage watering/care reminders with local notifications and alarm support.
- **Nearby Nursery Discovery** – Location-based nursery search using device geolocation and OpenStreetMap (`flutter_map` + `latlong2`).
- **User Authentication** – Email/password sign-in and registration via Firebase Authentication.
- **User Profile** – Profile management (name, location, phone, bio, profile image) stored in Cloud Firestore.
- **Application Preferences** – Dark mode and notification preferences.
- **Admin Panel** – Role-based admin area for users, identifications, plants, reports, announcements, feedback, support, logs, and app settings.
- **Announcements, Feedback & Support** – In-app announcement viewing, feedback submission, and support features.
- **Cross-platform UI** – Material 3 design targeting Android, iOS, and Web (deployed on Netlify).

---

## How It Works

1. User signs in or registers with Firebase Authentication.
2. From the home screen, the user selects Plant Identification or Disease Detection.
3. The user captures a photo or picks an image from the gallery.
4. The image bytes are sent to a Gemini model via Firebase AI (`firebase_ai`).
5. The model returns structured text (parsed into models such as `IdentifyResult` or `DiseaseResult`).
6. Results are displayed with confidence scores, descriptions, care tips, and health status.
7. Users can generate a full plant care report and export it as PDF.
8. Optional features: set care reminders, chat with the AI assistant, find nearby nurseries, or manage profile/settings.
9. Admins can access a separate dashboard for content and user management.

---

## Technology Stack

| Category              | Technology                                      |
|-----------------------|-------------------------------------------------|
| Framework             | Flutter                                         |
| Language              | Dart (SDK ^3.9.0)                               |
| State Management      | Riverpod (`flutter_riverpod`)                   |
| Navigation            | GoRouter                                        |
| UI                    | Material 3, Google Fonts, flutter_svg           |
| Authentication        | Firebase Auth                                   |
| Database              | Cloud Firestore                                 |
| AI                    | Firebase AI / Google Gemini                     |
| Image Handling        | image_picker, image, file_picker                |
| PDF Generation        | pdf, printing                                   |
| Local Storage         | shared_preferences, path_provider               |
| Location & Maps       | geolocator, flutter_map, latlong2               |
| Notifications         | flutter_local_notifications, timezone, alarm    |
| Networking            | dio                                             |
| Other                 | connectivity_plus, url_launcher, uuid, crypto, logger, intl |

**Deployment:** Web build published to Netlify (`netlify.toml` + `build.sh`).

---

## Project Architecture

Feature-first structure under `lib/`:

```
lib/
├── main.dart                 # App entry point, Firebase init, ProviderScope
├── firebase_options.dart
├── app/
│   ├── app.dart              # Root widget
│   ├── router.dart           # GoRouter configuration
│   └── theme.dart            # Light/dark themes
├── core/
│   ├── constants/            # Colors, spacing, radius, text styles
│   └── services/             # Shared services (e.g. AI helper)
└── features/
    ├── auth/                 # Login, register, user service
    ├── home/                 # Dashboard, recent plants
    ├── identify/             # Plant identification flow
    ├── disease/              # Disease detection flow
    ├── plant_report/         # Care reports + PDF generation
    ├── chatbot/              # AI chat assistant
    ├── reminder/             # Reminders & notifications
    ├── nursery/              # Nearby nursery map
    ├── profile/              # User profile
    ├── announcements/
    ├── feedback/
    ├── support/
    ├── admin/                # Admin dashboard & management
    └── splash/
```

Each feature typically contains `models/`, `providers/`, `screens/`, `services/`, and `widgets/`.

---

## AI Integration

AI capabilities are implemented with the **Firebase AI** package (`firebase_ai`), which provides access to Google Gemini models.

- **Plant Identification** (`IdentifyService` / `AIService`): Image bytes + detailed text prompt → structured fields (plant name, scientific name, confidence, description, care tips, healthy flag).
- **Disease Detection** (`DiseaseService`): Image + prompt → disease name, confidence, description, symptoms, treatment, prevention, healthy flag. Results are cached locally using SHA-256 image hash.
- **Chatbot** (`ChatbotService`): Multi-turn chat session with a system instruction that restricts the assistant to plant-care topics.

Models referenced in code include Gemini Flash variants (e.g. `gemini-2.5-flash`, `gemini-3.5-flash`, `gemini-3.5-flash-lite`, `gemini-3.6-flash`). Exact model names may be updated in the service files.

Input is primarily image data (`Uint8List` + MIME type detection) combined with carefully engineered prompts that request strict field-based or JSON-like output for reliable parsing.

---

## Firebase / Backend

| Service              | Role                                              |
|----------------------|---------------------------------------------------|
| Firebase Auth        | User sign-up, sign-in, session management         |
| Cloud Firestore      | User profiles (`users` collection), admin data, announcements, feedback, support, logs |
| Firebase AI          | Gemini model access for identification, disease analysis, and chatbot |
| Firebase App Check   | App integrity / security                          |
| Firebase Core        | Initialization                                    |

No custom backend server is required. The Flutter client communicates directly with Firebase services.

---

## Screenshots

Screenshots are not currently stored in the repository. Recommended placement:

```
docs/screenshots/
├── 01-login.png
├── 02-home.png
├── 03-identify.png
├── 04-disease.png
├── 05-report.png
├── 06-chatbot.png
├── 07-profile.png
└── 08-admin.png
```

After adding images, you can display them with:

```markdown
| Login | Home | Identify |
|:-----:|:----:|:--------:|
| ![Login](docs/screenshots/01-login.png) | ![Home](docs/screenshots/02-home.png) | ![Identify](docs/screenshots/03-identify.png) |
```

---

## Installation & Setup

### Prerequisites

- Flutter SDK (compatible with Dart SDK ^3.9.0)
- A Firebase project with Authentication, Cloud Firestore, and Firebase AI (Gemini) enabled
- Platform tooling (Android Studio / Xcode / Chrome) depending on target

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/amrulhasa/greenmind_ai.git
   cd greenmind_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase configuration**
   - The project includes `lib/firebase_options.dart` and `firebase.json`.
   - Ensure your Firebase project is correctly linked (FlutterFire CLI or manual configuration of `firebase_options.dart` and platform-specific files such as `google-services.json` / `GoogleService-Info.plist`).
   - Enable Email/Password authentication and create a Firestore database.
   - Enable the Gemini / Firebase AI API for your Firebase project.

4. **Run the application**
   ```bash
   flutter run
   ```
   Or target a specific platform:
   ```bash
   flutter run -d chrome
   flutter run -d android
   flutter run -d ios
   ```

### Web Deployment

The repository contains `netlify.toml` and `build.sh` for Netlify deployment. The published directory is `build/web`.

---

## Project Structure (Key Paths)

| Path | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, Firebase initialization, Riverpod scope |
| `lib/app/router.dart` | Route definitions and navigation |
| `lib/features/identify/` | Plant identification UI + Gemini service |
| `lib/features/disease/` | Disease detection UI + caching |
| `lib/features/plant_report/` | Care reports and PDF generation |
| `lib/features/chatbot/` | Conversational AI assistant |
| `lib/features/admin/` | Admin dashboard and management screens |
| `lib/features/nursery/` | Location + map-based nursery finder |
| `assets/` | Images, icons, animations, fonts |

---

## Future Improvements

Possible enhancements not yet fully implemented or still evolving:

- Expanded offline support and more robust local data synchronization
- Additional plant database / history features beyond current recent plants and reports
- Refined admin analytics and reporting dashboards
- Improved accessibility and internationalization
- More comprehensive automated tests

---

## Development Highlights

This project demonstrates:

- Multimodal AI integration (image + text prompts) with Google Gemini via Firebase AI
- Clean feature-first Flutter architecture
- Riverpod for state management
- GoRouter for declarative navigation
- Firebase Authentication and Cloud Firestore
- Image capture, processing, and local caching
- PDF report generation
- Local notifications and reminders
- Location services and interactive maps
- Role-based admin functionality
- Material 3 theming with light/dark mode support
- Cross-platform deployment (including web on Netlify)

---

## Author

**MD. AMRUL HASAN SAKIB**  
GitHub: [https://github.com/amrulhasa](https://github.com/amrulhasa)

---

## License

No license file is currently present in the repository. A license can be added later if desired.
