import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafraq_cpf_project_v1/ProgressPage.dart';
import 'package:mafraq_cpf_project_v1/homePage.dart';
import 'package:mafraq_cpf_project_v1/profilepage.dart';
import 'package:mafraq_cpf_project_v1/workoutPage.dart';
import 'package:mafraq_cpf_project_v1/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aboutAppPage.dart';
import 'login_screen.dart';

class NavView extends StatefulWidget {
  final User currentUser;

  const NavView({super.key, required this.currentUser});

  @override
  State<NavView> createState() => _NavViewState();
}

class _NavViewState extends State<NavView> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(),
      ExercisesPage(),
      Progresspage(currentUser: widget.currentUser),
    ];
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF288a52),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Peak Physique",
              style: GoogleFonts.oswald(fontSize: 26, color: Colors.white),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.currentUser.name),
              accountEmail: Text(widget.currentUser.email),
              currentAccountPicture: CircleAvatar(
                child: Text(widget.currentUser.name[0]),
              ),
              decoration: const BoxDecoration(color: Color(0xFF288a52)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(currentUser: widget.currentUser),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About App'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF288a52),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Progress",
          ),
        ],
      ),
    );
  }
}
