// ─────────────────────────────────────────────────────────────
//  DATA MODEL  –  all fields needed by both In and Out punch
class PunchRequestData {
  final String empPk;
  final String employeeCode;
  final String attendanceDate;
  final String applicationDate;
  final String deviceId;
  final String latitude;
  final String longitude;
  final String locationPk;
  final String companyPk;
  final String address;
  final String batteryLevel;
  /// "ONLINE" | "OFFLine"
  final String data;
  /// "ON" | "OFF"  (whether GPS is enabled)
  final String location;
  final String inTime;
  final String outTime;

  /// "0" = in-punch, "1" = out-punch  
  final String inOrOut;

  const PunchRequestData({
    required this.empPk,
    required this.employeeCode,
    required this.attendanceDate,
    required this.applicationDate,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.locationPk,
    required this.companyPk,
    required this.address,
    required this.batteryLevel,
    required this.data,
    required this.location,
    required this.inTime,
    required this.outTime,
    required this.inOrOut,
  });

  Map<String, dynamic> toJson({required String overrideInOrOut}) => {
    "Emp_PK": empPk,
    "Employee_Code": employeeCode,
    "Status": "",
    "AttendanceDate": attendanceDate,
    "DeviceID": deviceId,
    "Latitude": latitude,
    "Data": data,
    "InOrOUT": overrideInOrOut,
    "ApplicationDate": applicationDate,
    "Longitude": longitude,
    "Location_PK": locationPk,
    "Company_PK": companyPk,
    "batterylevel": batteryLevel,
    "TimeCard": 1,
    "Location": location,
    "Address": address,
    "InTime": inTime,
    "OutTime": outTime,
  };
}
