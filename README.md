# Anavandi Locator - Bus Route Navigation App
## Project Overview
&emsp;Anavandi Locator is a Flutter mobile application designed to help users find and track buses for their commute.  It provides a user-friendly interface to search for bus routes, view detailed bus information, and track bus locations in real-time on a map. The app leverages Firebase for real-time data and OpenRouteService API for route planning.

## Features
- Bus Route Search:
  - Users can search for buses by specifying a starting point and destination from a list of available depots.
  - Autocompletion suggestions for depot names enhance search efficiency.
  - Input validation ensures accurate search queries and valid location entries from the database.
- Real-time Bus Location Tracking:
  - Displays the current location of selected buses on an interactive map.
  - Real-time updates of bus locations are fetched from Firebase Firestore.
- User Location Display (Optional):
  - Optionally displays the user's current location on the map.
  - Periodic location fetching when the user is not travelling by bus.
- Route Polyline Visualization:
  - Visualizes the bus route on the map as a polyline, showing the path from the user's starting point to the bus destination.
  - Route data is fetched using the OpenRouteService API.
- Bus Details Page:
  - Provides a dedicated page with comprehensive details about a selected bus, including registration number, unique number, current location, arrival time, and bus type.
  - Displays the bus destination on a map in the details page.
- Map Controls:
  - Menu options to center the map on the bus location or user location.
  - Option to manually re-fetch user location.
  - Compass widget for map orientation.
- Recent Routes History:
  - Keeps a history of recently searched bus routes for quick access.
  - Users can swipe to delete individual routes from history or clear the entire history.
- Favorite Buses (Visual):
  - Allows users to "favorite" buses (functionality is currently visual and local - persistence needs backend implementation).
- Splash Screen:
  - Displays a branding splash screen during app startup with a loading progress indicator.
- Location Permissions & Services:
  - Handles location permissions gracefully, requesting access if needed.
  - Provides user feedback if location services are disabled or permissions are denied.
## Getting Started
Follow these steps to get the Anavandi Locator app running on your local machine:

### Prerequisites
- **Flutter SDK:** Ensure you have Flutter SDK installed and configured correctly. Flutter Installation Guide
- **Android Studio or VS Code:** Recommended IDE for Flutter development.
- **Firebase Project:** You need to have a Firebase project set up. Firebase Console
- **OpenRouteService API Key:** Obtain an API key from OpenRouteService.

## ⚠️ Usage Restriction

This project is proprietary and not intended for reuse, redistribution, or modification without the author's written consent.


### OpenRouteService API
- The app utilizes the OpenRouteService API for fetching driving route polyline data.
- You need to sign up for a free account at OpenRouteService to obtain an API key.
- Remember to replace the placeholder `YOUR_OPENROUTESERVICE_API_KEY` in `lib/api/open_route_service.dart` with your actual API key.
### Project Structure
<pre>
anavandi_locator/
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── lib/                   # Dart source code
│   ├── api/               # API related files (open_route_service.dart)
│   ├── screen/            # Application screens/pages
│   │   ├── bus_details_page.dart
│   │   ├── main_screen.dart
│   │   ├── recent_page.dart
│   │   ├── splash_screen.dart
│   ├── widgets/           # Reusable widgets
│   │   ├── bus_selection_menu.dart
│   │   ├── compass_widget.dart
│   │   ├── constants.dart
│   │   ├── map.dart
│   │   ├── textForBusDetails.dart
│   ├── main.dart          # Main application entry point
├── assets/                # Application assets (images, logos)
├── pubspec.yaml         # Project dependencies and configuration
├── readme.md            # Project README file (this file)
</pre>
### Dependencies
- **flutter_map:** For interactive map display.
- **latlong2:** For handling latitude and longitude coordinates.
- **geolocator:* For accessing device location services.
- **font_awesome_flutter:** For Font Awesome icons.
- **http:** For making HTTP requests (to OpenRouteService API).
- **cloud_firestore:** For Firebase Firestore integration.
- **firebase_core:** For core Firebase functionality.
- **sensors_plus:** For accessing device sensors (magnetometer for compass).
- **string_extensions:** For string manipulation utilities (e.g., `toTitleCase`).
