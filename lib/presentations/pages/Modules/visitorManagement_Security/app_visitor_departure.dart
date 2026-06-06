// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVisitorDeparture extends StatefulWidget {
  const AppVisitorDeparture({super.key});

  @override
  State<AppVisitorDeparture> createState() => _AppVisitorDepartureState();
}

class _AppVisitorDepartureState extends State<AppVisitorDeparture> {
  int? emppk;
  String? empcode;
  int? companypk;
  int? deptpk;
  int? locationpk;
  String? empname;
  int isSuperAdmin = 0;
  List<dynamic> visitorDepartureData = [];

  @override
  void initState() {
    super.initState();
    _getPrefsData().then((_) => _fetchVisitorsDepartureList());
  }

  /// ----------------- Get Prefs Data ----------------------
  Future<void> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt("emppk");
    empcode = prefs.getString("employeecode");
    companypk = prefs.getInt("companypk");
    deptpk = prefs.getInt("deptpk");
    locationpk = prefs.getInt("locationpk");
    empname = prefs.getString("employeename");
    isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;
  }

  ///--------- fetch visitors departure data ----------------
  Future<void> _fetchVisitorsDepartureList() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.getVisitorDepartureData,
        data: {
          "report": {"AppointmentDate": "", "Name": ""},
        },
      );

      if (response.statusCode == 200) {
        if (response.data["GetDataVisitorDepa_ListResult"]["ErrorMessage"] !=
                "No data found" &&
            response.data["GetDataVisitorDepa_ListResult"]["IsError"] == false) {
          setState(() {
            visitorDepartureData = [];
          });
        } else {
          setState(() {
            visitorDepartureData =
                response.data["GetDataVisitorDepa_ListResult"]["Data"];
          });
        }
      } else {
        debugPrint(
          "Failed to fetch visitor departure data. Status code: ${response.statusCode}",
        );
      }
    } catch (ex) {
      debugPrint("Error fetching visitor departure data: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [_header(), Expanded(child: _listOfVisitorsDeparture())]),
    );
  }

  // HEADER
  Widget _header() {
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
            "Visitors Departure",
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  //------------------ List of Visitors Departure Widget ----------------------
  Widget _listOfVisitorsDeparture() {
    return visitorDepartureData.isEmpty
        ? Center(
            child: Text(
              "No visitor departure data found.",
              style: AppTextStyles.labelMedium,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visitorDepartureData.length,
            itemBuilder: (context, index) {
              final visitor = visitorDepartureData[index];
              return ListTile(
                title: Text(visitor["VisitorName"] ?? "Unknown Visitor"),
                subtitle: Text(
                  "Departure Time: ${visitor["DepartureTime"] ?? "N/A"}",
                ),
              );
            },
          );
  }
}
