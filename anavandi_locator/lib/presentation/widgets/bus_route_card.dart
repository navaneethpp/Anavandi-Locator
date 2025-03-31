import 'package:flutter/material.dart';
import 'package:anavandi_locator/presentation/screens/bus_route_container_screen.dart'; // Import the new container screen
import 'package:anavandi_locator/data/models/bus_route.dart';
import 'package:anavandi_locator/utils/string_extensions.dart';

class BusRouteCard extends StatelessWidget {
  final BusRoute route;

  const BusRouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    print("Hello tripId : ${route.tripId}");
    return InkWell(
      // Wrap the Card with InkWell for tap functionality
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BusRouteContainerScreen(
                  // Navigate to BusRouteContainerScreen
                  tripId: route.tripId,
                  busRegistrationNumber: route.busRegistrationNumber,
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${route.startingPoint.capitalize()} - ${route.endingPoint.capitalize()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(route.busType),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(route.busRegistrationNumber),
                  Text('${route.startingTime} - ${route.endingTime}'),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Stops: ',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              route.busStops.length <= 3
                  ? Text(
                    route.busStops.map((stop) => stop.stopName).join(' -> '),
                  )
                  : Text(
                    '${route.busStops.first.stopName.capitalize()} -> ... (${route.busStops.length - 2} stops) ... -> ${route.busStops.last.stopName.capitalize()}',
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
