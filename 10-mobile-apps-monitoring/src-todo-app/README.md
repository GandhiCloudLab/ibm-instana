# Flutter Todo App - Advanced Edition

A comprehensive, feature-rich todo list application built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-green.svg)
![License](https://img.shields.io/badge/License-Open%20Source-orange.svg)

## 🚀 Quick Start

```bash
# Setup and run on web
flutter create . --platforms=web,macos
flutter pub get
flutter run -d chrome

# Setup and run on iOS Simulator
flutter create . --platforms=ios
cd ios && pod install && cd ..
flutter run
```

## ✨ Features

- ✅ Add, Edit, Delete Todos
- 🏷️ Categories (Personal, Work, Shopping, Health, Other)
- 🚩 Priority Levels (Low, Medium, High)
- 📅 Due Dates with Date Picker
- 🏷️ Custom Tags
- 🔍 Real-time Search
- 🎯 Advanced Filtering
- 🎨 Dark Mode Support
- 📊 Statistics Dashboard
- 💾 Persistent Local Storage
- 📱 Cross-Platform (iOS, Android, Web, Desktop)

## 📚 Documentation

All documentation has been moved to the `/docs` folder:

- **[Complete README](docs/README.md)** - Full project documentation
- **[Features Guide](docs/FEATURES.md)** - Detailed features documentation
- **[Setup Guide](docs/SETUP_GUIDE.md)** - Installation and setup instructions
- **[Quick Start](docs/QUICK_START.md)** - Quick reference commands
- **[iOS Testing Guide](docs/IOS_TESTING_GUIDE.md)** - How to test on iOS Simulator

## 🎯 Platform Support

| Platform | Status | Command |
|----------|--------|---------|
| 🌐 Web | ✅ Ready | `flutter run -d chrome` |
| 🍎 iOS | ✅ Ready | `flutter run` (with simulator) |
| 🤖 Android | ✅ Ready | `flutter run` (with emulator) |
| 🖥️ macOS | ✅ Ready | `flutter run -d macos` |
| 🪟 Windows | ✅ Ready | `flutter run -d windows` |
| 🐧 Linux | ✅ Ready | `flutter run -d linux` |

## 📱 Testing on iOS

Want to test the app on iOS Simulator? Check out our comprehensive guide:

👉 **[iOS Testing Guide](docs/IOS_TESTING_GUIDE.md)**

Quick iOS setup:
```bash
flutter create . --platforms=ios
cd ios && pod install && cd ..
flutter run
```

## 🏗️ Project Structure

```
app1/
├── lib/
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable widgets
│   └── main.dart        # App entry point
├── docs/                # Documentation
├── ios/                 # iOS platform files
├── android/             # Android platform files
├── web/                 # Web platform files
└── macos/               # macOS platform files
```

## 🔧 Technologies

- **Flutter** - UI Framework
- **Provider** - State Management
- **SharedPreferences** - Local Storage
- **Material Design 3** - UI Design System
- **Intl** - Date Formatting

## 📖 Getting Started

1. **Install Flutter**: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

2. **Clone/Download** this project

3. **Enable platforms**:
   ```bash
   flutter create . --platforms=ios,android,web,macos
   ```

4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🎨 Screenshots

The app features:
- Beautiful gradient backgrounds
- Color-coded priorities
- Swipe actions
- Dark mode support
- Statistics dashboard
- And much more!

## 📄 License

This project is open source and available for educational purposes.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📞 Support

For detailed documentation, troubleshooting, and guides, visit the [docs](docs/) folder.

---

**Version**: 2.0.0  
**Last Updated**: March 2026

Made with ❤️ using Flutter