import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Nav.dart';
import 'login_screen.dart';
import 'onboarding_view.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  User? currentUser;

  if (isLoggedIn) {
    int userId = prefs.getInt('userId') ?? 0;
    String userName = prefs.getString('userName') ?? '';
    String userEmail = prefs.getString('userEmail') ?? '';

    currentUser = User(
      id: userId,
      name: userName,
      email: userEmail,
      password: '',
    );
  }

  Widget startScreen;

  if (!seenOnboarding) {
    startScreen = const OnboardingView();
  } else if (isLoggedIn && currentUser != null) {
    startScreen = NavView(currentUser: currentUser);
  } else {
    startScreen = const LoginScreen();
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: startScreen);
  }
}
