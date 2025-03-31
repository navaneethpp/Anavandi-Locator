import 'package:flutter/material.dart';
import 'package:anavandi_locator/presentation/screens/about_page.dart';
import 'package:anavandi_locator/presentation/screens/home_content.dart';
import 'package:anavandi_locator/presentation/screens/home/home_submit_handler.dart';
import 'package:anavandi_locator/data/models/bus_route.dart'; // Import the model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _textField1Controller = TextEditingController();
  final TextEditingController _textField2Controller = TextEditingController();
  final GlobalKey<HomeContentState> _homeContentKey =
      GlobalKey<HomeContentState>(); // Using the public HomeContentState

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleRouteFound(List<BusRoute> route) {
    // This callback will be passed to HomeContent
    _homeContentKey.currentState?.updateRoute(
      route,
    ); // Access the state using the GlobalKey
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ), // Adjust the duration as needed
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                _selectedIndex == 0
                    ? const Text(
                      'Anavandi Locator',
                      key: ValueKey<int>(0),
                    ) // Key for Home title
                    : const SizedBox.shrink(
                      key: ValueKey<int>(1),
                    ), // Key for About (no title)
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: <Widget>[
            HomeContent(
              key: _homeContentKey, // Assign the GlobalKey to HomeContent
              startPointController: _textField1Controller,
              destinationController: _textField2Controller,
              onRouteFound: _handleRouteFound, // Pass the callback
              onSubmit: () {
                HomeSubmitHandler.handleSubmit(
                  context,
                  _textField1Controller,
                  _textField2Controller,
                  _handleRouteFound, // Pass the callback to handleSubmit
                );
              },
            ),
            const AboutPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
