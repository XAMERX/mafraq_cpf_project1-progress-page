import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF288a52);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: const Text(
          "About the App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icon/iconLuncher.png', height: 100),
            const SizedBox(height: 12),
            const Text(
              "Peak Physique",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "A simple gym application that helps users track workouts, steps, and fitness goals easily and effectively.",
              style: TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About the Project",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This application was developed as part of a Flutter training course "
                    "provided by Orange. The project focuses on applying essential concepts "
                    "in mobile app design, state management, and API integration.",
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Developers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Amer Mohammad Shdifat\n• Abdallah Marwan Abo Olim",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 15),
            const Text(
              "Contact",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "📧 amershdifat22@gmail.com\n📧 momabdalla66@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              "GitHub",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "🔗 https://github.com/XAMERX\n🔗 https://github.com/Abdallah-Abu-Oliam",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 25),

            Image.asset('assets/images/orange.png', height: 70),
            const SizedBox(height: 10),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text("Version: 1.0.0", style: TextStyle(fontSize: 14)),
                  Text("Developed in 2025", style: TextStyle(fontSize: 14)),
                  Text(
                    "Built with Flutter & Dart",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Training provided by Orange",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
