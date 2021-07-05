import 'dart:convert';

import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbInvitation.dart';
import 'package:chores_app/database/entity/DbLogin.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/GroupMember.dart';
import 'package:chores_app/models/Task.dart';
import 'package:chores_app/models/TaskMember.dart';
import 'package:chores_app/models/notificationBody/NotificationAcceptedMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskAccepted.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskReceive.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskRecurringIDs.dart';
import '../../database/DatabaseHelper.dart';
import '../../database/entity/DbMember.dart';
import '../../ui/create_group.dart';
import '../../ui/main_dashboard_screen.dart';
import '../../utils/chores_constant.dart';

Future getGroupAndMemberByMobileFromServer(
    BuildContext context, SharedPreferences sp,int userId, int groupId) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  var mobileNumber = await sp.getString("mobile");
  var response = await getGroupDataFromServer(groupId);
  if (response != null) {
    GroupMember group = GroupMember.fromJson(json.decode(response));
    if (group != null) {
      DBGroup dbGroup = DBGroup();
      dbGroup.groupId = group.groupId;
      dbGroup.name = group.groupName;
      dbGroup.mobile = mobileNumber;
      // dbGroup.mobile = group.mobile;
      var dbHelper = DatabaseHelper();
      List<UserInfo> userInfoList = group.userInfo;
      await dbHelper.insert(dbGroup).then((value) => {
            sp.setString(SP_GROUP_ID, group.groupId.toString()),
            sp.setString(SP_GROUP_NAME, group.groupName),
            saveMemberDataInLocalDB(context,dbHelper, userInfoList,userId,groupId,sp),
          });
    }
  }else{
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => CreateGroup()),
            (Route<dynamic> route) => false);
  }
}

Future<List<DBMember>> saveMemberDataInLocalDB(
    BuildContext context,
    DatabaseHelper dbHelper,
    List<UserInfo> userInfoList,
    int userId,
    int groupId,
    SharedPreferences sp) async {
  List<DBMember> dbMemberList = List();
  await dbHelper
      .insertMemberList(userInfoList, userId, groupId)
      .then((value) => {
            print("List of member ${value.length}"),
            if (value != null && value.length > 0)
              {
                openNewScreen(context, dbHelper, sp),
              }
          });
  return dbMemberList;
}

Future<void> openNewScreen(
    BuildContext context, DatabaseHelper dbHelper, SharedPreferences sp) async {
  String role = sp.getString(SP_ROLE);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(
                  lohginRole: role,
                  pageIndex: 0,
                )),
        (Route<dynamic> route) => false);
}

void createUserInfo(DatabaseHelper dbHelper, SharedPreferences sp,
    String userMobile, List<UserInfo> userInfoList) {
  int count = 0;
  for (UserInfo userInfo in userInfoList) {
    count++;
    if (userMobile == userInfo.mobile) {
      sp.setInt(SP_USER_ID, userInfo.userId);
      sp.setString(SP_ROLE, userInfo.role);
    }
    DBMember dbMember = DBMember();
    dbMember.uId = userInfo.userId;
    dbMember.memberName = userInfo.name;
    dbMember.memberMobile = userInfo.mobile;
    dbMember.memberRole = userInfo.role;
    dbMember.memberStatus = userInfo.status;
    dbMember.memberCreationDate = userInfo.createdDate;
    dbHelper.insertMember(dbMember).then((value) => {});
  }
}

/*Future addTAskDetailsInLocal(NotificationTaskComplete taskComplete) async {
  DBTask dbTask = DBTask();
  dbTask.tId = taskComplete.taskId;
  dbTask.assigneeId = taskComplete.adminId;
  dbTask.memberId = taskComplete.memberId;
  dbTask.taskName = taskComplete.taskName;
  dbTask.taskDescription = taskComplete.taskDescription;
  dbTask.taskType = taskComplete.taskType;
  dbTask.custom = taskComplete.custom;
  dbTask.dueDate = taskComplete.dueDate;
  dbTask.dueTime = taskComplete.dueTime;
  dbTask..taskPoint = taskComplete.taskPoint;
  dbTask..lastUpdatedDate = getCurrentDate();
  var dbHelper = DatabaseHelper();
  await dbHelper
      .insertTask(dbTask)
      .then((value) => {print('Task Insert ${value}')});
}*/

