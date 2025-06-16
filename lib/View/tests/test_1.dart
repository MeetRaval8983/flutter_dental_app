import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/Widgets/card_user_profile.dart';
import 'package:new_dental/View/Widgets/image_pick_view.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/test/test_1_controller.dart';

class UploadTeethImagePagewifi extends StatefulWidget {
  final Map<String, dynamic> studentInfo;

  const UploadTeethImagePagewifi({super.key, required this.studentInfo});

  @override
  _UploadTeethImagePagewifiState createState() =>
      _UploadTeethImagePagewifiState();
}

class _UploadTeethImagePagewifiState extends State<UploadTeethImagePagewifi>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestOneController>(
      init: TestOneController(), // Initialize controller
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Upload Teeth Images'),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            // Wrap body in SingleChildScrollView to avoid overflow
            child: Column(
              children: [
                _buildContent(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
                controller.uploadImagesController(widget.studentInfo);
            },
            backgroundColor: cerulean,
            child: const Icon(Icons.done, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 30),
          UserProfileWidget(studentInfo: widget.studentInfo),
          SizedBox(height: 30),

          Text(
            'Step 1: Upload Teeth Images',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: cerulean),
          ),
          SizedBox(height: 30),
          _buildTabBar(),
          // Wrap TabBarView with Expanded to ensure layout constraints
          SizedBox(
            // Use Container to provide explicit height to TabBarView
            height: 400, // Set a height to avoid unbounded height issues
            child: _buildTabViews(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        indicatorColor: cerulean, // Change indicator color
        labelStyle: TextStyle(
          fontSize: 18, // Font size for the selected tab
          fontWeight: FontWeight.bold, // Bold font weight for the selected tab
          letterSpacing: 1, // Optional: Adds some space between letters
        ),
        unselectedLabelColor:
            cerulean.withOpacity(0.8), // Color for unselected tabs
        unselectedLabelStyle: TextStyle(
          fontSize: 14, // Font size for unselected tabs
          fontWeight: FontWeight.bold, // Normal font weight for unselected tabs
        ),
        indicatorWeight: 5.0, // Thickness of the indicator line
        // indicatorPadding: EdgeInsets.symmetric(horizontal: 20), // Padding around the indicator
        tabs: [
          Tab(
            text: "Front",
          ),
          Tab(
            text: "Upper",
          ),
          Tab(
            text: "Lower",
          ),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [
        ImagePickerView(
          label: 'Front',
        ),
        ImagePickerView(
          label: 'Upper',
        ),
        ImagePickerView(
          label: 'Lower',
        ),
      ],
    );
  }
}
