// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
import 'package:new_design_demo/presentations/common_widgets/common_datePicker.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/common_widgets/common_timePicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleBooking extends StatefulWidget {
  const VehicleBooking({super.key});

  @override
  State<VehicleBooking> createState() => _VehicleBookingState();
}

class _VehicleBookingState extends State<VehicleBooking> {
  bool isAuthorizationScreen = false;
  bool showBookVehicleForm = false;
  String? selectedDepartment;
  String? selectedVehicleType;
  String tripType = "One Way";
  List vehicleBookingAppList = [];
  int selectedApprovalTab = 0;
  bool isAuthLoading = false;
  List filteredVehicleList = [];

  ///Controllers for booking an vehicle form
  TextEditingController employeeCodeController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController placetovisitcontroller = TextEditingController();
  TextEditingController purposecontroller = TextEditingController();
  TextEditingController personcontroller = TextEditingController();
  TextEditingController pickuplocationcontroller = TextEditingController();
  TextEditingController pickupTimeController = TextEditingController();
  TextEditingController todatecontroller = TextEditingController();
  TextEditingController totimecontroller = TextEditingController();
  TextEditingController vehiclenumbercontroller = TextEditingController();
  TextEditingController visitornamecontroller = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();
  TextEditingController fromdatecontroller = TextEditingController();
  TextEditingController fromtimecontroller = TextEditingController();
  TextEditingController numberofpersonscontroller = TextEditingController();

