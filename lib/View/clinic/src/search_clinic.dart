import 'package:flutter/material.dart';
import 'package:new_dental/controller/clinic/clinic_home_controlle.dart';

class ClinicSearchDelegate extends SearchDelegate<String> {
  final ClinicHomeController controller;
  final Function(Map<String, dynamic>) onPatientSelected;

  ClinicSearchDelegate({required this.controller, required this.onPatientSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.grey),
        onPressed: () {
          query = '';
          controller.onSearchChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredPatients = controller.filteredPatients;
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = filteredPatients[index];
        return _buildPatientTile(patient);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredSuggestions = controller.patients.where((patient) {
      return patient['full_name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final patient = filteredSuggestions[index];
        return _buildPatientTile(patient);
      },
    );
  }

  Widget _buildPatientTile(Map<String, dynamic> patient) {
    return InkWell(
      onTap: () {
        onPatientSelected(patient);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['full_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    patient['email'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  TextStyle? get searchFieldStyle => TextStyle(color: Colors.white);

  @override
  InputDecorationTheme get searchFieldDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.8),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
