import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/api/open_route_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> calculateETA({
  required LatLng? busLocation,
  required LatLng? userLocation,
  required LatLng? endLocation,
  required bool isInBus,
  required ValueSetter<String> onEtaUpdated, // Callback to update ETA in UI
  required bool mounted,
  required TickerProvider vsync, // For the TickerProvider
  required String openRouteSerivceAPI,
}) async {
  print('ETA Calculator: calculateETA() called');
  if (busLocation == null) {
    print('ETA Calculator: Cannot calculate ETA - bus location is null');
    return;
  }

  LatLng? targetLocation;
  if (!isInBus && userLocation != null) {
    targetLocation = userLocation;
    print('ETA Calculator: Calculating ETA to user location: $userLocation');
  } else if (isInBus && endLocation != null) {
    targetLocation = endLocation;
    print('ETA Calculator: Calculating ETA to destination: $endLocation');
  } else {
    print(
      'ETA Calculator: Cannot calculate ETA - target location is null or user choice not made.',
    );
    onEtaUpdated(''); // Update ETA to empty
    return;
  }

  final startLat = busLocation.latitude;
  final startLng = busLocation.longitude;
  final endLat = targetLocation.latitude;
  final endLng = targetLocation.longitude;

  print('ETA Calculator: Bus Location for ETA: $busLocation');
  print('ETA Calculator: Target Location for ETA: $targetLocation');

  final orsDirectionsUrl = Uri.parse(
    'https://api.openrouteservice.org/v2/directions/driving-car'
    '?api_key=$openRouteSerivceAPI'
    '&start=$startLng,$startLat&end=$endLng,$endLat',
  );

  print(
    'ETA Calculator: OpenRouteService ETA API URL: ${orsDirectionsUrl.toString()}',
  );

  try {
    final response = await http.get(orsDirectionsUrl);

    print(
      'ETA Calculator: OpenRouteService ETA API response - Status Code: ${response.statusCode}',
    );
    print(
      'ETA Calculator: OpenRouteService ETA API response - Body: ${response.body}',
    );
    print('ETA Calculator: Full ETA API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('ETA Calculator: Parsed JSON data: $data');
      final List<dynamic> features = data['features'];
      print('ETA Calculator: Features list: $features');
      if (features.isNotEmpty) {
        final properties = features[0]['properties'];
        print('ETA Calculator: Properties map: $properties');
        dynamic durationValue;
        if (properties['segments'] != null &&
            (properties['segments'] as List).isNotEmpty) {
          durationValue = properties['segments'][0]['duration'];
        } else {
          durationValue = null;
          print(
            'ETA Calculator: OpenRouteService ETA API response - Segments array is empty or null.',
          );
          onEtaUpdated('ETA not available');
          return; // Exit if no segments found
        }
        print('ETA Calculator: Raw duration value from API: $durationValue');

        if (durationValue != null) {
          double? durationInSeconds;
          if (durationValue is int) {
            durationInSeconds = durationValue.toDouble();
            print(
              'ETA Calculator: Duration is an integer, converted to: $durationInSeconds',
            );
          } else if (durationValue is double) {
            durationInSeconds = durationValue;
            print('ETA Calculator: Duration is a double: $durationInSeconds');
          }

          if (durationInSeconds != null) {
            final duration = Duration(seconds: durationInSeconds.toInt());
            String twoDigits(int n) => n.toString().padLeft(2, '0');
            final hours = twoDigits(duration.inHours);
            final minutes = twoDigits(duration.inMinutes.remainder(60));
            final seconds = twoDigits(duration.inSeconds.remainder(60));
            final formattedDuration = '$hours:$minutes:$seconds';
            if (mounted) {
              onEtaUpdated(formattedDuration); // Update ETA using the callback
              print('ETA Calculator: ETA calculated: $formattedDuration');
            }
          } else {
            print(
              'ETA Calculator: OpenRouteService ETA API response - Could not parse duration as double or int.',
            );
            if (mounted) {
              onEtaUpdated('ETA not available');
            }
          }
        } else {
          print(
            'ETA Calculator: OpenRouteService ETA API response - Duration is null.',
          );
          if (mounted) {
            onEtaUpdated('ETA not available');
          }
        }
      } else {
        print(
          'ETA Calculator: OpenRouteService ETA API response - No route features found.',
        );
        if (mounted) {
          onEtaUpdated('ETA not available');
        }
      }
    } else {
      print(
        'ETA Calculator: OpenRouteService ETA API request failed: ${response.statusCode}, Body: ${response.body}',
      );
      if (mounted) {
        onEtaUpdated('Error calculating ETA');
      }
    }
  } catch (e) {
    print('ETA Calculator: Error fetching ETA from ORS: $e');
    if (mounted) {
      onEtaUpdated('Error calculating ETA');
    }
  }
}
