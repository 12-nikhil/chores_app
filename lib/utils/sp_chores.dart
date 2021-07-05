import 'package:chores_app/utils/chores_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUserRole() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(SP_ROLE) ?? null;
}

Future<int> getUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(SP_USER_ID) ?? 0;
}
Future<int> getGroupId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(SP_GROUP_ID) ?? 0;
}