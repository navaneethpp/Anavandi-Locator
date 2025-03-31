import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:anavandi_locator/presentation/screens/bus_route_map_screen.dart';
import 'package:anavandi_locator/presentation/screens/route_details_screen.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';
import 'package:anavandi_locator/services/bus_route_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class BusRouteContainerScreen extends StatefulWidget {
  final String busRegistrationNumber;
  final String tripId;

  const BusRouteContainerScreen({
    super.key,
    required this.busRegistrationNumber,
    required this.tripId,
  });

  @override
  State<BusRouteContainerScreen> createState() =>
      _BusRouteContainerScreenState();
}

class _BusRouteContainerScreenState extends State<BusRouteContainerScreen> {
  int _selectedIndex = 0;
  Bus? _bus;
  List<Map<String, dynamic>> _stopsData = [];
  String? _startPoint;
  String? _destinationPoint;

  // GlobalKey to access the state of the child screens
  final GlobalKey<BusRouteMapScreenState> _mapScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _bus = await BusRouteService.fetchBusLocation(widget.busRegistrationNumber);
    final fetchedStopsData = await BusRouteService.fetchBusStopsData(
      widget.tripId,
    );
    final assignDataSnapshot =
        await FirebaseFirestore.instance
            .collection('assignData')
            .where('tripId', isEqualTo: widget.tripId)
            .limit(1)
            .get();

    if (mounted) {
      setState(() {
        _stopsData = fetchedStopsData ?? [];
        if (assignDataSnapshot.docs.isNotEmpty) {
          final assignData = assignDataSnapshot.docs.first.data();
          _startPoint = assignData['startingPoint']?.toString();
          _destinationPoint = assignData['endingPoint']?.toString();
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleRefresh() {
    if (_selectedIndex == 0) {
      _mapScreenKey.currentState?.resetStateAndInitialize();
    } else if (_selectedIndex == 1) {
      // For RouteDetailsScreen, we can simply re-fetch the data
      _fetchInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      BusRouteMapScreen(
        key: _mapScreenKey,
        busRegistrationNumber: widget.busRegistrationNumber,
        tripId: widget.tripId,
      ),
      RouteDetailsScreen(
        stopsData: _stopsData,
        startPoint: _startPoint ?? '',
        destinationPoint: _destinationPoint ?? '',
        initialBusLocation: _bus?.location,
        busLocationStream: Stream.periodic(const Duration(seconds: 5), (
          _,
        ) async {
          final fetchedBus = await BusRouteService.fetchBusLocation(
            widget.busRegistrationNumber,
          );
          return fetchedBus?.location;
        }).asyncMap((event) async => await event).takeWhile((value) => mounted),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _startPoint != null && _destinationPoint != null
                  ? '$_startPoint - $_destinationPoint'
                  : 'Route Not Available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(widget.busRegistrationNumber, style: TextStyle(fontSize: 14)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: SlidingClippedNavBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          onButtonPressed: (index) => _onItemTapped(index),
          activeColor: Colors.blue,
          selectedIndex: _selectedIndex,
          barItems: <BarItem>[
            BarItem(icon: Icons.map, title: 'Map'),
            BarItem(icon: Icons.list, title: 'Stops'),
          ],
        ),
      ),
    );
  }
}
