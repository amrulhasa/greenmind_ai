# GreenMind AI

> **AI-Powered Plant Identification & Smart Plant Care Assistant**

GreenMind AI is a cross-platform Flutter application that combines **Google Gemini AI through Firebase AI** with a modern plant-care experience. It helps users identify plants from images, analyze plant health, detect visible diseases, generate personalized care reports, receive AI-powered guidance, manage care reminders, and discover nearby nurseries.

<p align="center">
  <a href="https://greenmind-ai-app.netlify.app/">Live Demo</a> •
  <a href="https://github.com/amrulhasa/greenmind_ai">Source Code</a>
</p>

---

## Project Overview

Plant owners often have difficulty identifying unfamiliar plants, recognizing visible health problems, and maintaining consistent care routines. GreenMind AI addresses these challenges through an AI-assisted workflow:

**Capture / Upload Image → AI Analysis → Plant & Health Insights → Personalized Care → Ongoing Reminders**

The application combines multimodal AI analysis, Firebase services, local device capabilities, and a feature-first Flutter architecture to provide a complete smart plant-care platform.

---

## Key Features

### AI & Plant Intelligence

- **AI Plant Identification** — Identify plants from captured or uploaded images.
- **Plant Health Analysis** — Receive an AI-generated visual health assessment and health score.
- **Disease Detection** — Analyze visible disease, pest, or stress symptoms with confidence, symptoms, treatment, and prevention guidance.
- **Personalized Plant Care Report** — Generate a structured care report containing health analysis, care guidance, schedules, and recommendations.
- **PDF Report Export** — Preview and export generated plant-care reports as PDF.
- **AI Plant-Care Chatbot** — Ask questions and receive conversational guidance focused on plants, gardening, identification, and care.

### Smart Plant Care

- **Care Reminders** — Create watering and plant-care reminders.
- **Local Notifications & Alarms** — Receive scheduled care notifications.
- **Nearby Nursery Discovery** — Find nearby nurseries using device location and OpenStreetMap-based maps.

### User & Platform Features

- **Firebase Authentication** — Email/password registration and sign-in.
- **User Profiles** — Manage name, location, phone, bio, and profile information.
- **Dark Mode** — Light and dark application themes.
- **Notification Preferences** — Control plant-care notifications.
- **Announcements, Feedback & Support** — Built-in communication features.
- **Admin Panel** — Role-based administration for users, plant identifications, reports, announcements, feedback, support, logs, and application settings.
- **Cross-Platform UI** — Flutter application targeting Android, iOS, and Web.

---

## How GreenMind AI Works

1. The user registers or signs in using Firebase Authentication.
2. The user selects **Plant Identification** or **Disease Detection**.
3. A plant image is captured or selected from the device.
4. The image is analyzed using Google Gemini through Firebase AI.
5. AI results are parsed into structured application models.
6. The application displays identification, confidence, health, disease, and care information.
7. The user can generate a personalized plant-care report and export it as PDF.
8. Users can continue managing reminders, chatting with the AI assistant, finding nearby nurseries, and updating their profile.
9. Administrators can manage application data through the dedicated admin area.

---

## Technology Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Navigation | GoRouter |
| UI | Material 3, Google Fonts, flutter_svg |
| AI | Firebase AI / Google Gemini |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Networking | Dio |
| Image Processing | image_picker, image, file_picker |
| PDF | pdf, printing |
| Local Storage | shared_preferences, path_provider |
| Location | Geolocator |
| Maps | OpenStreetMap, flutter_map, latlong2 |
| Notifications | flutter_local_notifications, timezone |
| Alarm | alarm |
| Security | Firebase App Check |
| Utilities | connectivity_plus, url_launcher, uuid, crypto, logger, intl |
| Deployment | Netlify |

---

## Architecture

GreenMind AI follows a **feature-first Flutter architecture** designed to keep application modules organized and maintainable.

```text
lib/
├── main.dart
├── firebase_options.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   └── services/
│
└── features/
    ├── auth/
    ├── home/
    ├── identify/
    ├── disease/
    ├── plant_report/
    ├── chatbot/
    ├── reminder/
    ├── nursery/
    ├── profile/
    ├── announcements/
    ├── feedback/
    ├── support/
    ├── admin/
    └── splash/
```

