import 'package:flutter/material.dart';
import 'package:medipal/Individual/appoin_details_screen.dart';
import 'package:medipal/Individual/dashboard_screen.dart';
import 'package:medipal/Individual/inventory_screen.dart';
import 'package:medipal/Individual/profile_screen.dart';

class BottomNavigationIndividual extends StatefulWidget {
  const BottomNavigationIndividual({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationIndividual> {
  int _selectedIndex = 0; // Current selected tab index
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    _pageController.animateToPage(
      0, // Index of the Dashboard tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _navigateToInventory() {
    _pageController.animateToPage(
      1, // Index of the Inventory tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _navigateToAppDetails() {
    _pageController.animateToPage(
      2, // Index of the Dashboard tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _navigateToProfile() {
    _pageController.animateToPage(
      3, // Index of the Profile tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button when on the first page
        if (_selectedIndex == 0) {
          return false;
        }
        // Handle navigation when on other pages
        _navigateToDashboard();
        return true;
      },
      child: Scaffold(
        appBar: null, // Set the AppBar to null to hide it
        body: PageView(
          controller: _pageController,
          children:  const <Widget>[
            DashboardScreen(),
            InventoryScreen(),
            AppointmentScreen(),
            ProfileScreen(),
          ],
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_rounded),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Appoinmnent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_rounded),
              label: 'Profile',
            ),
          ],
          unselectedItemColor: const Color.fromARGB(146, 170, 149, 247),
          //unselectedItemColor: Color.fromARGB(255, 154, 17, 17),
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 41, 45, 92),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 0:
                _navigateToDashboard();
                break;
              case 1:
                _navigateToInventory();
                break;
              case 2:
                _navigateToAppDetails();
                break;
              case 3:
                _navigateToProfile();
                break;
            }
          },
        ),
      ),
    );
  }
}
