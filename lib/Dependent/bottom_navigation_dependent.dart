import 'package:flutter/material.dart';
import 'package:medipal/Dependent/appoin_details_dependent_screen.dart';
import 'package:medipal/Dependent/dashboard_screen_dependent.dart';
import 'package:medipal/Dependent/inventory_screen_dependent.dart';
import 'package:medipal/Dependent/profile_screen_dependent.dart';

class BottomNavigationDependent extends StatefulWidget {
  const BottomNavigationDependent({Key? key}) : super(key: key);

  @override
  _BottomNavigationDependentState createState() =>
      _BottomNavigationDependentState();
}

class _BottomNavigationDependentState extends State<BottomNavigationDependent> {
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
  // Function to navigate to the Inventory page
  void _navigateToInventory() {
    _pageController.animateToPage(
      1, // Index of the Inventory tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _navigateToAppDetails() {
    _pageController.animateToPage(
      2, // Index of the Profile tab
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          DashboardScreenDependent(),
          InventoryDependent(),
          AppointmentDependentScreen(),
          ProfileScreenDependent(),

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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Appoinmnent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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
    );
  }
}
