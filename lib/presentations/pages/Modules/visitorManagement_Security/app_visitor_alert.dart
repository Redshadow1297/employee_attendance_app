// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVisitorAlertScreen extends StatefulWidget {
  const AppVisitorAlertScreen({super.key});

  @override
  State<AppVisitorAlertScreen> createState() => _AppVisitorAlertScreenState();
}

class _AppVisitorAlertScreenState extends State<AppVisitorAlertScreen> {
  int? emppk;
  String? empcode;
  int? companypk;
  int? deptpk;
  int? locationpk;
  String? empname;
  int? isSuperAdmin;
  List<dynamic> visitorAlerts = [];
  bool isLoading = false;

  //fetch Preference data
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

  //Get Data alert Visitor API call
  Future<void> _fetchVisitorAlerts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiClient.post(
        ApiConstants.getDataAlertVisitor,
        data: {"Emp_pk": emppk.toString(), "Flag": "A"},
      );

      if (response.statusCode == 200) {
        final result = response.data["GetDataApproval_VisitorResult"];

        if (result != null) {
          final bool isError = result["IsError"] ?? false;

          if (isError) {
            debugPrint("Visitor Alert Error: ${result["ErrorMessage"]}");

            setState(() {
              visitorAlerts = [];
            });
          } else {
            debugPrint("Visitor Alert Data: ${result["Data"]}");

            setState(() {
              visitorAlerts = List<dynamic>.from(result["Data"] ?? []);
            });
          }
        } else {
          debugPrint("Invalid response structure");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (ex) {
      debugPrint("Error fetching visitor alerts: $ex");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //init
  @override
  void initState() {
    super.initState();
    _getPrefsData().then((_) => _fetchVisitorAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          header(isDark),
          Expanded(child: _visitorAlertList(isDark)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //header
  Widget header(bool isDark) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        // color: Colors.red,
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
             Navigator.pop(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            "Visitor Alert",
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  //Visitor Alert List
  Widget _visitorAlertList(bool isDark) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visitorAlerts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No Visitor Alerts Found",
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: visitorAlerts.length,

        itemBuilder: (context, index) {
          final item = visitorAlerts[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),

              title: Text(item["VisitorName"] ?? "Unknown"),

              subtitle: Text(item["VisitDate"] ?? ""),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {}, //Handle the details of the visitor if want to see
            ),
          );
        },
      ),
    );
  }
}
