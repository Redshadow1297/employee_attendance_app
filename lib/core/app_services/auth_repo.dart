import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  static Future<bool> login(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear old session

      final response = await ApiClient.post(
        ApiConstants.login,
        data: {"UserName": username, "CONFPass": password},
      );

      if (response.data['DoLoginResult']["Respons"] == "OK") {
        final result = response.data['DoLoginResult'];

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("employeecode", result['Employee_Code']);
        await prefs.setInt(
          "emppk",
          int.tryParse(result['Emp_PK'].toString()) ?? 0,
        );
        await prefs.setInt("deptpk", result['Dept_PK']);
        await prefs.setInt("companypk", result['Company_PK']);
        await prefs.setInt("locationpk", result['Location_PK']);
        await prefs.setString("isAllowTracking", result['IsAllowTracking']);
        await prefs.setString("issuperadmin", result['IsSuperAdmin']);
        await prefs.setString("employeename", result['Employee_Name']);
        await prefs.setInt("loginid", result['Login_ID']);
        await prefs.setString("username", result['username']);
        await prefs.setString("welcomeName", result['welcomeName']);
        await prefs.setString("profileImage", result['photo']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
/////isLoggedInFlag
  static Future<void> saveLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
