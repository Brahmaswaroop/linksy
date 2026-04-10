# Linksy 🔗

**Linksy** is a relationship management tool designed to help you track, nurture, and visualize your personal and professional networks. It moves beyond a simple contact list by focusing on **relationship health** and **interaction quality**.

---

## 🎯 The Goal
The primary objective of Linksy is to prevent important relationships from "fading away" due to lack of communication. It achieves this by:
1.  **Setting Intentions**: Defining how often you want to connect with someone.
2.  **Tracking Reality**: Logging actual interactions and calculating a "Health Score."
3.  **Visualizing Networks**: Mapping connections to see how people are linked.

---

## ✨ Key Features

### 🟢 Relationship Health Dashboard
The main screen provides a prioritized list of contacts.
- **Status Indicators**: Each person has a health status (🟢 Healthy, 🟡 Warning, 🔴 Overdue).
- **Priority Levels**: Contacts are ranked (Low, Medium, High), which affects their sorting and how fast their health score drops when overdue.
- **Sorting Logic**: Combines health score and priority to ensure the most "at-risk" relationships are at the top.

### ✍️ Interaction Logging
Users can log various types of communication:
- **Types**: Calls, Messages, Meetings.
- **Energy Rating**: A unique metric (1-5) to track how "energizing" or "draining" an interaction was.
- **Notes**: Capture context for future reference.

### 🧠 Dynamic Health Score Engine
The heart of the app is a custom engine that calculates a score (0-100%) based on:
- **Frequency (50%)**: How close the current date is to the target follow-up date.
- **Consistency (30%)**: Analyzes the average gap between past interactions.
- **Priority Penalty (20%)**: Higher priority relationships lose health faster if a check-in is missed.

### 🕸️ Interactive Connection Graph
A visual map of your social or professional network.
- **Primary Connections**: People you know directly orbit "You" at the center.
- **Secondary (Weak) Connections**: Indirect links (e.g., "friend of a friend") orbit the person who introduced them.
- **Category Filtering**: View specific segments of your network (Family, Work, Colleague, etc.).

### 🔔 Automated Reminders
- **Notifications**: The app sends local notifications when a relationship becomes overdue.
- **Background Processing**: Uses `workmanager` to update health scores and trigger reminders periodically.

---

## 📸 Screenshots

*(Replace with actual screenshots of your application)*

| Dashboard | Person Details | Network Graph |
| :---: | :---: | :---: |
| <img src="screenshot1.png" width="200" alt="Dashboard"> | <img src="screenshot2.png" width="200" alt="Details"> | <img src="screenshot3.png" width="200" alt="Graph"> |

---

## 🛠️ Technical Implementation
Linksy is built using modern Flutter development practices:
- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive and robust)
- **Local Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for high-performance offline storage
- **UI & Styling**: `flex_color_scheme`, `google_fonts`, `lucide_icons`, `flutter_animate`
- **Routing**: [Go Router](https://pub.dev/packages/go_router)
- **Background Processing**: `workmanager`
- **Notifications**: `flutter_local_notifications`

---

## 🚀 Getting Started

To get a local copy up and running, follow these steps.

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

---

## 🤝 Contributing
Contributions are welcome! If you have suggestions for improvement or new features, please open an issue or submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License
Distributed under the MIT License. See `LICENSE` for more information.
