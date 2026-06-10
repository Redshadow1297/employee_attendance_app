// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  // ignore: prefer_typing_uninitialized_variables
  var newdb;
  static Database? _db;
  int? result;
  static int? countDb;
  User? user;
  Future<Database?> get db async { 
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'PeopleScope.db');
    newdb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return newdb;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE User (_id INTEGER PRIMARY KEY, Location_PK TEXT, Emp_PK TEXT, Status TEXT, Address TEXT, Company_PK TEXT, AttendanceDate TEXT,Latitude TEXT, InOrOUT TEXT, TimeCard TEXT, ApplicationDate TEXT, Longitude TEXT, AllowTracking TEXT,InTime TEXT, OutTime TEXT, Device_Id TEXT, Data TEXT, Location TEXT, batterylevel TEXT, Division_Pk, Site_Pk, Shift_Pk)');
        await db.execute(
        'CREATE TABLE Geofenceadd (id_Geo INTEGER PRIMARY KEY, LATITUDE TEXT, LONGITUDE TEXT, RADIUS TEXT, LOCATION_NAME TEXT)');
  }


  Future<Geofenceadd> addGeo(Geofenceadd Geofenceadd) async {
    var dbClient = await db;
    Geofenceadd.id_Geo =
        await dbClient!.insert('Geofenceadd', Geofenceadd.toJson());
    return Geofenceadd;
  }

    Future<int?> getCountGeo() async {
    Database? mydb = await db;
    result = Sqflite.firstIntValue(
        await mydb!.rawQuery("SELECT COUNT (*) FROM Geofenceadd"));
    debugPrint("Geofenceadd++  $result");
    countDb = result;
    debugPrint(countDb as String?);
    return result;
  }

  Future<User> add(User User) async {
    var dbClient = await db;
    User.id = await dbClient!.insert('User', User.toJson());
    return User;
  }

 // fetch user data
  Future<List<User>> getUsers() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!.query('User', columns: [
      '_id'
      'Location_PK',
      'Emp_PK',
      'Status',
      'Address',
      'Company_PK',
      'AttendanceDate',
      'Latitude',
      'InOrOut',
      'TimeCard',
      'ApplicationDate',
      'Longitude',
      'AllowTracking',
      'InTime',
      'OutTime',
      'Device_Id',
      'Data',
      'Location',
      'batterylevel'
    ]);
    List<User> users = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        users.add(User.fromJson(maps[i]));
      }
    }
    debugPrint("Length::$users");
    return users;
  }

  //to Count number of items in SQLite
 Future<int?> getCount() async {
    Database? mydb = await db;
    result = Sqflite.firstIntValue(
        await mydb!.rawQuery("SELECT COUNT (*) FROM User"));
    debugPrint("USERCount++$result");
    countDb = result;
    debugPrint(countDb as String?);
    return result;
  }

  // fetch and return a list from the database:
  Future<List<Map<String, dynamic>>> getAllEmployees(String Dbname) async {
    final db1 = await db;
    List<Map<String, dynamic>> maps = await db1!.query(Dbname);
    return maps;
  }

  Future<int> deleteAlldata(String dbName) async {
    var dbClient = await db;
    return await dbClient!.delete(dbName);
  }

  //delete record from db
  Future<int> delete(int id) async {
    Database? mydb = await db;
    return await mydb!.delete(
      'User',
      where: '_id = ?',
      whereArgs: [id],
    );
  }

   //update the data in db
  Future<int> update(User User) async {
    var dbClient = await db;
    return await dbClient!.update(
      'User',
      User.toJson(),
      where: 'id = ?',
      whereArgs: [User.id],
    );
  }

 //to close db
  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

}

class Geofenceadd {
  int? id_Geo;
  String? Latitude_Geo;
  String? Longitude_Geo;
  String? Radius_Geo;
  String? Location_name_Geo;

  final String tableUser = 'Geofenceadd';
  final String FIELD_ROW_ID = "id_Geo";
  final String FIELD_Latitude = "LATITUDE";
  final String FIELD_Longitude = "LONGITUDE";
  final String FIELD_Radius = "RADIUS";
  final String FIELD_Location_name = "LOCATION_NAME";

