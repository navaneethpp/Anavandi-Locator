// favorite_page.dart

import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // List of favorite routes
  List<String> favoriteRoutes = [
    'Route 1 - City Center to Uptown',
    'Route 2 - Downtown to Suburbs',
    'Route 3 - Eastside to Westside',
  ];

  // Function to remove a route from the favorites list
  void _removeFromFavorites(String route) {
    setState(() {
      favoriteRoutes.remove(route); // Remove the route from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Favorites',
              style: TextStyle(color: Colors.white),
            ),
            Image.asset(
              'assets/logo_white.png', // Replace with the actual path to your logo
              width: 100, // Adjust size as needed
              height: 40,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: ListView.builder(
                    itemCount: favoriteRoutes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading:
                              const Icon(Icons.favorite, color: Colors.red),
                          title: Text(favoriteRoutes[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            onPressed: () {
                              // Remove the route from favorites
                              _removeFromFavorites(favoriteRoutes[index]);
                            },
                          ),
                          onTap: () {
                            // Navigate to details or map view for selected route
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