// ignore: missing_return
Future removeTaskFromLocalDB(int taskID) async {
  var dbHelper = DatabaseHelper();
  await dbHelper.getDbTaskByRecurringTaskId(taskID).then((value) => {
        if (value != null && value.length > 0)
          {
            dbHelper.deleteTaskList(value).then((value) => {}),
          },
        dbHelper
            .deleteTask(taskID)
            .then((value) => {print("Task Deleted $value")}),
      });
}

// ignore: missing_return
Future<int> removeMemberFromLocalDB(int memberId) async {
  var dbHelper = DatabaseHelper();
  var id = 0;
  await dbHelper.deleteMember(memberId).then((value) => {
        print("Member Deleted $value"),
        id = value,
      });
  return id;
}

// ignore: missing_return
Future<int> removeGroupFromLocalDB(int groupId) async {
  var dbHelper = DatabaseHelper();
  int id;
  dbHelper.deleteGroup(groupId).then((value) => {
        print("Group Deleted ${value}"),
        // remove task and Member table too
        removeGroupTableFromLocalDB(),
        removeMemberTableFromLocalDB(),
        removeTaskTableFromLocalDB(),
        removeInvitaionTableFromLocalDB(),
        removeLoginTableFromLocalDB(),
        clearSharedPreference(),
        id = value,
      });
  return id;
}

// ignore: missing_return
Future removeGroupTableFromLocalDB() {
  var dbHelper = DatabaseHelper();
  dbHelper.deleteGroupTable();
}

// ignore: missing_return
Future removeMemberTableFromLocalDB() {
  var dbHelper = DatabaseHelper();
  dbHelper.deleteMemberTable();
}

// ignore: missing_return
Future removeTaskTableFromLocalDB() {
  var dbHelper = DatabaseHelper();
  dbHelper.deleteTaskTable();
}

Future removeInvitaionTableFromLocalDB() {
  var dbHelper = DatabaseHelper();
  dbHelper.deleteInvitation();
}

Future removeLoginTableFromLocalDB() {
  var dbHelper = DatabaseHelper();
  dbHelper.deleteTaskTable();
}

