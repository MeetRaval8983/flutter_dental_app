import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_dental/View/admin/src/assign_doctor_screen.dart';
import 'package:new_dental/View/admin/src/admin_home.dart';
import 'package:new_dental/View/doctor/src/profile.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/View/admin/src/upload_data.dart';
import 'package:new_dental/services/permission_service.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});

  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
  int selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> pages =  [
    AdminHomeScreen(),
    StudentDataUploadScreen(),
    DoctorDataScreen(),
    // InstituteDataScreen(),
    ProfileViewDoctor(),
  ];

  // @override
  // void initState() async {
  //   super.initState();
  //   await PermissionService.requestAllPermissions();
    
  // }
    @override
  initState(){
    super.initState();
    permission();
  }
  void permission() async{
    _pageController = PageController();
    await PermissionService.requestAllPermissions();

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_14),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document_upload),
            label: "Upload Data",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.stethoscope),
            label: "Doctor",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(FontAwesomeIcons.institution),
          //   label: "Institute",
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
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