  int? emppk;
  String? empcode;
  int? companypk;
  int? locationpk;
  String? empname;
  String? department;
  String? designation;
  String? mobileNumber;
  int? isSuperAdmin;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getPrefsData();
  }

  Future<void> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();

    emppk = prefs.getInt("emppk");
    empcode = prefs.getString("employeecode");
    companypk = prefs.getInt("companypk");
    locationpk = prefs.getInt("locationpk");
    empname = prefs.getString("employeename");
    isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;

    debugPrint("Loaded EmpPk :- $emppk");

    _setEmployeeDataToForm();
    _getAndSaveBookingPreferences();
    _getVehicleBookingAppList();
  }

  Future<void> _getAndSaveBookingPreferences() async {
    final response = await ApiClient.get(
      ApiConstants.getUserProfile,
      query: {'Emp_PK': emppk},
    );

    if (response.statusCode == 200 && response.data.isNotEmpty) {
      final profile = response.data[0];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("department", profile["Dept_Name"] ?? "");
      department = profile["Dept_Name"] ?? "";
      await prefs.setString("designation", profile["Designation_Title"] ?? "");
      designation = profile["Designation_Title"] ?? "";
      await prefs.setString("mobileNumber", profile["Mobile_Number"] ?? "");
      mobileNumber = profile["Mobile_Number"] ?? "";

      if (selectedVehicleType != null) {
        await prefs.setString("selectedVehicleType", selectedVehicleType!);
      }
    } else {
      debugPrint("Failed to load user profile for saving booking preferences.");
    }
    _setEmployeeDataToForm();
  }

  Future<void> _getVehicleBookingAppList() async {
    if (emppk == null) return;

    final response = await ApiClient.get(
      ApiConstants.getVehicleBookingAppList,
      query: {'Emp_PK': emppk},
    );
    if (response.statusCode == 200) {
      setState(() {
        vehicleBookingAppList = List<Map<String, dynamic>>.from(
          response.data.map((e) => Map<String, dynamic>.from(e)),
        );
      });
      debugPrint("DATA LENGTH: ${vehicleBookingAppList.length}");
    } else {
      debugPrint("API FAILED");
    }
  }

  Future<void> _selfRejectVehicleBooking(int bookingId) async {
    final response = await ApiClient.post(
      ApiConstants.selfRejectVehicleBooking,
      data: {"VehicleBook_PK": bookingId.toString()},
    );

    if (response.statusCode == 200) {
      _getVehicleBookingAppList();
      CommonSnackBar.show(
        context: context,
        title: "Success",
        message: "Vehicle booking rejected successfully.",
        type: SnackBarType.success,
      );
    } else {
      CommonSnackBar.show(
        context: context,
        title: "Failed",
        message: "Failed to self reject booking.",
        type: SnackBarType.error,
      );
      debugPrint("Failed to self reject booking.");
    }
  }

  Future<void> getVehicleAuthorizationList(int index) async {
    setState(() {
      selectedApprovalTab = index;
      isAuthLoading = true;
    });

    try {
      final response = await ApiClient.get(
        ApiConstants.getVehicleBookingApprovalList,
        query: {
          "Emp_PK": emppk,
          "Status": index == 0
              ? "Pending"
              : index == 1
              ? "Approved"
              : "Rejected",
        },
      );

      List list = response.data;

      filteredVehicleList = list.where((item) {
        final status = item["BookingStatus"].toString().toLowerCase();
        if (index == 0) {
          return status.contains("pending") || status.contains("approved by");
        }
        if (index == 1) return status.contains("approved");
        return status.contains("reject") || status.contains("rejected by");
      }).toList();
    } catch (e) {
      debugPrint("Auth Error: $e");
    }

    setState(() {
      isAuthLoading = false;
    });
  }

  void _setEmployeeDataToForm() {
    employeeCodeController.text = empcode ?? "";
    employeeNameController.text = empname ?? "";
    departmentController.text = department ?? "";
    designationController.text = designation ?? "";
    mobileNumberController.text = mobileNumber ?? "";
  }

  @override
  Widget build(BuildContext context) {
    //         — same as AppVisitorManagement
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (showBookVehicleForm) {
          setState(() => showBookVehicleForm = false);
          return false;
        }
        if (isAuthorizationScreen) {
          setState(() => isAuthorizationScreen = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        //        
        backgroundColor: isDark ? const Color(0xFF0F172A) : null,
        body: Stack(
          children: [
            Column(
              children: [
                _header(),
                Expanded(
                  flex: 2,
                  child: isAuthorizationScreen
                      ? _vehicleAuthorizationData(isDark: isDark)
                      : _vehicleBookingAppStatus(isDark: isDark),
                ),
              ],
            ),

            if (showBookVehicleForm)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showBookVehicleForm = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _vehicleBookingForm(isDark: isDark),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 270,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      // Header gradient fixed — same as original
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 195, 193, 61),
            Color.fromARGB(255, 111, 109, 3),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (!isAuthorizationScreen) {
                Navigator.pop(context);
              } else {
                setState(() => isAuthorizationScreen = false);
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.15),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Requisition',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Management',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage Your Vehicle Requisitions.',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CommonButton(
                    width: 170,
                    height: 40,
                    color: Colors.white,
                    label: 'Book Vehicle',
                    icon: const Icon(Icons.add, color: Colors.lightGreen),
                    textColor: Colors.lightGreen,
                    onPressed: () =>
                        setState(() => showBookVehicleForm = !showBookVehicleForm),
                  ),
                  const SizedBox(height: 10),
                  if (!isAuthorizationScreen)
                    SizedBox(
                      width: 175,
                      height: 42,
                      child: CommonButton(
                        label: 'Authorization',
                        color: Colors.white,
                        icon: const Icon(
                          Icons.verified_user,
                          color: Colors.lightBlue,
                          size: 19,
                        ),
                        textColor: Colors.lightGreen,
                        onPressed: () {
                          setState(() => isAuthorizationScreen = true);
                        },
                        width: 100,
                        height: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicleBookingForm({bool isDark = false}) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        //        
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => showBookVehicleForm = false),
                        child: CircleAvatar(
                          radius: 23,
                          //        
                          backgroundColor: isDark
                              ? Colors.white12
                              : const Color.fromARGB(255, 218, 216, 216),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            //        
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Book Vehicle",
                        style: AppTextStyles.headingMedium.copyWith(
                          //        
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _sectionTitle("Employee Details :", isDark: isDark),
                  const SizedBox(height: 8),
                  _field('Employee Code', employeeCodeController,
                      readOnly: true, isDark: isDark),
                  _field('Employee Name', employeeNameController,
                      readOnly: true, isDark: isDark),
                  _field('Department', departmentController,
                      readOnly: true, isDark: isDark),
                  _field('Designation', designationController,
                      readOnly: true, isDark: isDark),
                  _field('Mobile Number', mobileNumberController,
                      readOnly: true, isDark: isDark),

                  _sectionTitle("Trip Details :", isDark: isDark),
                  const SizedBox(height: 8),
                  _field('Place of Visit', placetovisitcontroller, isDark: isDark),
                  _field('Purpose', purposecontroller, isDark: isDark),
                  _field('Number of Persons', numberofpersonscontroller,
                      isDark: isDark),
                  _field('Pickup Location', pickuplocationcontroller,
                      isDark: isDark),
                  _timeField('Pickup Time', pickupTimeController, isDark: isDark),

                  Row(
                    children: [
                      Expanded(
                        child: _dateField('From Date', fromdatecontroller,
                            isDark: isDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _timeField('From Time', fromTimeController,
                            isDark: isDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField('To Date', todatecontroller,
                            isDark: isDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            _timeField('To Time', toTimeController, isDark: isDark),
                      ),
                    ],
                  ),

                  _sectionTitle("Vehicle Info :", isDark: isDark),
                  const SizedBox(height: 8),
                  _dropdown(
                    label: "Vehicle Type",
                    value: selectedVehicleType,
                    items: ["Car", "SUV", "Sedan"],
                    onChanged: (val) =>
                        setState(() => selectedVehicleType = val),
                    isDark: isDark,
                  ),
                  _field('Vehicle Number', vehiclenumbercontroller, isDark: isDark),

                  _radioGroup(isDark: isDark),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: CommonButton(
                  height: 40,
                  color: Colors.lightGreen,
                  label: "Submit",
                  onPressed: () {},
                  width: 70,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: CommonButton(
                  height: 40,
                  width: 70,
                  color: Colors.orangeAccent,
                  label: "Cancel",
                  onPressed: () => setState(() => showBookVehicleForm = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {bool isDark = false}) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        fontWeight: FontWeight.bold,
        //        
        color: isDark ? Colors.white70 : null,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        //        
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _radioGroup({bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            //        
            color: isDark ? Colors.white70 : null,
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: "One Way",
              groupValue: tripType,
              onChanged: (val) => setState(() => tripType = val!),
            ),
            Text(
              "One Way",
              //        
              style: TextStyle(color: isDark ? Colors.white70 : null),
            ),
            Radio<String>(
              value: "Return Trip",
              groupValue: tripType,
              onChanged: (val) => setState(() => tripType = val!),
            ),
            Text(
              "Return Trip",
              //        
              style: TextStyle(color: isDark ? Colors.white70 : null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateField(
    String label,
    TextEditingController fromdatecontroller, {
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        //        
        style: TextStyle(color: isDark ? Colors.white : null),
        onTap: () async {
          CommonDatePicker.pickDate(context: context).then((selectedDate) {
            if (selectedDate != null) {
              debugPrint("Selected Date: $selectedDate");
            }
          });
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: isDark ? Colors.white54 : null,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeField(
    String label,
    TextEditingController controller, {
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        //        
        style: TextStyle(color: isDark ? Colors.white : null),
        onTap: () async {
          AppTimePicker.show(context: context, controller: controller);
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          suffixIcon: Icon(
            Icons.access_time,
            color: isDark ? Colors.white54 : null,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController? controller, {
    bool readOnly = false,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        //        
        style: TextStyle(color: isDark ? Colors.white : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          //         — readonly/disabled fields slightly muted in dark
          filled: readOnly && isDark,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : null,
        ),
      ),
    );
  }

  Widget _vehicleBookingAppStatus({bool isDark = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (vehicleBookingAppList.isEmpty) {
      return Center(
        child: Text(
          "No bookings found.",
          //        
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return ListView.builder(
      itemCount: vehicleBookingAppList.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final app = vehicleBookingAppList[index];

        return InkWell(
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            //        
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app["VehicleType"] ?? "-",
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          //        
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      _statusChip(app["BookingStatus"]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${app["PickUpLocation"]} ➝ ${app["DropLocation"]}",
                    style: AppTextStyles.labelMedium.copyWith(
                      //        
                      color: isDark ? Colors.white70 : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "From: ${app["FromDateTime"]}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  Text(
                    "To: ${app["ToDateTime"]}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Persons: ${app["Persons"]}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.white70 : null,
                    ),
                  ),
                  Text(
                    "Purpose: ${app["Purpose"]}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.white70 : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((app["VisitorName"] ?? "").isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Visitor: ${app["VisitorName"]}",
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? Colors.white70 : null,
                          ),
                        ),
                        if (app["BookingStatus"] == "Pending" ||
                            app["BookingStatus"] ==
                                app["BookingStatus"].contains("Approved by"))
                          CommonButton(
                            label: "Self Reject",
                            color: Colors.deepOrangeAccent,
                            textColor: Colors.white,
                            onPressed: () {
                              _selfRejectVehicleBooking(app["VehicleBook_PK"]);
                            },
                            width: 130,
                            height: 27,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              elevation: 2,
              //         — bottom sheet bg
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  style: BorderStyle.solid,
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              builder: (context) => _bookingFullDetails(
                Map<String, dynamic>.from(app),
                isDark: isDark,
              ),
            );
          },
        );
      },
    );
  }

  Widget _bookingFullDetails(Map<String, dynamic> booking,
      {bool isDark = false}) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        //        
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  //        
                  backgroundColor: isDark
                      ? Colors.white12
                      : const Color.fromARGB(255, 218, 216, 216),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Vehicle Booking Details",
                  style: AppTextStyles.headingMedium.copyWith(
                    //        
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _detailRow("Application Date", booking["ApplicationDate"],
                isDark: isDark),
            _detailRow("Status", booking["BookingStatus"], isDark: isDark),
            _detailRow("Trip Type", booking["TripType"], isDark: isDark),
            _detailRow("Vehicle Type", booking["VehicleType"], isDark: isDark),

            Divider(color: isDark ? Colors.white12 : null),

            _detailRow("Pickup Location", booking["PickUpLocation"],
                isDark: isDark),
            _detailRow("Drop Location", booking["DropLocation"], isDark: isDark),
            _detailRow("Pickup Time", booking["PickupTime"], isDark: isDark),

            Divider(color: isDark ? Colors.white12 : null),

            _detailRow("From Date", booking["FromDateTime"], isDark: isDark),
            _detailRow("To Date", booking["ToDateTime"], isDark: isDark),
            _detailRow("From Day Type", booking["FromDayType"], isDark: isDark),
            _detailRow("To Day Type", booking["ToDayType"], isDark: isDark),

            Divider(color: isDark ? Colors.white12 : null),

            _detailRow("Persons", booking["Persons"], isDark: isDark),
            _detailRow("Persons Name", booking["PersonsName"], isDark: isDark),
            _detailRow("Purpose", booking["Purpose"], isDark: isDark),

            if ((booking["VisitorName"] ?? "").isNotEmpty)
              _detailRow("Visitor", booking["VisitorName"], isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                //        
                color: isDark ? Colors.white : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : "-",
              //        
              style: TextStyle(color: isDark ? Colors.white70 : null),
            ),
          ),
        ],
      ),
    );
  }

  // Status Chip — colored badges, no theme change needed
  Widget _statusChip(String status) {
    Color color;

    if (status.toLowerCase().contains("approved")) {
      color = Colors.green;
    } else if (status.toLowerCase().contains("booked")) {
      color = Colors.orange;
    } else if (status.toLowerCase().contains("reject")) {
      color = Colors.redAccent;
    } else {
      color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _vehicleAuthorizationData({bool isDark = false}) {
    if (isAuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _authorizationTabs(isDark: isDark),
          const SizedBox(height: 10),
          Expanded(
            child: filteredVehicleList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty_sharp,
                          size: 50,
                          //        
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        Text(
                          "No Data Found",
                          //        
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredVehicleList.length,
                    itemBuilder: (context, index) {
                      final app = filteredVehicleList[index];

                      return InkWell(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            //        
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app["VehicleType"] ?? "-",
                                    style: AppTextStyles.headingSmall.copyWith(
                                      //        
                                      color: isDark ? Colors.white : null,
                                    ),
                                  ),
                                  _statusChip(app["BookingStatus"]),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${app["PickUpLocation"]} ➝ ${app["DropLocation"]}",
                                style: TextStyle(
                                  //        
                                  color: isDark ? Colors.white70 : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "From: ${app["FromDateTime"]}",
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : null,
                                ),
                              ),
                              Text(
                                "To: ${app["ToDateTime"]}",
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : null,
                                ),
                              ),
                              if (selectedApprovalTab == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CommonButton(
                                      label: "Approve",
                                      color: Colors.green,
                                      onPressed: () {},
                                      width: 110,
                                      height: 35,
                                    ),
                                    const SizedBox(width: 10),
                                    CommonButton(
                                      label: "Reject",
                                      color: Colors.red,
                                      onPressed: () {},
                                      width: 110,
                                      height: 35,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _authorizationTabs({bool isDark = false}) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        //        
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          _authTabItem("Pending", 0, isDark: isDark),
          _authTabItem("Approved", 1, isDark: isDark),
          _authTabItem("Rejected", 2, isDark: isDark),
        ],
      ),
    );
  }

  Widget _authTabItem(String title, int index, {bool isDark = false}) {
    bool isSelected = selectedApprovalTab == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => getVehicleAuthorizationList(index),
        child: Container(
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  // Selected tab — fixed gradient same as original
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 195, 193, 61),
                      Color.fromARGB(255, 111, 109, 3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  //         — unselected tab text
                  : (isDark ? Colors.white38 : Colors.grey),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}