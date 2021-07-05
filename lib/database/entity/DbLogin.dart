import 'package:chores_app/utils/Utils.dart';

class DbLogin{
  int id;
  int userId;
  String name;
  String mobile;
  String role;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      uId: userId,
      uName: name,
      uMobile: mobile,
      uRole: role
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  DbLogin();

  DbLogin.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userId = map[uId];
    name = map[uName];
    mobile = map[uMobile];
    role = map[uRole];
  }

}