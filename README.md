# Linksy

Linksy is a Flutter application designed to help you manage, track, and nurture your personal and professional relationships. Keep track of connections, relation types, labels, and set follow-up reminders to ensure you never lose touch with the people who matter most.

---

## ✨ Features

- **People Dashboard**: View all your connections in one place with detailed profile cards.
- **Categorization & Labels**: Tag your contacts with custom labels and specify connection types.
- **Follow-up Reminders**: Set dates to follow up with contacts and get notified so you never miss an important check-in.
- **Offline First**: All your data is stored securely on your device for lightning-fast access, even without an internet connection.
- **Beautiful UI**: Modern, clean, and responsive design with smooth animations and dynamic theming.

## 🛠️ Tech Stack

Linksy is built using modern Flutter development practices and libraries:

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
- **Local Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Routing**: [Go Router](https://pub.dev/packages/go_router)
- **UI & Styling**: `flex_color_scheme`, `google_fonts`, `lucide_icons`, `flutter_animate`
- **Background Processing**: `workmanager`
- **Notifications**: `flutter_local_notifications`

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.10.1 or higher)
- Android Studio / Xcode for emulators and building.

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/linksy.git
   ```
2. Navigate to the project directory:
   ```sh
   cd linksy
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Run code generation (for Riverpod, Drift):
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```sh
   flutter run
   ```

## 📸 Screenshots

*(Replace with actual screenshots of your application)*

| Dashboard | Person Details | Add Connection |
| :---: | :---: | :---: |
| <img src="screenshot1.png" width="200" alt="Dashboard"> | <img src="screenshot2.png" width="200" alt="Details"> | <img src="screenshot3.png" width="200" alt="Add Person"> |

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
