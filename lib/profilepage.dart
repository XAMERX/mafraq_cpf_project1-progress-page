import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafraq_cpf_project_v1/user.dart';
import 'package:mafraq_cpf_project_v1/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  final User currentUser;

  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DbHelper dbHelper;
  int steps = 0;
  double distance = 0;
  double calories = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    _loadSteps();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _loadSteps() async {
    setState(() => isLoading = true);
    int currentSteps = await dbHelper.getSteps(widget.currentUser.id);
    setState(() {
      steps = currentSteps;
      distance = (steps * 0.762) / 1000;
      calories = steps * 0.04;
      isLoading = false;
    });
  }

  Widget _buildInfoCard(String label, String value, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF288a52)),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.oswald(fontSize: 18, color: Colors.black87),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.oswald(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Profile",
          style: GoogleFonts.oswald(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF288a52),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSteps,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF288a52),
                    child: Text(
                      widget.currentUser.name[0].toUpperCase(),
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.currentUser.name,
                          style: GoogleFonts.oswald(
                            fontSize: 26,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.currentUser.email,
                          style: GoogleFonts.openSans(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    "Steps",
                    "$steps steps",
                    icon: Icons.directions_walk,
                  ),
                  _buildInfoCard(
                    "Distance",
                    "${distance.toStringAsFixed(2)} km",
                    icon: Icons.map,
                  ),
                  _buildInfoCard(
                    "Calories",
                    "${calories.toStringAsFixed(2)} kcal",
                    icon: Icons.local_fire_department,
                  ),
                  _buildInfoCard(
                    "Email",
                    widget.currentUser.email,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _logout();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
