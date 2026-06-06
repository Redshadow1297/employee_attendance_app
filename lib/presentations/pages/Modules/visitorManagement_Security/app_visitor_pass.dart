// ignore_for_file: unrelated_type_equality_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_management.dart';

class AppVisitorsPassScreen extends StatefulWidget {
  const AppVisitorsPassScreen({super.key});

  @override
  State<AppVisitorsPassScreen> createState() => _AppVisitorsPassScreenState();
}

class _AppVisitorsPassScreenState extends State<AppVisitorsPassScreen> {
  List<dynamic> visitorsPassData = [];
  List<dynamic> filteredVisitorsPassData = [];
  TextEditingController searchController = TextEditingController();
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  //--------------FETCH VISITORS PASS DATA ------------------
  Future<void> _fetchVisitorsPass() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.getVisitorPass,
        data: {"report": {}},
      );

      if (response.statusCode == 200) {
        final result = response.data["GetListVisitorPassDataResult"]["Data"];

        if (result != null) {
          final now = DateTime.now();

          final pastVisitors = result.where((visitor) {
            final dateString = visitor["AppointmentDate"]?.toString();

            if (dateString == null || dateString.isEmpty) {
              return false;
            }

            try {
              final appointmentDate = DateFormat(
                "dd/MM/yyyy",
              ).parse(dateString);

              return appointmentDate.isBefore(now);
            } catch (e) {
              debugPrint("Date parse error: $e");
              return false;
            }
          }).toList();

          setState(() {
            visitorsPassData = pastVisitors;
            // filteredVisitorsPassData = pastVisitors;
          });
        }
      }
    } catch (ex) {
      debugPrint("Error fetching visitor pass data: $ex");
    }
  }

  /// Search Visitor Pass by name
  // void _searchVisitorPass(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       // filteredVisitorsPassData = visitorsPassData;
  //     } else {
  //       filteredVisitorsPassData = visitorsPassData.where((visitor) {
  //         final name = visitor["Name"]?.toString().toLowerCase() ?? "";
  //         return name.contains(query.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }

  //INIT
  @override
  void initState() {
    super.initState();
    _fetchVisitorsPass();
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(), 
        // searchVisitors(), 
        _listOfVisitorsPass()],
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
            "Visitors Pass",
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Widget searchVisitors() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: TextField(
  //             controller: searchController,
  //             decoration: InputDecoration(
  //               hintText: "Search by visitor name",
  //               prefixIcon: const Icon(Icons.search),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             // Live Search
  //             onChanged: (value) {
  //               // _searchVisitorPass(value);
  //             },
  //           ),
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: CommonButton(
  //             width: 70,
  //             height: 40,
  //             color: !isDark
  //                 ? const Color.fromARGB(255, 88, 161, 221)
  //                 : const Color.fromARGB(255, 9, 73, 126),
  //             label: 'Search Visitor',
  //             // Button Search
  //             onPressed: () {
  //               // _searchVisitorPass(searchController.text);
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  ///----------------- Visitor Pass List ------------------
  Widget _listOfVisitorsPass() {
    if (visitorsPassData.isEmpty) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: visitorsPassData.length,
        itemBuilder: (context, index) {
          final visitorPass = visitorsPassData[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          visitorPass["Name"] ?? "",
                          style: AppTextStyles.headingSmall,
                        ),

                        Text(
                          "Date : ${visitorPass["AppointmentDate"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Time : ${visitorPass["AppointmetInTime"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Organization : ${visitorPass["Organize"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Appointment ID : ${visitorPass["AppointmentID"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Status : ${visitorPass["Statusofmetting"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),

                        Text(
                          "Purpose : ${visitorPass["purpose"] ?? ""}",
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
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
