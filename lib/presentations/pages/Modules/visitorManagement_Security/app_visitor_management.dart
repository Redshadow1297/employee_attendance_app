// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/data/model/employee_model.dart';
import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_status_of_visitor.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_alert.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_departure.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_pass.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_register.dart';
import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVisitorManagement extends StatefulWidget {
  const AppVisitorManagement({super.key});

  @override
  State<AppVisitorManagement> createState() => _AppVisitorManagementState();
}

class _AppVisitorManagementState extends State<AppVisitorManagement> {
  int? emppk;
  String? empcode;
  int? companypk;
  int? deptpk;
  int? locationpk;
  String? empname;
  int? isSuperAdmin;
  String? base64string;
  String? ISParticipant1;

  bool showVisitorEntryForm = false;
  bool isAuthorizationScreen = false;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? capturedImage;

  String visitorCode = "";
  String selectedVisitorName = "";
  String selectedCompanyName = "";
  int? selectedEmpPk;

  List<String> visitorNames = [];
  List<String> companyNames = [];
  List<EmployeeModel> allEmployees = [];

  final visitorCodeController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final visitorNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final visitorCountController = TextEditingController();
  final contactController = TextEditingController();
  final purposeController = TextEditingController();
  final itemController = TextEditingController();
  final mailcontroller = TextEditingController();
  final whoomToMeetController = TextEditingController();
  final departmentController = TextEditingController();

  //Modules Of Visitor Management
  List<String> modulesForVisitorManagement = [
    "Visitor Alert",
    "Status Of Visitor",
    "Visitor Pass",
    "Visitor Departure",
    "Visitor Register",
  ];

  final Map<String, IconData> moduleIcons = {
    "Visitor Alert": Icons.notifications_active,
    "Status Of Visitor": Icons.people,
    "Visitor Pass": Icons.badge,
    "Visitor Departure": Icons.logout,
    "Visitor Register": Icons.app_registration,
  };

  //INIT
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  //DISPOSE
  @override
  void dispose() {
    visitorCodeController.dispose();
    dateController.dispose();
    timeController.dispose();
    visitorNameController.dispose();
    companyNameController.dispose();
    visitorCountController.dispose();
    contactController.dispose();
    purposeController.dispose();
    itemController.dispose();
    mailcontroller.dispose();
    whoomToMeetController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await _getPrefsData();
    await Future.wait([
      fetchVisitorCode(),
      getVisitorNames(),
      getWhoomToMeetNames(),
    ]);
    companyNames = await getCompanyNames();
    dateController.text = DateTime.now().toString().split(' ')[0];
    timeController.text = TimeOfDay.now().format(context);
    setState(() => isLoading = false);
  }

  //PREFS DATA
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

