// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusOfVisitorScreen extends StatefulWidget {
  const StatusOfVisitorScreen({super.key});

  @override
  State<StatusOfVisitorScreen> createState() => _StatusOfVisitorScreenState();
}

class _StatusOfVisitorScreenState extends State<StatusOfVisitorScreen> {
  int? emppk;
  String? employeeCode;
  String? employeename;

  final TextEditingController searchController = TextEditingController();

  List<dynamic> visitorStatusData = [];

  // Filtered List for Search
  List<dynamic> filteredVisitorStatusData = [];

  // Theme management
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // INIT
  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _fetchVisitorStatusData());
  }

  // Load User data from Prefs
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    employeeCode = prefs.getString('employeecode') ?? '';
    emppk = prefs.getInt('emppk');
  }

  /// Fetch visitor application status data
  Future<void> _fetchVisitorStatusData() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.getStatusOfVisitor,
        data: {
          "report": {"AppointmentDate": "", "Name": employeename},
        },
      );

      if (response.statusCode == 200) {
        final result =
            response.data["GetStatusOfVisitorDataResult"]["ErrorMessage"];

        debugPrint("Status of Visitor API Response: $result");

        if (result.toString().contains("No data found")) {
          debugPrint("No data found for the visitor application status.");
        } else if (response.data["GetStatusOfVisitorDataResult"]["Data"] !=
            null) {
          final data = response.data["GetStatusOfVisitorDataResult"]["Data"];

          debugPrint("Fetched Visitor Application Status Data: $data");

          setState(() {
            visitorStatusData = data;
            filteredVisitorStatusData = data;
          });
        }
      }
    } catch (ex) {
      debugPrint("Error fetching the status of visitor application: $ex");
    }
  }

  /// Search Visitor by Name
  void _searchVisitor(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredVisitorStatusData = visitorStatusData;
      } else {
        filteredVisitorStatusData = visitorStatusData.where((visitor) {
          final name = visitor["Name"]?.toString().toLowerCase() ?? "";

          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        children: [
          header(),
          searchVisitors(),
          listOfStatusOfVisitorApplications(),
        ],
      ),
    );
  }

  // HEADER
  Widget header() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 57, 147, 182),
            Color.fromARGB(255, 16, 69, 90),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AppVisitorManagement(),
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          Text(
            "Status Of Visitor",
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Search Visitors Widget
  Widget searchVisitors() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by visitor name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Live Search
              onChanged: (value) {
                _searchVisitor(value);
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: CommonButton(
              width: 70,
              height: 40,
              color: !isDark
                  ? const Color.fromARGB(255, 88, 161, 221)
                  : const Color.fromARGB(255, 9, 73, 126),
              label: 'Search Visitor',

              // Button Search
              onPressed: () {
                _searchVisitor(searchController.text);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// List Of Status Of Visitor Applications
  Widget listOfStatusOfVisitorApplications() {
    return Expanded(
      child: filteredVisitorStatusData.isEmpty
          ? const Center(
              child: Text(
                "No visitor application status data available.",
                style: AppTextStyles.labelMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredVisitorStatusData.length,
              itemBuilder: (context, index) {
                final visitorStatus = filteredVisitorStatusData[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        visitorStatus["Name"] != null
                            ? visitorStatus["Name"][0]
                            : "U",
                        style: AppTextStyles.headingSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      visitorStatus["Name"] ?? "Unknown Visitor",
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        Text(
                          "Status: ${visitorStatus["Statusofmetting"] ?? "Unknown Status"}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Visitor Code: ${visitorStatus["VisitorCode"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "In Time: ${visitorStatus["AppointmetInTime"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Out Time: ${visitorStatus["AppointmentOutTime"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