  Geofenceadd(
    // this.id_Geo,
    this.Latitude_Geo,
    this.Longitude_Geo,
    this.Radius_Geo,
    this.Location_name_Geo,
  );

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      FIELD_ROW_ID: id_Geo,
      FIELD_Latitude: Latitude_Geo,
      FIELD_Longitude: Longitude_Geo,
      FIELD_Radius: Radius_Geo,
      FIELD_Location_name: Location_name_Geo,
    };
    if (id_Geo != null) {
      map[FIELD_ROW_ID] = id_Geo;
    }
    return map;
  }

  Geofenceadd.fromJson(Map<String, dynamic> map) {
    id_Geo = map[FIELD_ROW_ID];
    Latitude_Geo = map[FIELD_Latitude];
    Longitude_Geo = map[FIELD_Longitude];
    Radius_Geo = map[FIELD_Radius];
    Location_name_Geo = map[FIELD_Location_name];

    debugPrint("NEW_id_DB_DATA:$id_Geo");
    debugPrint("NEW_id_DB_DATA:$Latitude_Geo");
    debugPrint("NEW_id_DB_DATA:$Longitude_Geo");
    debugPrint("NEW_id_DB_DATA$Radius_Geo");
    debugPrint("NEW_id_DB_DATA$Location_name_Geo");
  }
}

class User {
  final String tableUser = 'user';
  final String FIELD_ROW_ID = "_id";
  final String FIELD_Location_PK = "Location_PK";
  final String FIELD_Emp_PK = "Emp_PK";
  final String FIELD_Status = "Status";
  final String FIELD_Address = "Address";
  final String FIELD_Company_PK = "Company_PK";
  final String FIELD_AttendanceDate = "AttendanceDate";
  final String FIELD_Latitude = "Latitude";
  final String FIELD_InOrOUT = "InOrOUT";
  final String FIELD_TimeCard = "TimeCard";
  final String FIELD_ApplicationDate = "ApplicationDate";
  final String FIELD_Longitude = "Longitude";
  final String FIELD_AllowTracking = "AllowTracking";
  final String FIELD_INTIME = "InTime";
  final String FIELD_DEVICEID = "Device_Id";
  final String FIELD_OUTTIME = "OutTime";
  final String FIELD_DATA = "Data";
  final String FIELD_LOCATION = "Location";
  final String FIELD_BATTERY = "batterylevel";


  int? id;
  String? location_PK;
  String? emp_PK;
  String? status;
  String? address;
  String? company_PK;
  String? attendanceDate;
  String? latitude;
  String? inOrOUT;
  String? timeCard;
  String? applicationDate;
  String? Longitude;
  String? allowTracking;
  String? inTime;
  String? device_Id;
  String? outTime;
  String? data;
  String? location;
  String? battery;


  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      FIELD_ROW_ID: id,
      FIELD_Location_PK: location_PK,
      FIELD_Emp_PK: emp_PK,
      FIELD_Status: status,
      FIELD_Address: address,
      FIELD_Company_PK: company_PK,
      FIELD_AttendanceDate: attendanceDate,
      FIELD_Latitude: latitude,
      FIELD_InOrOUT: inOrOUT,
      FIELD_TimeCard: timeCard,
      FIELD_ApplicationDate: applicationDate,
      FIELD_Longitude: Longitude,
      FIELD_AllowTracking: allowTracking,
      FIELD_INTIME: inTime,
      FIELD_DEVICEID: device_Id,
      FIELD_OUTTIME: outTime,
      FIELD_DATA: data,
      FIELD_LOCATION: location,
      FIELD_BATTERY: battery,
    };
    if (id != null) {
      map[FIELD_ROW_ID] = id;
    }
    return map;
  }

  // User();
  User(
      this.location_PK,
      this.emp_PK,
      this.status,
      this.address,
      this.company_PK,
      this.attendanceDate,
      this.latitude,
      this.inOrOUT,
      this.timeCard,
      this.applicationDate,
      this.Longitude,
      this.allowTracking,
      this.inTime,
      this.outTime,
      this.device_Id,
      this.data,
      this.location,
      this.battery);

  User.fromJson(Map<String, dynamic> map) {
    id = map[FIELD_ROW_ID];
    debugPrint("NEW_id_DB_DATA:$id");
    location_PK = map[FIELD_Location_PK];
    emp_PK = map[FIELD_Emp_PK];
    debugPrint("NEW_emp_PK_DB_DATA:$emp_PK");

    status = map[FIELD_Status];
    debugPrint("NEW_Status_DB_DATA:$status");

    address = map[FIELD_Address];
    company_PK = map[FIELD_Company_PK];
    attendanceDate = map[FIELD_AttendanceDate];
    latitude = map[FIELD_Latitude];
    inOrOUT = map[FIELD_InOrOUT];
    timeCard = map[FIELD_TimeCard];
    applicationDate = map[FIELD_ApplicationDate];
    Longitude = map[FIELD_Longitude];
    allowTracking = map[FIELD_AllowTracking];
    inTime = map[FIELD_INTIME];
    outTime = map[FIELD_OUTTIME];
    device_Id = map[FIELD_DEVICEID];
    data = map[FIELD_DATA];
    location = map[FIELD_LOCATION];
    battery = map[FIELD_BATTERY];
  }
  
}







