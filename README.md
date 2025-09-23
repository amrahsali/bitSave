# Estate360 Security

![Estate360 Security](https://your-logo-url.com/logo.png) <!-- (Optional: Add a logo or relevant banner here) -->

## Overview
Estate360 Security is a comprehensive security management mobile application designed to enhance estate security operations, visitor management, and overall safety for residential and commercial estates. The app provides:

- Real-time monitoring
- Visitor tracking
- Incident reporting
- Seamless communication between estate security personnel, residents, and management

This solution is a key component of the Estate360 ecosystem, offering a robust and efficient way to manage estate security with modern technology-driven security protocols.

---

## 🚀 Features

### ✅ Visitor Management
- Generate and verify visitor invitation codes (QR-based)
- Approve or deny visitor access requests
- Track visitor logs and view visit history

### ✅ Security Personnel Dashboard
- Overview of estate security alerts and visitor logs
- Assign and receive security tasks
- Report and track incidents in real time

### ✅ Incident Reporting & Alerts
- Report security incidents with photos and descriptions
- Push notifications for emergency alerts
- Instant updates to estate managers & residents

### ✅ Resident Integration
- View approved visitor list
- Notify security of expected deliveries or guests
- Request emergency security assistance

### ✅ Access Control & Monitoring
- Digital check-in/check-out for visitors & service providers
- View security camera feeds (where supported)
- Integrate with estate gate access control systems

---

## 🛠 Technology Stack
The Estate360 Security app is built with a modern and scalable technology stack to ensure performance, security, and reliability.

| Technology       | Usage                                      |
|-----------------|--------------------------------------------|
| **Flutter**     | Cross-platform app development            |
| **Dart**        | App logic and UI implementation           |
| **Firebase**    | Push notifications, authentication, analytics |
| **REST API**    | Backend communication                     |
| **SQLite/Sembast** | Local storage for offline access      |
| **Google Maps API** | Location tracking and geofencing    |
| **Twilio/Sendchamp** | OTP verification & SMS notifications |

---

## 📥 Installation Guide

### Prerequisites
Before running the project, ensure you have the following installed:

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (Included with Flutter)
- **Android Studio / Xcode** (For device emulation)
- **Firebase CLI** (For authentication & notifications)
- **CocoaPods** (For iOS builds: `brew install cocoapods`)

### Clone the Repository
```sh
git clone https://github.com/EchobitsTech/estate360-security.git
cd estate360-security
```

### Set Up Firebase
1. Create a Firebase project.
2. Add Android & iOS apps to Firebase.
3. Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS).
4. Place them in:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```
5. Run Firebase configuration:
   ```sh
   flutterfire configure
   ```

### Install Dependencies
```sh
flutter pub get
```

### Run the App
For Android:
```sh
flutter run
```
For iOS: (Ensure Xcode is installed and configured)
```sh
cd ios
pod install
cd ..
flutter run
```

---

## 📂 Folder Structure
```bash
estate360-security/
│── lib/                  # Main application code
│   ├── core/             # Core utilities & network handling
│   ├── data/             # Models, repositories & local storage
│   ├── ui/               # UI components & screens
│   ├── services/         # API services & authentication
│   ├── state/            # State management
│   ├── app/              # App configuration & routing
│   ├── main.dart         # Entry point
│── assets/               # Images, icons, animations
│── android/              # Android-specific configuration
│── ios/                  # iOS-specific configuration
│── pubspec.yaml          # Dependencies & app metadata
│── README.md             # Project documentation
```

---

## 📡 API Endpoints
| Method | Endpoint | Description |
|--------|---------|-------------|
| **POST** | `/auth/login` | Authenticate security personnel |
| **GET**  | `/security/visitors` | Fetch visitor logs |
| **POST** | `/auth/user/{userId}/update-device` | Update device information |
| **POST** | `/security/report-incident` | Report a security incident |
| **GET**  | `/estate/alerts` | Fetch active alerts |

---

## 🔧 Environment Variables (.env)
Set up a `.env` file in the project root to configure API keys and environment settings.

```env
API_BASE_URL=https://esecure.echobitsone.com/api
FIREBASE_KEY=your-firebase-key
MAPS_API_KEY=your-google-maps-key
PUSH_NOTIFICATIONS_ENABLED=true
```

---

## 🔒 Security & Compliance
- **Data Encryption**: All sensitive user data is encrypted.
- **GDPR & Compliance**: Estate360 adheres to data protection regulations.
- **Role-Based Access Control**: Different access levels for security officers, residents, and estate managers.

---

## 🚀 Upcoming Features
✔ AI-Powered Threat Detection
✔ License Plate Recognition for Vehicles
✔ Blockchain-based Incident Logging
✔ Real-time Estate Security Analytics Dashboard

---

## 👥 Contributors ✨
- **[George David]** - Lead Developer
- **[Team Member]** 
- **[Other Team Members]**

Want to contribute? Feel free to reach out to [support@echobitstech.com](mailto:support@echobitstech.com).

---

## 📜 License
This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact & Support
For support, contact:

📩 **Email**: [support@echobitstech.com](mailto:support@echobitstech.com)
🌐 **Website**: [Estate360 Hub](https://estate360hub.com)
