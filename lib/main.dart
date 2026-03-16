import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/category_provider.dart';
import 'screens/main_nav_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Primary provider — manages recipe list & state
        ChangeNotifierProvider(create: (_) => RecipeProvider()),

        // Stats provider — auto-reloads whenever RecipeProvider notifies
        ChangeNotifierProxyProvider<RecipeProvider, StatsProvider>(
          create: (_) => StatsProvider(),
          update: (_, recipeProvider, statsProvider) {
            statsProvider!.loadStats();
            return statsProvider;
          },
        ),

        // Category provider — manages category list
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Food Recipe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8523A),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE8523A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8523A),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const MainNavScreen(),
      ),
    );
  }
}
