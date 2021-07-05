import 'package:chores_app/utils/Utils.dart';

class DbInvitation{
  int id;
  int uId;
  int groupId;
  String adminName;
  String adminMobile;
  String groupName;
  String role;

  DbInvitation();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId:id,
      iUId:uId,
      iGId:groupId,
      iAdminName: adminName,
      iAdminMobile: adminMobile,
      iRole: role,
      iGroupName:groupName,
    };
    if (uId != null) {
      map[iUId] = uId;
    }
    return map;
  }

  DbInvitation.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    uId = map[iUId];
    groupId = map[iGId];
    groupName = map[iGroupName];
    adminName = map[iAdminName];
    adminMobile = map[iAdminMobile];
    role = map[iRole];
  }
}