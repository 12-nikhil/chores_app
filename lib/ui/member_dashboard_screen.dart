import 'dart:convert';

import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbLogin.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/main.dart';
import 'package:chores_app/models/GroupMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/models/notificationBody/NotificationSaveData.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/add_task_copy_screen.dart';
import 'package:chores_app/ui/admin_dashboard_screen.dart';
import 'package:chores_app/ui/create_group.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/ui/task_list_screen.dart';
import 'package:chores_app/utils/Utils.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/models/AcceptedMembers.dart';
import 'package:sqflite/sqflite.dart';

class MemberDashboardScreen extends StatefulWidget {
  final dynamic notification;
  final String titleCode;
  final isNewMember;
  final NotificationGroupJoin groupJoin;

  const MemberDashboardScreen(
      {Key key,
      this.notification,
      this.isNewMember,
      this.titleCode,
      this.groupJoin})
      : super(key: key);

  @override
  _MemberDashboardScreenState createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  NotificationGroupJoin groupJoin;
  NotificationTaskComplete taskStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setValue();
    setState(() {
      groupJoin;
      taskStatus;
    });
  }

  void setValue() async {
    print("member notification ${widget.notification}");
    try {
      if (widget.isNewMember != null) {
        // var body = widget.notification['data']['body'] ?? '';
        /*JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
        var body = jsonEncoder.convert(widget.notification);*/
        if (widget.notification != null) {
          groupJoin =
              NotificationGroupJoin.fromJson(json.decode(widget.notification));
          print("member join ${groupJoin.adminName}");
        } else {
          print("member join ${widget.groupJoin.role}");
          groupJoin = widget.groupJoin;
        }
      } else {
        // var body = widget.notification['data']['body'] ?? '';
        taskStatus =
            NotificationTaskComplete.fromJson(json.decode(widget.notification));
      }
    } catch (error) {
      print('Join Group Error ${error}');
    }
  }

  Future getTaskDetailsFromLocal(NotificationTaskComplete taskComplete) {
    var dbHelper = DatabaseHelper();
    dbHelper.getDbTaskByTaskId(taskComplete.taskId).then((value) => {
          if (value != null)
            {
              updateTaskStatus(context, taskComplete.taskId,
                      taskComplete.status, taskComplete.scored)
                  .then((value) => {
                        // open task detail page
                      })
            }
          else
            {
              // get groupDetails from mobile number
              getMemberDetailsFromLocal(context, groupJoin, status),
            }
        });
  }

  void openTaskDetailPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TaskListScreen()));
  }

  Future fetchGroupAndMemberByMobileFromServer(String status) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var mobileNumber = await sp.getString(SP_MOBILE);
    var response = await getGroupDataFromServer(groupJoin.group_id);
    if (response != null) {
      GroupMember group = GroupMember.fromJson(json.decode(response));
      if (group != null) {
        DBGroup dbGroup = DBGroup();
        dbGroup.groupId = group.groupId;
        dbGroup.name = group.groupName;
        //dbGroup.mobile = group.mobile;
        var dbHelper = DatabaseHelper();
        List<UserInfo> userInfoList = group.userInfo;
        await dbHelper.insert(dbGroup).then((value) => {
              sp.setString(SP_GROUP_ID, group.groupId.toString()),
              sp.setString(SP_GROUP_NAME, group.groupName),
              getUserInfo(dbHelper, mobileNumber, userInfoList, status),
            });
      }
    }
  }

  Future<void> getUserInfo(DatabaseHelper dbHelper,
      String userMobile, List<UserInfo> userInfoList, String status) async {
    var dbHelper = DatabaseHelper();
    String role;
    await dbHelper.insertMemberList(userInfoList, groupJoin.userId,groupJoin.group_id).then((value) => {
      print("List of member ${value.length}"),
          if (value != null && value.length > 0)
            {
              openNewScreen(status, role),
            }
        });
  }

  /* void getUserInfo(DatabaseHelper dbHelper, SharedPreferences sp,
      String userMobile, List<UserInfo> userInfoList, String status) {
    int count =0;
    for (UserInfo userInfo in userInfoList) {
      DBMember dbMember = DBMember();
      if (userInfo.userId == groupJoin.userId) {
        // save data in shared Preference for future use
        saveDataInSharedPreference(
            userInfo.userId, userInfo.role, userInfo.mobile, userInfo.name);
        // save LoginData in shared Preference for future use,cause in background sp not fetch data(only in my project)
        // cause i am using old plugin version
        saveLoginDetailsInLocalDB(userInfo);
        dbMember.memberStatus = status;
      } else {
        dbMember.memberStatus = userInfo.status;
      }
      dbMember.uId = userInfo.userId;
      dbMember.groupId = groupJoin.group_id;
      dbMember.memberName = userInfo.name;
      dbMember.memberMobile = userInfo.mobile;
      dbMember.memberRole = userInfo.role;
      dbMember.memberCreationDate = userInfo.createdDate;
      print("Invitation Member role ${userInfo.role}");
      dbHelper.insertMember(dbMember).then((value) => {
            // open admin dashboard
            //updateMemberStatus(context, userId, status)
           if(count==userInfoList.length)
             {
               print("UId ${dbMember.uId} gId ${groupJoin.userId}"),
               */ /*if (dbMember.uId == groupJoin.userId)
                 {*/ /*
                   openNewScreen(status,role),
                   */ /*sendDataOnServer(
                    context, dbMember.uId, groupJoin.adminId, status)*/ /*
               */ /*}*/ /*
              },
           count = count+1,
          });
    }
  }*/

  Future<dynamic> sendDataOnServer(
      BuildContext context, int userId, int adminId, String status) async {
    var response = await acceptRejectStatus(status, userId, adminId);
    if (response != null) {
      if ("Accept" == status) {
        fetchGroupAndMemberByMobileFromServer(status);
      } else {
        openNewScreen(status, null);
      }
    }
  }

  Future<void> openNewScreen(String status, String role)async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String role = await sp.getString(SP_ROLE);
    Navigator.pop(context);
    removeInvitaionTableFromLocalDB();
    if ("Reject" == status) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CreateGroup()),
          (Route<dynamic> route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MainDashboardScreen(
                    lohginRole: role,
                  )),
          (Route<dynamic> route) => false);
    }
  }

  Future getMemberDetailsFromLocal(BuildContext context,
      NotificationGroupJoin groupJoin, String status) async {
    var dbHelper = DatabaseHelper();
    await dbHelper
        .getDbTaskByMemberId(groupJoin.userId)
        .then((value) => {if (value != null) {}});
  }

  Future<void> updateTaskStatus(
      BuildContext context, int taskId, String status, int score) async {
    var dbHelper = DatabaseHelper();
    dbHelper
        .updateTaskStatus(taskId, status, score)
        .then((value) => {Navigator.pop(context)});
  }

  Widget showTaskStatusDialog(BuildContext context, String title,
      String message, int userId, bool result) {
    // set up the button
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          child: alert,
          onWillPop: () => Future.value(false),
        );
      },
    );
  }

  Widget showAlertDialog(BuildContext context, String title, String message,
      int userId, int adminId, bool result) {
    // set up the button
    Widget AcceptButton = FlatButton(
      child: Text("ACCEPT"),
      onPressed: () {
        if (result) {
          Navigator.of(context).pop();
          showLoaderDialog(context);
          //fetchGroupAndMemberByMobileFromServer("Accept");
          sendDataOnServer(context, userId, adminId, "Accept");
        } else {
          Navigator.of(context).pop();
        }
      },
    );
    Widget RejectButton = FlatButton(
      child: Text("REJECT"),
      onPressed: () {
        if (result) {
          Navigator.of(context).pop();
          showLoaderDialog(context);
          sendDataOnServer(context, userId, adminId, "Reject");
        } else {
          Navigator.of(context).pop();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AcceptButton,
        RejectButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          child: alert,
          onWillPop: () => Future.value(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (groupJoin != null) {
      // open dialog and accept or reject member request
      String groupName =
          "${groupJoin.adminName} invites you to join ${groupJoin.group_name} group";
      // var title = getNotificationTitle("1");
      Future.delayed(
          Duration.zero,
          () => showAlertDialog(context, INVITE_GROUP_MSG, groupName,
              groupJoin.userId, groupJoin.adminId, true));
      /* switch(widget.titleCode)
      {
        case "1":
          String groupName =
              "${groupJoin.adminName} invite you to join ${groupJoin.group_name} group";
          // var title = getNotificationTitle("1");
          Future.delayed(
              Duration.zero,
                  () => showAlertDialog(
                  context, INVITE_GROUP_MSG, groupName, groupJoin.userId, true));
          break;
      }*/

      return Scaffold(
        backgroundColor: LightColors.kPrimary,
      );
    } else {
      return Container(
       color: LightColors.kTitle,
        child: Center(
          child: Text(APP_NAME),
        ),
      );
    }
  }
}

Future<void> saveLoginDetailsInLocalDB(UserInfo userInfo) async {
  DbLogin dbLogin = DbLogin();
  dbLogin.userId = userInfo.userId;
  dbLogin.name = userInfo.name;
  dbLogin.mobile = userInfo.mobile;
  dbLogin.role = userInfo.role;
  var dbHelper = DatabaseHelper();
  await dbHelper.insertLogin(dbLogin).then((value) =>
      {print('Login details save successfully ${value.role} ${value.userId}')});
}
