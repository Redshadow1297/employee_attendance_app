class ApiConstants {
  static const String baseUrl =
      // "http://192.168.7.179/PM_Flutter/"; ////PSPravin_UATLINK
      "http://103.19.136.117/Pravin_Flutter_12_Jan/";//PsPravin36
      // "http://103.229.5.175/flutter_demo_to_client_sir/"; ////Flutter Demo to client sir


  // ------------------- Auth -------------------
  static const String login = "Common_Services.svc/DoLogin";

  // ------------------- User -------------------
  static const String getUserProfile = "Common_Services.svc/GetUserProfile";
  static const String getUserModules = "Common_Services.svc/GetUserModules";

  // ------------------- Punch In / Out -------------------
  static const String punchInOut =
      "Leave_Services.svc/AttendaceApplicationWithLocation";

  // ------------------- Common -------------------
  static const String getLastLoginDetails = "Common_Services.svc/getlogininfo";
  static const String getCurrentDate = "Leave_Services.svc/CurrentDate";
  static const String searchEmployeeNameCode =
      "Leave_Services.svc/AutoCompleteData_AttendanceApplication";
  static const String getCompanyGroupList =
      "Leave_Services.svc/GetCompanyGroup";
    // ------------------- Wall Post -------------------
  static const String getWallPosts = "Common_Services.svc/GetWallPost";


  // ------------------- Leave -------------------
  static const String getLeaveStatus = "Leave_Services.svc/GetLeaveStatus";
  static const String getLeaveType = "Leave_Services.svc/GetLeavesList";
  static const String getLeaveBalance = "Leave_Services.svc/GetLeaveBalance";
  static const String getShiftTime = "Leave_Services.svc/GetDefaultshiftTimings?Emp_PK=";
  static const String shortLeaveURL = "Leave_Services.svc/ShortLeaveApplication";
  static const String leaveSelfReject = "Leave_Services.svc/leaveSelfReject";
  static const String submitLeaveApplication =
      "Leave_Services.svc/LeaveApplication";
  static const String getLeaveAuthorization =
      "Leave_Services.svc/GetLeaveApprovalList";


  // ------------------- Attendance -------------------
  static const String getAttendanceStatus =
      "Leave_Services.svc/GetAttendanceStatus";
  static const String getTimeCardData = "Leave_Services.svc/GetTimeCard";
  static const String approveAttendanceApplication =
      "Leave_Services.svc/ApproveAttendanceApplication";
  static const String submitAttendanceApplication =
      "Leave_Services.svc/AttendaceApplication";
  static const String getAttendanceApprovalList =
      "Leave_Services.svc/GetAttendaceAppApprovalList";
  static const String getTodaysAttendance =
      "Leave_Services.svc/TodaysAttendance";
  static const String selfRejectAttendance =
      "Leave_Services.svc/AttendanceSelfReject";
  static const String attendanceApplicationApproveORReject =
      "Leave_Services.svc/ApprovedAttendaceApplication";
  

  //-------------------- Advance -------------------
  static const String getAdvanceStatus = "Advance.svc/GetAdvanceStatus";
  static const String getAdvanceApprovalList =
      "Advance.svc/GetAdvanceApprovalList";
  static const String getAdvanceDetails = "Advance.svc/GetAdvanceDetails";
  static const String submitAdvanceApplication = "Advance.svc/SaveAdvance";
  static const String getAdvanceReason = "Advance.svc/GetAdvanceReasons";
  static const String approveAdvanceApplication =
      "Advance.svc/AdvanceAuthorization";


  // ------------------- Vehicle Requisition -------------------
  static const String getVehicleBookingAppList =
      "Vehicle.svc/GetMyVehicleBookings";
  static const String selfRejectVehicleBooking =
      "Vehicle.svc/selfRejectVehicleBooking";
  static const String getVehicleBookingApprovalList =
      "Vehicle.svc/GetVehicleBookingForApproval";
      

  ///------------------- Visitor Management -------------------
  static const String getVisitorCode = "Visitor_Services.svc/GetVisitorCode";
  static const String getVisitorsName = "Visitor_Services.svc/GetVisitorName";
  static const String getCoompanyNames = "Visitor_Services.svc/GetOrgnizationName";
  static const String saveVisitorEntry = "Visitor_Services.svc/Insert_VisitorEntry";
  static const String getDataAlertVisitor = "Visitor_Services.svc/GetDataApproval_Visitor";
  static const String getWhoomToMeetList = "Visitor_Services.svc/getActiveEmployeeList";
  static const String getStatusOfVisitor = "Visitor_Services.svc/GetStatusOfVisitorData";
  static const String getVisitorPass = "Visitor_Services.svc/GetListVisitorPassData";
  static const String getVisitorDepartureData = "Visitor_Services.svc/GetDataVisitorDepa_List";
  static const String getVisitorRegisterData = "Visitor_Services.svc/Display_VisitorRegisterData";


  ///----------------- Clearance Management --------------------
  static const String getClearanceApprovalList = "Resignation_Clearance_Services.svc/GetClearanceApprovalList";
  static const String getClearanceApprovalDetails = "Resignation_Clearance_Services.svc/GetClearanceApprovalDetails";
  static const String saveClearanceApprovalDetails = "Resignation_Clearance_Services.svc/SaveClearanceApp";

}
