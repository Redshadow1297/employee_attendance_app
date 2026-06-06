// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
import 'package:new_design_demo/presentations/common_widgets/common_datePicker.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVisitorRegisterScreen extends StatefulWidget {
  const AppVisitorRegisterScreen({super.key});

  @override
  State<AppVisitorRegisterScreen> createState() =>
      _AppVisitorRegisterScreenState();
}

class _AppVisitorRegisterScreenState extends State<AppVisitorRegisterScreen> {
  int? emppk;
  String? empcode;
  int? companypk;
  int? deptpk;
  int? locationpk;
  String? empname;
  int isSuperAdmin = 0;
  List<dynamic> visitorRegisterData = [];
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getPrefsData();

    if (!mounted) return;

    await fetchVisitorRegisterData();
  }

  //fetch prefs Data
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

  //Fetch visitor register data
  Future<void> fetchVisitorRegisterData() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.getVisitorRegisterData,
        data: {
          'report': {
            "Fromdate": _fromDateController.text,
            "Todate": _toDateController.text,
            "DeptPk": deptpk ?? 0,
            "Name": "",
          },
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (response.data["Display_VisitorRegisterDataResult"]["IsError"] ==
                false &&
            response.data["Display_VisitorRegisterDataResult"]["Data"] !=
                null) {
          setState(() {
            visitorRegisterData =
                response.data["Display_VisitorRegisterDataResult"]["Data"];
          });
        } else {
          debugPrint(
            "Error Fetching the register data. Error: "
            "${response.data["Display_VisitorRegisterDataResult"]["ErrorMessage"]}",
          );
        }
      } else {
        debugPrint(
          "Failed to fetch visitor register data. Status code: ${response.statusCode}",
        );
      }
    } catch (ex) {
      debugPrint("Error fetching visitor register data: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(),
          _searchSection(),
          Expanded(child: _visitorRegisterList()),
        ],
      ),
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
            "Visitors Register",
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  ///Visitor Regieter Search Section
  Widget _searchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Visitor Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Row(
            children: [
              // From Date
              Expanded(
                child: TextField(
                  controller: _fromDateController,
                  decoration: InputDecoration(
                    labelText: "From Date",
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await CommonDatePicker.pickDate(
                      context: context,
                    );

                    if (!mounted) return;

                    if (selectedDate != null) {
                      setState(() {
                        _fromDateController.text =
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 6),

              // To Date
              Expanded(
                child: TextField(
                  controller: _toDateController,
                  decoration: InputDecoration(
                    labelText: "To Date",
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await CommonDatePicker.pickDate(
                      context: context,
                    );

                    if (!mounted) return;

                    if (selectedDate != null) {
                      setState(() {
                        _toDateController.text =
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 16),
              //SearchButton
              CommonButton(
                width: 100,
                height: 40,
                color: Colors.blue,
                label: "Search",
                onPressed: () {
                  fetchVisitorRegisterData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Visitor reg list UI
  Widget _visitorRegisterList() {
    return visitorRegisterData.isEmpty
        ? Center(
            child: Text(
              "Visitor Register data not found.",
              style: AppTextStyles.labelMedium,
            ),
          )
        : ListView.separated(
            itemCount: visitorRegisterData.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.only(left: 2, right: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Visitor Code:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['VisitorCode'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Visitor Name:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          //SizedBox(width: 50),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['VisitorName'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Date:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['AppointmentDate'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "In Time:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['AppointmetInTime'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Out Time:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['AppointmentOutTime'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Organization:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['Organization'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Whom to Meet:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['WhomToMeet'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Department:",
                              style: AppTextStyles.headingSmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (visitorRegisterData[index]['Department'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  //Dispose controllers
  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }
}
