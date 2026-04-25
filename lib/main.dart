import 'package:flutter/material.dart';
import 'core/app_config.dart';
import 'screens/restaurant_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppConfig.create(
      child: MaterialApp(
        title: 'Restaurant Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        themeMode: ThemeMode.system,
        home: const RestaurantListScreen(),
      ),
    );
  }
}
