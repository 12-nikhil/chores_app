import 'package:chores_app/utils/Utils.dart';

class DBTask {
  int id;
  int tId;
  int assigneeId;
  int memberId;
  int groupId;
  int recurringTaskId;
  String taskName;
  String taskDescription;
  int taskPoint;
  String taskType;
  String custom;
  String dueDate;
  String dueTime;
  int scored;
  String status;
  String lastUpdatedDate;

  DBTask();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      taskId: tId,
      tAssigneeId: assigneeId,
      tMemberId: memberId,
      tGroupId: groupId,
      tName: taskName,
      tDescription: taskDescription,
      tType: taskType,
      tCustom: custom,
      tDueDate: dueDate,
      tDueTime: dueTime,
      tStatus: status,
      tScore: scored,
      tPoint: taskPoint,
      tLastUpdatedDate: lastUpdatedDate,
      tRecurringTaskId: recurringTaskId
    };
    if (tId != null) {
      map[taskId] = tId;
    }
    return map;
  }

  DBTask.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    tId = map[taskId];
    assigneeId = map[tAssigneeId];
    memberId = map[tMemberId];
    taskName = map[tName];
    taskDescription = map[tDescription];
    taskType = map[tType];
    custom = map[tCustom];
    dueDate = map[tDueDate];
    dueTime = map[tDueTime];
    groupId = map[tGroupId];
    taskPoint = map[tPoint];
    scored = map[tScore];
    status = map[tStatus];
    lastUpdatedDate = map[tLastUpdatedDate];
    recurringTaskId = map[tRecurringTaskId];
  }
}
