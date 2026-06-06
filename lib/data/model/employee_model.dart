class EmployeeModel {
  final int empPk;
  final String empCode;
  final String employeeName;
  final String departmentName;

  EmployeeModel({
    required this.empPk,
    required this.empCode,
    required this.employeeName,
    required this.departmentName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empPk: json['Emp_Pk'] ?? 0,
      empCode: json['empCode'] ?? "",
      employeeName: json['empName'] ?? "",
      departmentName: json['Department'] ?? "",
    );
  }
}