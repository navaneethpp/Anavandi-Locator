// constants.dart

// This file defines global constants used throughout the Anavandi Locator application.
// It centralizes the definition of values that are used in multiple parts of the app,
// making it easier to maintain and modify these values consistently.

// Documentation:
//
// File Purpose:
// The constants.dart file is designed to hold application-wide constants.
// Currently, it defines constants specifically related to the map functionality,
// such as icon sizes and zoom levels. Using constants improves code readability,
// maintainability, and allows for easy adjustments of these values across the entire application
// by modifying them in a single location.
//
// Constants Defined:
// - iconSize: `const double iconSize = 30.0;`
//   - Purpose: Defines the default size for icons used within the map widgets.
//   - Value: Set to `30.0` (pixels). This value determines the dimensions (width and height)
//     of icons displayed on the map, such as bus markers, user location markers, or other points of interest.
//     Adjusting this constant will change the size of all map-related icons consistently.
//
// - zoomValue: `const double zoomValue = 16;`
//   - Purpose: Defines the initial zoom level for the FlutterMap widget when it is first loaded.
//   - Value: Set to `16`. This value represents the zoom level at which the map is initially displayed.
//     Higher values indicate a closer zoom level (more detail), while lower values indicate a wider view (less detail).
//     Setting an appropriate initial zoom level is important for providing a good user experience when the map first appears.
//
// Usage:
// These constants can be imported and used in any Dart file within the project where these values are needed.
// For example, in map-related widgets, you can use `iconSize` to set the size of map icons and `zoomValue` to set the initial zoom level of the map.
//
// Benefits of Using Constants:
// - Maintainability: If you need to change the icon size or initial zoom level across the app, you only need to change the values in this file.
// - Readability: Using named constants like `iconSize` and `zoomValue` makes the code more self-documenting and easier to understand compared to using magic numbers (e.g., `30.0`, `16`).
// - Consistency: Ensures that the same values are used consistently throughout the application for these specific settings.
// - Reusability: Constants can be easily reused in different parts of the application.

const double iconSize = 30.0; // Icon size for Maps
const double zoomValue = 16; // Initial Zoom value
