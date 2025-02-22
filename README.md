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

### Installation
1. Clone the Repository:

```Bash
git clone <repository_url>
cd anavandi_locator
```
2. Install Dependencies:

```Bash

flutter pub get
```
3. Firebase Configuration:
  - **Enable Firestore Database:** In your Firebase project console, enable the Firestore Database.
  - **Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS):** From your Firebase project settings, download the configuration files for Android and iOS.
  - **Place Configuration Files:**
    - Android: Place `google-services.json` in the `android/app/ directory`.
    - iOS: Place  `GoogleService-Info.plist` in the `ios/Runner/ directory`.
4. OpenRouteService API Key Configuration:
  - Create a file named `open_route_service.dart` in the `lib/api/` directory (if it doesn't exist).
  - Add your OpenRouteService API key to this file:

```Dart
// lib/api/open_route_service.dart
const String openRouteSerivceAPI = 'YOUR_OPENROUTESERVICE_API_KEY'; // Replace with your actual API key
```
&emsp;**Replace `YOUR_OPENROUTESERVICE_API_KEY` with the API key you obtained from OpenRouteService.**

5. Run the App:

```Bash

flutter run
```
&emsp;Choose your desired device (connected device or emulator) and run the application.

### Firebase Setup Details
- **Firestore Database:** The app uses Firestore to store and retrieve real-time bus location data.

  - **Collection Name:** `Depot` - Stores depot names and locations (latitude, longitude).
  - **Collection Name:** `location` - Document `location` within this collection is used to stream bus location updates. The document should have a field named `Location` storing location data as a string (e.g., "10.1234N, 77.5678E").
Firestore Data Structure (Example):

### Depot Collection:

```JSON

[
  {
    "name": "City Center Depot",
    "location": [10.1234, 76.5678] // Latitude, Longitude (as an array)
  },
  {
    "name": "Uptown Depot",
    "location": [10.5678, 76.9012]
  },
  // ... more depots
]
```
**location Collection (Document: `location`):**
```JSON

{
  "Location": "10.7675N, 76.6492E" // Example location string format
}
```
&emsp;**Note:** Ensure your Firestore database rules are configured appropriately for your application's security needs.

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
