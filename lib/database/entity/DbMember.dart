import 'package:chores_app/utils/Utils.dart';
class DBMember{
  int id;
  int uId;
  int groupId;
  String memberName;
  String memberMobile;
  String memberStatus;
  String memberRole;
  String memberCreationDate;

  DBMember();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId:id,
      userId:uId,
      gId:groupId,
      name: memberName,
      mobile: memberMobile,
      role: memberRole,
      status:memberStatus,
      createdDate:memberCreationDate
    };
    if (uId != null) {
      map[userId] = uId;
    }
    return map;
  }

  DBMember.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    uId = map[userId];
    groupId = map[gId];
    memberName = map[name];
    memberMobile = map[mobile];
    memberRole = map[role];
    memberStatus = map[status];
    memberCreationDate = map[createdDate];
  }

}