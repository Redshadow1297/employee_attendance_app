import 'api_client.dart';
import 'api_constants.dart';

class ApiService {
  // ----------------------- Login ---------------------------POST
  static Future<dynamic> login(Map<String, dynamic> data) async {
    final response = await ApiClient.post(ApiConstants.login, data: data);

    return response.data;
  }

  // ----------------------- Profile Info ---------------------------GET
  static Future<List<dynamic>> getProfile(int empPk) async {
    final response = await ApiClient.get(
      ApiConstants.getUserProfile,
      query: {"Emp_PK": empPk},
    );

    return response.data;
  }

  // ----------------------- Module List ---------------------------GET
  static Future<List<dynamic>> getModules(int empPk) async {
    final response = await ApiClient.get(
      ApiConstants.getUserModules,
      query: {"Emp_PK": empPk},
    );

    return response.data;
  }

  // ----------------------- Wall Posts ---------------------------GET
  static Future<List<dynamic>> getWallPosts(
    String userName,
    String password,
  ) async {
    final response = await ApiClient.get(
      ApiConstants.getWallPosts,
      query: {"UserName": userName, "ConfPass": password},
    );

    return response.data;
  }

  // ----------------------- Leave Status ---------------------------GET
  static Future<List<dynamic>> getLeaveStatus(int empPk) async {
    final response = await ApiClient.get(
      ApiConstants.getLeaveStatus,
      query: {"Emp_PK": empPk},
    );

    return response.data;
  }

  //------------------------ Leave types ----------------------------GET
  static Future<List<dynamic>> getLeavetype(int empPk) async {
    final response = await ApiClient.get(
      ApiConstants.getLeaveType,
      query: {"Emp_PK": empPk},
    );

    return response.data;
  }

  //---------------------- getLeaveBalance ---------------------------GET
  static Future<List<dynamic>> getLeaveBalance(int empPk) async {
    final response = await ApiClient.get(
      ApiConstants.getLeaveType,
      query: {"Emp_PK": empPk},
    );

    return response.data;
  }

  // ----------------------- Leave Self Reject ---------------------------POST
  static Future<dynamic> leaveSelfReject(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.leaveSelfReject,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Get Attendance Status List ---------------------------POST
  static Future<dynamic> getAttendanceStatus(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getAttendanceStatus,
      data: data,
    );

    return response.data;
  }

  // -----------------------  Get AttApproval List Authorization ---------------------------- POST
  static Future<dynamic> getAttendaceApprovalList(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.getAttendanceApprovalList,
      data: data,
    );