  ////Fetching Visitor code method
  Future<void> fetchVisitorCode() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getVisitorCode,
        query: {},
      );
      if (response.data["GetVisitorCodeResult"] != null) {
        final decodedList = jsonDecode(response.data["GetVisitorCodeResult"]);
        if (decodedList.isNotEmpty) {
          visitorCode = decodedList[0]["Column1"] ?? "";
          visitorCodeController.text = visitorCode;
        }
      }
    } catch (e) {
      debugPrint("Visitor Code Error: $e");
    }
  }

  ////Get Visitors names
  Future<void> getVisitorNames() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getVisitorsName,
        query: {},
      );
      if (response.data["GetVisitorNameResult"] != null) {
        final List<dynamic> data = response.data["GetVisitorNameResult"];
        visitorNames = data
            .map((e) => e.toString().trim())
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint("Visitor Names Error: $e");
    }
  }

  ///Get Company names
  Future<List<String>> getCompanyNames() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getCoompanyNames,
        query: {},
      );
      if (response.data["GetOrgnizationNameResult"] != null) {
        final List<dynamic> data = response.data["GetOrgnizationNameResult"];
        return data
            .map((e) => e.toString().trim())
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint("Company Names Error: $e");
    }
    return [];
  }

  //Saving the Visitors Entry
  Future<void> saveVisitorEntry() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.saveVisitorEntry,
        data: {
          "data": {
            "AppointmentDate": dateController.text,
            "AppointmentTimeIn": timeController.text,
            "VisitorCode": visitorCode,
            "DeptPk": deptpk.toString(),
            "Name": visitorNameController.text,
            "organize": companyNameController.text,
            "purpose": purposeController.text,
            "CreatedBy": emppk.toString(),
            "ItemTakenIn": itemController.text,
            "ContactNo": contactController.text,
            "EmailID": mailcontroller.text,
            "whoomTomeetpk": selectedEmpPk,
            "Department": departmentController.text,
            "NoofVisitor": visitorCountController.text,
            "Photo": "",
            "IsImage": true,
            "ImageExtension": "jpg",
            "Flag": "I",
            "ImageVisitor": base64string ?? "",

            ///Bse64String
            "ManualPermission": ISParticipant1 ?? 0,
          },
        },
      );

      final result = response.data["Insert_VisitorEntryResult"];

      if (result != null && result["IsError"] == false) {
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: result["Data"] ?? "Visitor entry saved successfully",
          type: SnackBarType.success,
        );
        clearForm();
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Failed",
          message: result?["Data"] ?? "Failed to save visitor entry",
          type: SnackBarType.error,
        );
      }
    } catch (ex) {
      debugPrint("ERROR TYPE : ${ex.runtimeType}");
      debugPrint("FULL ERROR : $ex");
      // if (ex is DioException) {
      //   debugPrint("STATUS : ${ex.response?.statusCode}");
      //   debugPrint("DATA : ${ex.response?.data}");
      //   final responseData = ex.response?.data;
      //   if (responseData != null &&
      //       responseData["Insert_VisitorEntryResult"] != null) {
      //     final result = responseData["Insert_VisitorEntryResult"];
      //     if (result["IsError"] == false) {
      //       CommonSnackBar.show(
      //         context: context,
      //         title: "Success",
      //         message: result["Data"],
      //         type: SnackBarType.success,
      //       );
      //       clearForm();
      //       return;
      //     }
      //   }
      // }
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Error to save visitor entry.",
        type: SnackBarType.error,
      );
    }
  }

  ////Capture the image of visitor
  Future<void> captureVisitorImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          capturedImage = File(image.path);
          base64string = base64Encode(bytes);
        });
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: "Image captured successfully",
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Failed to capture image",
        type: SnackBarType.error,
      );
      debugPrint("Camera Error: $e");
    }
  }

  ////// ----------------- Fetch Whoom To meet User List --------------------
  Future<void> getWhoomToMeetNames() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getWhoomToMeetList,
        query: {},
      );

      if (response.statusCode == 200) {
        final List data = response.data['getActiveEmployeeListResult'] ?? [];

        setState(() {
          allEmployees = data.map((e) => EmployeeModel.fromJson(e)).toList();
        });

        debugPrint("Employee Count :: ${allEmployees.length}");
      }
    } catch (ex) {
      debugPrint("Exception Is :: $ex");
    }
  }

  ////Clearing alll  fields of visitor entry form
  void clearForm() {
    visitorNameController.clear();
    companyNameController.clear();
    visitorCountController.clear();
    contactController.clear();
    purposeController.clear();
    itemController.clear();
    whoomToMeetController.clear();
    mailcontroller.clear();
    departmentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      //
      backgroundColor: isDark ? const Color(0xFF0F172A) : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    _header(),
                    Expanded(
                      child: isAuthorizationScreen
                          ? _visitorAutorizationScreen(isDark: isDark)
                          : GridView.builder(
                              padding: const EdgeInsets.all(10),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (modulesForVisitorManagement[index] ==
                                          "Visitor Alert") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AppVisitorAlertScreen(),
                                          ),
                                        );
                                      } else if (modulesForVisitorManagement[index] ==
                                          "Status Of Visitor") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const StatusOfVisitorScreen(),
                                          ),
                                        );
                                      } else if (modulesForVisitorManagement[index] ==
                                          "Visitor Pass") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AppVisitorsPassScreen(),
                                          ),
                                        );
                                      } else if (modulesForVisitorManagement[index] ==
                                          "Visitor Departure") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AppVisitorDeparture(),
                                          ),
                                        );
                                      } else if (modulesForVisitorManagement[index] ==
                                          "Visitor Register") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AppVisitorRegisterScreen(),
                                          ),
                                        );
                                      } else {
                                        CommonSnackBar.show(
                                          context: context,
                                          title: "Info",
                                          message:
                                              "${modulesForVisitorManagement[index]} screen is under development.",
                                          type: SnackBarType.warning,
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : Colors.white,
                                        border: Border.all(
                                          //        - border
                                          color: isDark
                                              ? Colors.white24
                                              : Colors.blueGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.4)
                                                : Colors.grey.withOpacity(0.18),
                                            blurRadius: 5,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              moduleIcons[modulesForVisitorManagement[index]] ??
                                                  Icons.widgets,
                                              size: 30,
                                              color: isDark
                                                  ? Colors.lightBlueAccent
                                                  : Colors.blue,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              modulesForVisitorManagement[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                //        - module label
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: modulesForVisitorManagement.length,
                            ),
                    ),
                  ],
                ),

                // Visitor Entry Form Overlay
                if (showVisitorEntryForm)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => showVisitorEntryForm = false),
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _visitorEntryForm(isDark: isDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _header() {
    return Container(
      height: 270,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 57, 147, 182),
            Color.fromARGB(255, 16, 69, 90),
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
                // Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AppDashboardScreen(),
                  ),
                );
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
                    'Visitor',
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
                    'Manage Your Visitor Entries.',
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
                    label: 'Visitor Entry',
                    icon: const Icon(Icons.add, color: Colors.lightGreen),
                    textColor: Colors.lightGreen,
                    onPressed: () => setState(
                      () => showVisitorEntryForm = !showVisitorEntryForm,
                    ),
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

  //  VISITOR ENTRY FORM
  Widget _visitorEntryForm({bool isDark = false}) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      //        - material color
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          //
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => showVisitorEntryForm = false),
                    child: CircleAvatar(
                      //
                      backgroundColor: isDark
                          ? Colors.white24
                          : Colors.black12.withOpacity(0.15),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Visitor Entry Form",
                    style: AppTextStyles.headingMedium.copyWith(
                      //
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildField(
                visitorCodeController,
                "Visitor Code",
                false,
                TextInputType.text,
                isDark,
              ),
              _buildField(
                dateController,
                "Visiting Date",
                false,
                TextInputType.text,
                isDark,
              ),
              _buildField(
                timeController,
                "Visiting Time",
                false,
                TextInputType.text,
                isDark,
              ),

              const SizedBox(height: 10),

              _autoCompleteField(
                visitorNameController,
                visitorNames,
                "Visitor Name",
                isDark,
              ),
              _autoCompleteField(
                companyNameController,
                companyNames,
                "Company Name",
                isDark,
              ),

              _buildField(
                visitorCountController,
                "Number of Visitors",
                true,
                TextInputType.number,
                isDark,
              ),
              _buildField(
                contactController,
                "Contact Number",
                true,
                TextInputType.phone,
                isDark,
              ),
              _buildField(
                mailcontroller,
                "Email Id",
                true,
                TextInputType.emailAddress,
                isDark,
              ),

              _whoomToMeetField(isDark: isDark),

              _buildField(
                departmentController,
                "Department",
                false,
                TextInputType.text,
                isDark,
              ),
              _buildField(
                purposeController,
                "Purpose of Visit",
                true,
                TextInputType.text,
                isDark,
              ),
              _buildField(
                itemController,
                "Item to be Carried",
                true,
                TextInputType.text,
                isDark,
              ),

              CommonButton(
                width: 220,
                height: 40,
                icon: const Icon(Icons.camera_alt_outlined, size: 28),
                color: Colors.grey,
                label: "Capture Image",
                onPressed: captureVisitorImage,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      label: "Submit",
                      color: Colors.green,
                      onPressed: () async {
                        if (base64string == null ||
                            base64string!.isEmpty ||
                            mailcontroller.text.isEmpty ||
                            whoomToMeetController.text.isEmpty ||
                            departmentController.text.isEmpty ||
                            visitorNameController.text.isEmpty ||
                            companyNameController.text.isEmpty ||
                            visitorCountController.text.isEmpty ||
                            contactController.text.isEmpty ||
                            purposeController.text.isEmpty ||
                            itemController.text.isEmpty) {
                          CommonSnackBar.show(
                            context: context,
                            title: "All Fields are Required",
                            message: "Please fill the all fields.",
                            type: SnackBarType.warning,
                          );
                          return;
                        }
                        await saveVisitorEntry();
                        setState(() => showVisitorEntryForm = false);
                      },
                      width: double.infinity,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CommonButton(
                      label: "Clear",
                      color: Colors.orange,
                      onPressed: clearForm,
                      width: double.infinity,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  BUILD FIELD
  Widget _buildField(
    TextEditingController controller,
    String label,
    bool enabled, [
    TextInputType keyboardType = TextInputType.text,
    bool isDark = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        //
        style: TextStyle(color: isDark ? Colors.white : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          //   disabled fields slightly muted in dark
          filled: !enabled && isDark,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : null,
        ),
      ),
    );
  }

  //  AUTOCOMPLETE FIELD
  Widget _autoCompleteField(
    TextEditingController controller,
    List<String> options,
    String label,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Autocomplete<String>(
        optionsBuilder: (textEditingValue) {
          return options.where(
            (option) => option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        onSelected: (selection) {
          controller.text = selection;
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              //        - dropdown list
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
        fieldViewBuilder:
            (context, textController, focusNode, onFieldSubmitted) {
              textController.text = controller.text;
              return TextField(
                controller: textController,
                focusNode: focusNode,
                style: TextStyle(color: isDark ? Colors.white : null), //
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey,
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }

  //  WHOOM TO MEET FIELD
  Widget _whoomToMeetField({bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Autocomplete<EmployeeModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return allEmployees;
          }

          return allEmployees.where((employee) {
            return employee.employeeName.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ) ||
                employee.empCode.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
          });
        },

        displayStringForOption: (EmployeeModel option) => option.employeeName,

        onSelected: (EmployeeModel selection) {
          whoomToMeetController.text = selection.employeeName;

          selectedEmpPk = selection.empPk;

          departmentController.text = selection.departmentName;

          FocusScope.of(context).unfocus();

          setState(() {});
        },

        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final employee = options.elementAt(index);

                    return ListTile(
                      title: Text(
                        employee.employeeName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      subtitle: Text(
                        employee.departmentName,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),

                      trailing: Text(
                        employee.empCode,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),

                      onTap: () {
                        onSelected(employee);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },

        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,

                style: TextStyle(color: isDark ? Colors.white : Colors.black),

                decoration: InputDecoration(
                  labelText: "Whom To Meet",

                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),

                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey,
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }

  //  VISITOR AUTHORIZATION SCREEN  Pending  -------------------------------------------
  Widget _visitorAutorizationScreen({bool isDark = false}) {
    return Center(
      child: Text(
        "Visitor Authorization List",
        style: AppTextStyles.labelMedium.copyWith(
          //
          color: isDark ? Colors.white70 : null,
        ),
      ),
    );
  }
}
