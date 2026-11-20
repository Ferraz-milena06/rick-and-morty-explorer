import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  await appProvider.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const RickMortyApp(),
    ),
  );
}

class RickMortyApp extends StatelessWidget {
  const RickMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF76C442),
          brightness: Brightness.dark,
          surface: const Color(0xFF171B25),
        ),
        scaffoldBackgroundColor: const Color(0xFF10141D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171B25),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF202735),
          clipBehavior: Clip.antiAlias,
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF202735),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: Consumer<AppProvider>(
        builder: (context, app, _) {
          if (!app.isLoggedIn) return const LoginScreen();
          return const HomeScreen();
        },
      ),
    );
  }
}