    return response.data;
  }

  //------------------------- Approve or Reject the att application Auth ------------------------ POST
  static Future<dynamic> attendanceApplicationApproveORReject ( Map<String, dynamic> data) async {
    final response = await ApiClient.post(ApiConstants.attendanceApplicationApproveORReject,
    data : data,
    );

    return response;
  }

  // ----------------------- Get TimeCard Data ---------------------------GET
  static Future<dynamic> getTimeCardData(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getTimeCardData,
      query: data,
    );

    return response.data;
  }

  // ----------------------- Get CurrentDate FromSchedular ---------------------------GET
  static Future<dynamic> getCurrentDate(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getCurrentDate,
      query: data,
    );

    return response.data;
  }

  // ----------------------- SubmitLeaveApplication ---------------------------POST
  static Future<dynamic> submitLeaveApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.submitLeaveApplication,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Submit Attendance Application ---------------------------POST
  static Future<dynamic> submitAttendanceApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.submitAttendanceApplication,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Approve/Reject Attendance Application (Authorize person only) ---------------------------POST
  static Future<dynamic> approveAttendanceApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.approveAttendanceApplication,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Self Reject Attendance Application  ---------------------------POST
  static Future<dynamic> selfRejectAttendance(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.selfRejectAttendance,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Approve/Reject Leave Application (Authorize person only) ---------------------------Get
  static Future<dynamic> getLeaveAuthorization(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.get(
      ApiConstants.getLeaveAuthorization,
      query: data,
    );

    return response.data;
  }

  // ----------------------- Get LastLoginDetails Data ---------------------------GET
  static Future<dynamic> getLastLoginDetails(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getLastLoginDetails,
      query: data,
    );

    return response.data;
  }

  //--------------------------- Get Company List -----------------------------GET
  static Future<dynamic> getCompanyGroupList(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getCompanyGroupList,
      query: data,
    );

    return response.data;
  }

  // ----------------------- Get Employee Search By Name && Employee Code ---------------------------POST
  static Future<dynamic> searchEmployeeNameCode(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.get(
      ApiConstants.searchEmployeeNameCode,
      query: data,
    );

    return response.data;
  }

  // ----------------------- Get Todays Attendance date time ---------------------------POST
  static Future<dynamic> getTodaysAttendance(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getTodaysAttendance,
      data: data,
    );

    return response.data;
  }

  // ----------------------- CheckIn/CheckOut (Punch In/Out) ---------------------------POST
  static Future<dynamic> punchInOut(Map<String, dynamic> data) async {
    final response = await ApiClient.post(ApiConstants.punchInOut, data: data);

    return response.data;
  }

  // ----------------------- Get Advance Status ---------------------------GET
  static Future<dynamic> getAdvanceStatus(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getAdvanceStatus,
      data: data,
    );

    return response.data;
  }

  // -----------------------Get Advance Details ---------------------------POST
  static Future<dynamic> getAdvanceDetails(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getAdvanceDetails,
      data: data,
    );

    return response.data;
  }

  // -----------------------Save Advance Application ---------------------------POST
  static Future<dynamic> saveAdvanceApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.submitAdvanceApplication,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Approve/Reject Advance Application (Authorize person only) ---------------------------POST
  static Future<dynamic> approveAdvanceApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.approveAdvanceApplication,
      data: data,
    );
    return response.data;
  }

  // ----------------------- Get Advance Reasons ---------------------------GET
  static Future<dynamic> getAdvanceReasons(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getAdvanceReason,
      query: data,
    );

    return response.data;
  }

  // ----------------------- Get Vehicle Booking Application List For Approval ---------------------------GET
  static Future<dynamic> getVehicleBookingAppList(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.get(
      ApiConstants.getVehicleBookingAppList,
      query: data,
    );

    return response.data;
  }

  // ----------------------- selfRejectVehicleBooking ---------------------------POST
  static Future<dynamic> selfRejectVehicleBooking(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.selfRejectVehicleBooking,
      data: data,
    );

    return response.data;
  }

  // ----------------------- Get Vehicle Booking Application List For Approval (Authorization) ---------------------------GET
  static Future<dynamic> getVehicleBookingApprovalList(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.get(
      ApiConstants.getVehicleBookingApprovalList,
      query: data,
    );

    return response.data;
  }

  //------------------------------------- Get Visitor Code -------------------------------------------------GET
  static Future<dynamic> getVisitorCode(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getVisitorCode,
      query: data,
    );

    return response.data;
  }

  //------------------------------------- Get Visitor Name -------------------------------------------------GET
  static Future<dynamic> getVisitorsName(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getVisitorsName,
      query: data,
    );

    return response.data;
  }

  //--------------------- Get Company Names for Visitor Management -----------------------------GET
  static Future<dynamic> getCompanyNames(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getCoompanyNames,
      query: data,
    );

    return response.data;
  }

  //------------------- Get Whoom To Meet Employee List ----------------------------GET
  static Future<dynamic> getWhoomToMeetList(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getWhoomToMeetList,
      query: data,
    );

    return response;
  }

  //--------------------- Save Visitor Entry -----------------------------POST
  static Future<dynamic> saveVisitorEntry(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.saveVisitorEntry,
      data: data,
    );

    return response.data;
  }

  //--------------------- Get Data Alert Visitor ---------------------------POST
  static Future<dynamic> getDataAlertVisitor(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getDataAlertVisitor,
      data: data,
    );

    return response.data;
  }

  ///----------------------- Get Shift Time ---------------------------GET
  static Future<dynamic> getShiftTime(Map<String, dynamic> data) async {
    final response = await ApiClient.get(
      ApiConstants.getShiftTime,
      query: data,
    );

    return response.data;
  }

  //----------------------- Get Status Of Visitor ---------------------------POST
  static Future<dynamic> getStatusOfVisitor(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getStatusOfVisitor,
      data: data,
    );

    return response.data;
  }

  //----------------------- Get Visitor Pass List ---------------------------POST
  static Future<dynamic> getVisitorPass(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      ApiConstants.getVisitorPass,
      data: data,
    );

    return response.data;
  }

  //----------------------- Get Visitor Departure Data ---------------------------POST
  static Future<dynamic> getVisitorDepartureData(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.getVisitorDepartureData,
      data: data,
    );

    return response.data;
  }

  //----------------------- Get Visitor Register Data ---------------------------POST
  static Future<dynamic> getVisitorRegisterData(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.getVisitorRegisterData,
      data: data,
    );

    return response.data;
  }

  

}
