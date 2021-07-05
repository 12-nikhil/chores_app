import 'package:chores_app/utils/Utils.dart';

class DbRecurringTask{
  int id;
  int taskId;
  String taskType;
  String customDay;
  String lastUpdateDate;
  String status;

  DbRecurringTask();

  /*Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId:id,
      rTaskId:taskId,
      rTaskType:taskType,
      rCustomDay: customDay,
      rLastUpdatedDate: lastUpdateDate,
      rStatus: status
    };
    if (taskId != null) {
      map[rTaskId] = taskId;
    }
    return map;
  }

  DbRecurringTask.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    taskId = map[rTaskId];
    taskType = map[rTaskType];
    customDay = map[rCustomDay];
    lastUpdateDate = map[rLastUpdatedDate];
    status = map[rStatus];
  }*/
}