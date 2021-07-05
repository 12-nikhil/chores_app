import 'package:chores_app/utils/Utils.dart';
class DBGroup{
  int id;
  int groupId;
  String name;
  String mobile;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      gpId: groupId,
      groupName: name,
      groupMobile: mobile
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  DBGroup();

  DBGroup.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    groupId = map[gpId];
    name = map[groupName];
    mobile = map[groupMobile];
  }

}