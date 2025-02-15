# Country Details App

## Overview
The **Country Details App** is a Flutter-based mobile application that allows users to browse and search for information about countries worldwide. The app fetches data from the [REST Countries API](https://restcountries.com/) and displays details such as population, language, currency, and more. It also includes filtering options by continent and time zone, language selection, and theme customization.

## Features
- 🌍 **Country List**: Browse a list of all countries.
- 🔎 **Search Functionality**: Quickly search for countries by name.
- 🏳 **Country Details**: View detailed information about a selected country, including flags and maps.
- 🌙 **Dark Mode Support**: Toggle between light and dark themes.
- 🌐 **Language Selection**: Choose a preferred language for country names.
- 🏛 **Filter Options**: Filter countries by continent and time zone.
- 🗺 **Map Integration**: Open country locations in an interactive map.

## Installation

### Prerequisites
Ensure you have the following installed on your system:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- Android Studio or VS Code (with Flutter plugin)

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/country-details-app.git
   cd country-details-app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure
```
/lib
│── main.dart            # Main entry point of the app
│── country_list.dart    # Displays the list of countries
│── country_detail.dart  # Displays detailed country information
│── map_view.dart        # WebView for maps
│── theme.dart           # Theme customization
│── utils.dart           # Utility functions
│── widgets              # Custom UI components
```

## API Usage
The app fetches country data from the [REST Countries API](https://restcountries.com/v3.1/all). API responses are parsed and displayed in the app.

## Dependencies
The following Flutter packages are used:
- `http` - For making API requests.
- `webview_flutter` - For displaying maps in a WebView.
- `flutter/material.dart` - Standard Flutter UI framework.

## Deployment
The app can be deployed using [Appetize.io](https://appetize.io/) for online previews. Alternatively, it can be published to the Google Play Store or Apple App Store following standard Flutter deployment procedures.
Here is the appetize link for the app (https://appetize.io/app/b_d6u3tj5vghz2gf5hj4xkrhlqma)
## Screenshots
### Home Screen
![Home Screen](screenshots/home.png)
### Country Details
![Country Details](screenshots/details.png)

## Future Enhancements
- 📌 **Offline Mode**: Cache country data for offline access.
- 🏴 **More Filters**: Additional filtering options like GDP, HDI, and independence status.
- 📍 **Improved Map Support**: Implement native map integration for a better experience.

## License
This project is licensed under the **MIT License**.

## Contact
For any issues or contributions, feel free to create a pull request or reach out via email at chukwuemekaeke007@gmail.com