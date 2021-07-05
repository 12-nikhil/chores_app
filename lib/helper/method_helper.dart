import 'package:chores_app/database/entity/DbInvitation.dart';
import 'package:chores_app/models/TaskMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 2,
      backgroundColor: Colors.white,
      textColor: Colors.black);
}

Future saveDataInSharedPreference(
    int userId, String role, String mobile, String name) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setInt(SP_USER_ID, userId);
  sp.setString(SP_ROLE, role);
  sp.setString(SP_NAME, name);
  sp.setString(SP_MOBILE, mobile);
}

Future saveGroupDataInSharedPreference(
    String groupId, int userId, String groupRole, String groupName) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(SP_GROUP_ID, groupId);
  sharedPreferences.setString(SP_ROLE, groupRole);
  sharedPreferences.setString(SP_GROUP_NAME, groupName);
  sharedPreferences.setInt(SP_USER_ID, userId);
}

String getDate(String dueDate) {
  var inputFormat = DateFormat('yyyy-mm-ddThh:mm:ss+00.00');
  var inputDate = inputFormat.parse(dueDate); // <-- Incoming date

  var outputFormat = DateFormat('dd/mm/yyyy');
  var outputDate = outputFormat.format(inputDate); // <-- Desired date
  print("Due date ${outputDate}");
  return outputDate;
}

DateTime getDateTimeDate(String dueDate) {
  var inputFormat = DateFormat('dd/MM/yyyy');
  var inputDate = inputFormat.parse(dueDate); // <-- Incoming date

  var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  var outputDate = outputFormat.format(inputDate);
  DateTime dt = DateTime.parse(outputDate);
  print("Due date ${outputDate}");
  return dt;
}

String getDateTimeWithWeek(String updatedDate) {
  var inputFormat = DateFormat('dd/MM/yyyy');
  var inputDate = inputFormat.parse(updatedDate); // <-- Incoming date

  var outputFormat = DateFormat('EEE, MMM d, ' 'yyyy');
  var outputDate = outputFormat.format(inputDate);
  /*DateTime dt = DateTime.parse(outputDate);*/
  print("Due date ${outputDate}");
  return outputDate;
}

DateTime getConvertStringToDate(String dueDate) {
  var parsedDate = DateTime.parse(dueDate);
  return parsedDate;
}

DateTime constructDate(DateTime date, TimeOfDay time) {
  if (date == null) {
    return null;
  }
  if (date != null && time == null) {
    return new DateTime(date.year, date.month, date.day);
  }
  return new DateTime(
      date.year, date.month, date.day, time.hour, time.minute);
}

String getCurrentDate() {
  return DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
}

String getCurrentDay() {
  var date = DateTime.now();
  String day = DateFormat('EE').format(date);
  print("Current Day ${day}");
  return day; // prin
}

String getCurrentDateTime() {
  return DateFormat('dd/MM/yyyy HH:mm aa').format(DateTime.now()).toString();
}

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}

Day getDayByDayName(String day) {
  switch (day) {
    case "Mon":
      return Day.monday;
      break;
    case "Tue":
      return Day.tuesday;
      break;
    case "Wed":
      return Day.wednesday;
      break;
    case "Thu":
      return Day.thursday;
      break;
    case "Fri":
      return Day.friday;
      break;
    case "Sat":
      return Day.saturday;
      break;
    case "Sun":
      return Day.sunday;
      break;
  }
}

void clearSharedPreference() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  await sp.clear();
}

NotificationGroupJoin createGroupJoin(DbInvitation invitation) {
  NotificationGroupJoin notificationGroupJoin = NotificationGroupJoin();
  notificationGroupJoin.userId = invitation.uId;
  notificationGroupJoin.group_id = invitation.groupId;
  notificationGroupJoin.group_name = invitation.groupName;
  notificationGroupJoin.adminName = invitation.adminName;
  notificationGroupJoin.adminMobileNumber = invitation.adminMobile;
  notificationGroupJoin.role = invitation.role;
  return notificationGroupJoin;
}

String getDayFromDateTime(DateTime date) {
  String day = DateFormat('EE').format(date);
  return day; // prin
}
// 2021-06-10 00:00:00.000
List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  //List<String> selectedDayList = ["Mon","Tue","Fri","Sun"];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  print("Day list ${days}");
  return days;
}
getFormatedDate(DateTime _date) {
 /* var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
  var inputDate = inputFormat.parse(_date);*/
 var outputFormat = DateFormat('dd/MM/yyyy');
  //var outputFormat = DateFormat('EEE dd MMM yyyy');
  return outputFormat.format(_date);
}

List<String> getRecurringDateTime(
    List<DateTime> dateTimeList, List<String> selectedDayList) {
  List<String> days = [];
  for (String selectedDay in selectedDayList) {
    for (DateTime date in dateTimeList) {
      String day = getDayFromDateTime(date).trim();
      if (selectedDay.trim() == day.trim()) {
        print("Day match ${selectedDay} and ${day}");
        days.add(getFormatedDate(date));
      }
    }
  }
  print("Selected Date ${days}");
  return days;
}