Most features are organized around their own **models, providers, screens, services, and widgets**, making the project easier to extend and maintain.

---

## AI Integration

GreenMind AI uses **Firebase AI** to access Google Gemini models for multimodal plant analysis and conversational assistance.

### Plant Identification

The identification workflow sends plant image data together with a carefully designed prompt and processes the AI response into structured fields such as:

- Plant/common name
- Scientific name
- Confidence score
- Description
- Care tips
- Health status

### Disease Detection

The disease-analysis workflow evaluates an uploaded plant image and provides:

- Disease or issue name
- Confidence score
- Description
- Symptoms
- Treatment guidance
- Prevention guidance
- Health status

Disease results are cached locally using an image hash to reduce unnecessary repeated processing.

### AI Chatbot

The chatbot uses a multi-turn AI session with plant-care-focused instructions so users can ask questions about plant identification, care, disease symptoms, gardening, and related topics.

---

## Firebase Architecture

| Firebase Service | Purpose |
|---|---|
| Firebase Authentication | User registration, sign-in, and session management |
| Cloud Firestore | Profiles, application data, announcements, feedback, support, and administrative data |
| Firebase AI | Google Gemini-powered plant analysis and chatbot |
| Firebase App Check | Application integrity and security |
| Firebase Core | Firebase initialization and configuration |

The application does not require a separate custom backend server for its core functionality; the Flutter client communicates with Firebase services directly.

---

## Screenshots

The application includes the following major interfaces:

- Login & Registration
- Home Dashboard
- Plant Identification
- AI Plant Health / Care Report
- Disease Detection
- AI Chatbot
- Care Reminders
- Nearby Nursery Finder
- User Profile & Preferences
- Admin Dashboard

> Screenshots can be added under `docs/screenshots/` as the project documentation is expanded.

---

## Live Demo

**Web Application:**

https://greenmind-ai-app.netlify.app/

The web version is deployed on **Netlify** and demonstrates the application's core user interface and workflows.

---

## Getting Started

### Prerequisites

- Flutter SDK compatible with the project's Dart SDK
- Android Studio / Xcode / Chrome depending on target platform
- A Firebase project
- Firebase Authentication enabled
- Cloud Firestore configured
- Firebase AI / Gemini configured for the project

### Installation

```bash
git clone https://github.com/amrulhasa/greenmind_ai.git
cd greenmind_ai
flutter pub get
```

### Firebase Configuration

Make sure the Firebase project is correctly configured for the target platforms. The repository includes the project's Firebase configuration files. Authentication, Firestore, and Firebase AI must be configured in the Firebase project before using the corresponding features.

### Run

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run -d android
```

---

## Web Deployment

The repository contains Netlify deployment configuration, including `netlify.toml` and `build.sh`.

The published Flutter Web output is generated in:

```text
build/web
```

---

## Project Highlights

This project demonstrates practical experience with:

- Multimodal AI integration using Google Gemini
- Firebase AI integration
- Flutter and Dart application development
- Riverpod state management
- GoRouter navigation
- Firebase Authentication and Cloud Firestore
- Image capture and processing
- AI-powered plant identification and disease analysis
- PDF report generation and export
- Local notifications and scheduled reminders
- Location services and interactive maps
- Role-based administration
- Material 3 responsive UI
- Light and dark themes
- Cross-platform development and web deployment

---

## Future Improvements

Potential areas for future development include:

- Stronger offline support and synchronization
- Expanded plant history and knowledge database
- More advanced analytics for administrators
- Improved accessibility and internationalization
- Broader automated test coverage
- Additional plant-care automation and personalization

---

## Author

**MD. AMRUL HASAN SAKIB**

Computer Science Student | Software Developer | AI & Machine Learning Enthusiast

- GitHub: https://github.com/amrulhasa
- Project: https://github.com/amrulhasa/greenmind_ai
- Live Demo: https://greenmind-ai-app.netlify.app/

---

## License

No license file is currently included in this repository.
