import 'package:flutter/material.dart';
import 'package:new_dental/View/clinic/src/clinic_home.dart';
import 'package:new_dental/View/doctor/src/profile.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/services/permission_service.dart';

class ClinicNav extends StatefulWidget {
  const ClinicNav({super.key});

  @override
  State<ClinicNav> createState() => _MainPageState();
}

class _MainPageState extends State<ClinicNav> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> pages = [
    ClinicHomeScreen(),
    ProfileViewDoctor(),
  ];
  
  @override
  initState(){
    super.initState();
    permission();
  }
  void permission() async{
    await PermissionService.requestAllPermissions();

  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut, // Smooth sliding effect
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black26,
        selectedItemColor: purple,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onTabTapped, // Call the function when tapped
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home5),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: pages,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