Future<void> saveTaskDetailsInDB(
    NotificationTaskReceived notificationTaskReceived,
    String role,
    int userId) async {
  var dbHelper = DatabaseHelper();
  DBTask dbTask = DBTask();
  dbTask.tId = notificationTaskReceived.taskId;
  dbTask.taskName = notificationTaskReceived.taskName;
  dbTask.taskDescription = notificationTaskReceived.taskDescription;
  dbTask.groupId = notificationTaskReceived.group_id;
  dbTask.memberId = notificationTaskReceived.memberUserId;
  dbTask.assigneeId = notificationTaskReceived.adminUserId;
  dbTask.custom = notificationTaskReceived.custom;
  dbTask.taskType = notificationTaskReceived.taskType;
  dbTask.status = notificationTaskReceived.status;
  dbTask.taskPoint = notificationTaskReceived.taskPoint;
  dbTask.dueDate = notificationTaskReceived.dueDate.replaceAll(r'\', r'');
  dbTask.dueTime = notificationTaskReceived.dueTime;
  dbTask.scored = notificationTaskReceived.score;
  dbTask.lastUpdatedDate = getCurrentDate().trim();
  //if (notificationTaskReceived.adminUserId != userId) {
  await dbHelper.insertTask(dbTask).then((value) => {});
  //}
}

Future<void> saveRecurringTaskListInDB(
    NotificationTaskRecurringIDs rIds, int userId) async {
  print("Data recurrig call ${rIds}");
  var dbHelper = DatabaseHelper();
  int recurringTaskId = rIds.recurringTaskId;
  await dbHelper.getDbTaskByTaskId(recurringTaskId).then((value) => {
        if (value != null)
          {
            saveTaskFromRecurringTask(dbHelper, rIds, value, userId),
          }
      });
}

Future saveTaskFromRecurringTask(DatabaseHelper dbHelper,
    NotificationTaskRecurringIDs rIds, DBTask recurringTask, int userId) async {
  int recurringId = rIds.recurringTaskId;
  List<dynamic> taskIdList = [];
  taskIdList = rIds.taskIds;
  DateTime from = getDateTimeDate(rIds.fromDate);
  DateTime to = getDateTimeDate(rIds.toDate);
  List<DateTime> selectedDateList = [];
  selectedDateList = getDaysInBetween(from, to);
  List<DBTask> taskList = List();
  List<int> tdList = List();
  print("Task Id list ${taskIdList}");
  for (int i = 0; i < taskIdList.length; i++) {
    DBTask dbTask = DBTask();
    dbTask.tId = int.parse(taskIdList[i]);
    tdList.add(dbTask.tId);
    dbTask.taskName = recurringTask.taskName;
    dbTask.taskDescription = recurringTask.taskDescription;
    //dbTask.groupId= notificationTaskReceived.
    dbTask.groupId = recurringTask.groupId;
    dbTask.memberId = recurringTask.memberId;
    dbTask.assigneeId = recurringTask.assigneeId;
    dbTask.taskType = ONE_TIME;
    dbTask.status = recurringTask.status;
    dbTask.taskPoint = recurringTask.taskPoint;
    dbTask.dueDate = getFormatedDate(selectedDateList[i]);
    dbTask.dueTime = recurringTask.dueTime;
    dbTask.scored = recurringTask.scored;
    dbTask.lastUpdatedDate = getCurrentDate().trim();
    dbTask.recurringTaskId = recurringId;
    taskList.add(dbTask);
  }
  print("taskList ${taskList}");
  await dbHelper.insertTaskList(taskList).then((value) => {
        print("data save successfully ${value}"),
        taskDataReceived(tdList, recurringTask.groupId, userId),
      });
}

Future updateUserStatusLocalDB(
    NotificationAcceptedMember acceptedMember) async {
  var dbHelper = DatabaseHelper();
  await dbHelper
      .updateMemberStatus(acceptedMember.userId, acceptedMember.status)
      .then((value) => {
            print("Group Accepted member ${value}"),
          });
}

Future updateTaskStatusLocalDB(NotificationTaskComplete taskComplete) async {
  var dbHelper = DatabaseHelper();
  await dbHelper
      .updateTaskStatus(
          taskComplete.taskId, taskComplete.status, taskComplete.scored)
      .then((value) => {
            print("Task Completed status ${value}"),
            //saveRecurringTaskDetails(dbHelper, taskComplete.taskId,taskComplete.taskType,taskComplete.status)
          });
}

/*Future<void> saveRecurringTaskDetails(
    DatabaseHelper dbhelper,int taskId,String taskType,String status) async {
  if (RECURRING == taskType) {
    DbRecurringTask recurringTask = DbRecurringTask();
    recurringTask.taskId = taskId;
    recurringTask.taskType = taskType;
    recurringTask.customDay = getCurrentDay();
    recurringTask.lastUpdateDate = getCurrentDate();
    recurringTask.status = status;
    await dbhelper.insertRecurringTask(recurringTask);
  }
}*/

Future updateTaskStatusWithScoreLocalDB(TaskAcceptReject taskComplete) async {
  var dbHelper = DatabaseHelper();
  await dbHelper
      .updateTaskStatus(
          taskComplete.taskId, taskComplete.taskStatus, taskComplete.taskScore)
      .then((value) => {
            print("Task Accept/Reject status ${value}"),
            //saveRecurringTaskDetails(dbHelper, taskComplete.taskId,taskComplete.taskType,taskComplete.taskStatus)
          });
}

Future<DBTask> getTaskDetailsByTaskId(
    NotificationTaskComplete taskComplete) async {
  DBTask dbTask = DBTask();
  var dbHelper = DatabaseHelper();
  dbTask = await dbHelper.getDbTaskByTaskId(taskComplete.taskId);
  dbTask.status = taskComplete.status;
  return dbTask;
}

Future<String> getLoginRole() async {
  var loginRole;
  SharedPreferences sp = await SharedPreferences.getInstance();
  loginRole = await sp.getString(SP_ROLE) ?? null;
  var dbHelper = DatabaseHelper();
  if (loginRole == null) {
    await dbHelper.getAllLoginDetails().then((value) => {
          if (value != null)
            {
              loginRole = value.role,
            }
        });
  }
  return loginRole;
}

Future<TaskMember> getTaskMemberByTaskCompleteNotification(
    NotificationTaskComplete taskComplete) async {
  TaskMember taskMember = TaskMember();
  taskMember.taskId = taskComplete.taskId;
  taskMember.assigneeId = taskComplete.adminId;
  taskMember.memberId = taskComplete.memberId;
  taskMember.memberName = taskComplete.memberName;
  taskMember.assigneeMobile = taskComplete.adminMobileNo;
  taskMember.taskPoint = taskComplete.taskPoint;
  taskMember.taskName = taskComplete.taskName;
  taskMember.taskDescription = taskComplete.taskDescription;
  taskMember.status = taskComplete.status;
  taskMember.dueDate = taskComplete.dueDate;
  taskMember.dueTime = taskComplete.dueTime;
  taskMember.taskType = taskComplete.taskType;
  taskMember.custom = taskComplete.custom;
  return taskMember;
}

Future<DbInvitation> saveInvitationDetailsInLocalDb(
    NotificationGroupJoin groupJoin) async {
  DbInvitation dbInvitation = DbInvitation();
  dbInvitation.uId = groupJoin.userId;
  dbInvitation.groupId = groupJoin.group_id;
  dbInvitation.groupName = groupJoin.group_name;
  dbInvitation.adminName = groupJoin.adminName;
  dbInvitation.adminMobile = groupJoin.adminMobileNumber;
  dbInvitation.role = groupJoin.role;
  var dbHelper = DatabaseHelper();
  await dbHelper.insertInvitation(dbInvitation);
  return dbInvitation;
}

/*void createRecurringTaskToOneTimeTask() async {
  try {
    print("object call ");
    var dbHelper = DatabaseHelper();
    */ /* SharedPreferences sp = await SharedPreferences.getInstance();
    String loginRole = await sp.getString(SP_ROLE);
    int userId = await sp.getInt(SP_USER_ID) ?? 0;*/ /*
    await dbHelper.getAllLoginDetails().then((value) => {
          getAllTaskFromLocalDB(dbHelper, value),
        });
    //}
  } catch (error) {
    print("Background recurring Exception ${error}");
  }
}

void getAllTaskFromLocalDB(DatabaseHelper dbHelper, DbLogin dbLogin) async {
  List<DBTask> taskList = await dbHelper.getDBAllTask();
  // if ("Admin" == loginRole) {
  if (taskList.length > 0) {
    for (DBTask task in taskList) {
      if (task.custom != null) {
        var weekDayList = task.custom.split(",");
        print("Week day list $weekDayList");
        if (weekDayList.length > 0) {
          String currentDay = getCurrentDay();
          for (String day in weekDayList) {
            if (day.trim() == currentDay.trim()) {
              print("Day match ");
              sendRecurringTAskAsOneTimeTakOnServer(
                  dbHelper, dbLogin.userId, task);
              break;
            }
          }
        }
      }
    }
  }
}

Future<void> sendRecurringTAskAsOneTimeTakOnServer(
    DatabaseHelper dbHelper, int adminId, DBTask dbTask) async {
  Task task = new Task();
  print("Inside data send ");
  task.taskName = dbTask.taskName;
  task.taskDescription = dbTask.taskDescription;
  task.taskType = ONE_TIME;
  task.dueTime = dbTask.dueTime;
  task.dueDate = getCurrentDate();
  task.taskPoint = dbTask.taskPoint;
  task.groupId = dbTask.groupId;
  List<dynamic> idList = new List();
  idList.add(dbTask.memberId);
  task.memberUserId = idList;
  task.adminUserId = dbTask.assigneeId;

  var responseTask = await createTaskOnServer(task);
  if (responseTask != null) {
    var responseJson = jsonDecode(responseTask) as List;
    List<Task> taskList =
        await responseJson.map((tagJson) => Task.fromJson(tagJson)).toList();
    // save task List in local db

    if (taskList != null) {
      print("Task list size ${taskList.length}");
      if (taskList.length > 0) {
        var dbHelper = DatabaseHelper();
        int count = 0;
        for (Task task in taskList) {
          DBTask dbTask = DBTask();
          dbTask.tId = task.taskId;
          dbTask.assigneeId = task.adminUserId;
          List<dynamic> memberList = task.memberUserId;
          dbTask.memberId = memberList[0];
          dbTask.taskName = task.taskName;
          //dbTask.groupId = sp.getString(SP_GROUP_ID) as int;
          dbTask.groupId = task.groupId;
          dbTask.taskDescription = task.taskDescription;
          dbTask.taskType = task.taskType;
          if ("Recurring" == dbTask.taskType) {
            task.dueDate = null;
          }
          dbTask.custom = task.custom;
          dbTask.dueDate = task.dueDate;
          dbTask.dueTime = task.dueTime;
          dbTask.taskPoint = task.taskPoint;
          dbTask.status = "Pending";
          dbTask.lastUpdatedDate = getCurrentDate();

          dbHelper.insertTask(dbTask).then((value) => {
                count++,
                if (count == taskList.length)
                  {
                    //dismissDialog(context),
                  }
              });
        }
      }
    }
  }
}*/
