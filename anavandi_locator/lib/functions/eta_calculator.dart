import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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
  if (busLocation == null) {
    return;
  }

  LatLng? targetLocation;
  if (!isInBus && userLocation != null) {
    targetLocation = userLocation;
  } else if (isInBus && endLocation != null) {
    targetLocation = endLocation;
  } else {
    onEtaUpdated(''); // Update ETA to empty
    return;
  }

  final startLat = busLocation.latitude;
  final startLng = busLocation.longitude;
  final endLat = targetLocation.latitude;
  final endLng = targetLocation.longitude;

  final orsDirectionsUrl = Uri.parse(
    'https://api.openrouteservice.org/v2/directions/driving-car'
    '?api_key=$openRouteSerivceAPI'
    '&start=$startLng,$startLat&end=$endLng,$endLat',
  );

  try {
    final response = await http.get(orsDirectionsUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> features = data['features'];
      if (features.isNotEmpty) {
        final properties = features[0]['properties'];
        dynamic durationValue;
        if (properties['segments'] != null &&
            (properties['segments'] as List).isNotEmpty) {
          durationValue = properties['segments'][0]['duration'];
        } else {
          durationValue = null;
          onEtaUpdated('ETA not available');
          return; // Exit if no segments found
        }

        if (durationValue != null) {
          double? durationInSeconds;
          if (durationValue is int) {
            durationInSeconds = durationValue.toDouble();
          } else if (durationValue is double) {
            durationInSeconds = durationValue;
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
            }
          } else {
            if (mounted) {
              onEtaUpdated('ETA not available');
            }
          }
        } else {
          if (mounted) {
            onEtaUpdated('ETA not available');
          }
        }
      } else {
        if (mounted) {
          onEtaUpdated('ETA not available');
        }
      }
    } else {
      if (mounted) {
        onEtaUpdated('Error calculating ETA');
      }
    }
  } catch (e) {
    if (mounted) {
      onEtaUpdated('Error calculating ETA');
    }
  }
}
