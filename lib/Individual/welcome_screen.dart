import 'package:flutter/material.dart';
import 'package:medipal/Individual/login_screen.dart';
import 'package:medipal/Individual/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 223, 238, 255),
                  Color.fromARGB(214, 152, 191, 255),
                  Color.fromARGB(255, 223, 238, 255),
                ],
              ),
            ),
          ),
          // Medipal Circular Image (Position it at the very top)
          Positioned(
            top: 0.15 * MediaQuery.of(context).size.height,
            left: 0.34 * MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/medipal.png', // Replace with your image path
              width: 0.35 * MediaQuery.of(context).size.width,
              height: 0.40 * MediaQuery.of(context).size.width,
            ),
          ),
          // Back Button
          Positioned(
            top: 0.04 * MediaQuery.of(context).size.height,
            left: 0.034 * MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                // Transparent white background
                shape: BoxShape.circle, // Circular shape
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Navigate back to the previous screen
                },
              ),
            ),
          ),
          Positioned(
            left: 0.38 * MediaQuery.of(context).size.width,
            top: 0.35 * MediaQuery.of(context).size.height,
            child: Text(
              'MediPal',
              style: TextStyle(
                fontSize: 0.07 * MediaQuery.of(context).size.width,
                color: const Color.fromARGB(255, 41, 45, 92),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Quote Text at the Left Side
          Positioned(
            left: 0.20 * MediaQuery.of(context).size.width,
            top: 0.40 * MediaQuery.of(context).size.height,
            child: Text(
              'Your medicine, our responsibility!',
              style: TextStyle(
                fontSize: 0.043 * MediaQuery.of(context).size.width,
                color: const Color.fromARGB(255, 41, 45, 92),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Sign In Button (Transparent with Border)
          Positioned(
            left: 0.03 * MediaQuery.of(context).size.width,
            right: 0.03 * MediaQuery.of(context).size.width,
            bottom: 0.25 * MediaQuery.of(context).size.height,
            child: SizedBox(
              height: 0.065 * MediaQuery.of(context).size.height,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 234, 244, 255),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 41, 45, 92), width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      0.03 * MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
          // Create Account Button (Transparent without Border)
          Positioned(
            left: 0.03 * MediaQuery.of(context).size.width,
            right: 0.03 * MediaQuery.of(context).size.width,
            bottom: 0.15 * MediaQuery.of(context).size.height,
            child: SizedBox(
              height: 0.065 * MediaQuery.of(context).size.height,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(103, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      0.03 * MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                child: const Text(
                  'Create an Account',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
