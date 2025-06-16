import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/profile_controller.dart';

class ProfileViewDoctor extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: scienceBlue)),
        centerTitle: true,
        // elevation: 4,
        backgroundColor: Colors.grey[100],
      ),
      body: SafeArea(
        child: Obx(() => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: controller.uploadImage,
                        child: Stack(
                          children: [
                            Obx(() => CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.white,
                                  backgroundImage: controller
                                          .profileImageUrl.value.isNotEmpty
                                      ? NetworkImage(
                                          controller.profileImageUrl.value)
                                      : AssetImage(ImageConstant.logo)
                                          as ImageProvider,
                                )),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.camera_alt,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildInfoCard(),
                    SizedBox(height: 24),
                    if (controller.userType.value == "doctor")
                      _buildStatsCard(),
                    // _buildStatsCard(),
                    SizedBox(height: 24),
                    _buildLogoutButton(),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      title: 'Personal Information',
      children: [
        Obx(() => _buildInfoRow('Name', controller.userName.value)),
        Obx(() => _buildInfoRow('Email', controller.userEmail.value)),
        if (controller.userType.value == "doctor" ||
            controller.userType.value == "clinic")
          Obx(() => _buildInfoRow(
              'Registration ID', controller.registrationId.value)),
        if (controller.userType.value == "doctor")
          Obx(() => _buildInfoRow('Institute', controller.instituteName.value)),
      ],
    );
  }

  Widget _buildStatsCard() {
    return _buildCard(
      title: 'Statistics',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Total Students',
                controller.totalStudents.toString(), Colors.blue),
            SizedBox(width: 12),
            _buildStatCard('Completed Tests',
                controller.completedTests.toString(), Colors.green),
            SizedBox(width: 12),
            _buildStatCard('Pending Tests',
                controller.remainingTests.toString(), Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: Icon(Icons.logout, color: Colors.red),
        label: Text('Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black54, fontSize: 16)),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: Text(
              value.isNotEmpty ? value : "Loading...",
              key: ValueKey<String>(value),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
