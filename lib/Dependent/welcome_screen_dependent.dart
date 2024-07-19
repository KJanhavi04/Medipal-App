import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen_dependent.dart';
import 'package:medipal/user_registration/enter_otp_dependent_screen.dart';

class WelcomeScreenDependent extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  WelcomeScreenDependent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient with Waves and Curves
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                (MediaQuery.of(context).size.height * 0.65).clamp(0, 300)),
            painter: BackgroundPainter(),
          ),

          // Medipal Circular Image (Position it at the very top)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.3,
            child: Image.asset(
              'assets/images/medipal.png',
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.35,
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            left: MediaQuery.of(context).size.width * 0.41,
            child: Text(
              'MediPal',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.055,
                color: const Color.fromARGB(255, 36, 40, 81),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Quote Text at the Left Side
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            left: MediaQuery.of(context).size.width * 0.20,
            child: Text(
              'Your medicine, our responsibility!',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.042,
                color: const Color.fromARGB(255, 41, 45, 92),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32.0),
                  const SizedBox(height: 32.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(182, 255, 255, 255)
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: _buildInputField(
                        Icons.person_2_sharp, 'Name', _nameController),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(182, 255, 255, 255)
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: _buildPhoneNoField(
                        Icons.phone_iphone, 'Phone Number', _phoneController),
                  ),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 120.0),
                  Container(
                    child: _buildSignInButton(
                        context, _phoneController.text, _nameController.text),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, String number, String name) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return _buildLoadingIndicator();
            },
          );
          verify(context, number, name);
        },
        style: ElevatedButton.styleFrom(
          //check this ui
          primary: const Color.fromARGB(255, 41, 45, 92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void verify(BuildContext context, String phoneNumber, String name) async {
    await auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPForDependentPage(
                      verificationId: verificationId,
                      name: name,
                      phoneNo: phoneNumber)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  Widget _buildInputField(
      IconData icon, String hintText, TextEditingController nameController) {
    return TextField(
      style: const TextStyle(color: Color.fromARGB(255, 41, 45, 92)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 41, 45, 92)),
        prefixIcon: Icon(
          icon,
          color: const Color.fromARGB(218, 41, 45, 92),
        ),
        border: InputBorder.none,
      ),
      controller: nameController,
    );
  }

  Widget _buildPhoneNoField(
      IconData icon, String hintText, TextEditingController phoneController) {
    return TextField(
      style: const TextStyle(color: Color.fromARGB(255, 41, 45, 92)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 41, 45, 92)),
        prefixIcon: Icon(icon, color: const Color.fromARGB(218, 41, 45, 92)),
        border: InputBorder.none,
      ),
      controller: phoneController,
      keyboardType: TextInputType.number, // Only allow numeric input
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint();

    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.9,
        size.width * 0.8, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.65, size.height * 0.9, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);

    paint.color = const Color.fromARGB(255, 202, 222, 255);
    paint.style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Widget _buildLoadingIndicator() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromARGB(255, 150, 161, 170),
          ),
        ),
      ],
    ),
  );
}
