import 'dart:async';
import 'dart:convert';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/main.dart';
import 'package:chores_app/models/ServerResponse.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/create_group.dart';
import 'package:chores_app/ui/group_member.dart';
import 'package:chores_app/ui/login_screen.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/ui/registration_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/ui/admin_dashboard_screen.dart';
import 'package:chores_app/ui/member_dashboard_screen.dart';
import 'member_dashboard.dart';
import 'package:chores_app/helper/method_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> initState() {
    super.initState();
    //addTask();
    // remove below code after testing
    //deleteGroup(9);
    //unSubscribeTopicMobile();
    try {
      Timer(
        Duration(seconds: 3),
        () {
          _launchedNewScreen();
        },
      );
    } catch (err) {
      print("Exception ${err}");
    }
  }

  Future<void> _launchedNewScreen() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    String role = await sp.getString(SP_ROLE);
    String gpName = await sp.getString(SP_GROUP_NAME);
    print("Login role ${role}");
    if (role == null) {
      if (sp.getString(SP_MOBILE) == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RegistrationScreen()),*/
        );
      } else {
        /* Navigator.push(
            context,
            MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(lohginRole: role)));*/
        var dbHelper = DatabaseHelper();
        NotificationGroupJoin groupJoinInvitation;
        await dbHelper.getInvitationDetails().then((value) => {
              if (value != null)
                {
                  groupJoinInvitation = createGroupJoin(value),
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MemberDashboardScreen(
                                groupJoin: groupJoinInvitation,
                                isNewMember: true,
                              )),
                      (Route<dynamic> route) => false)
                }
              else
                {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CreateGroup()),
                      (Route<dynamic> route) => false)
                }
            });
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MainDashboardScreen(
                    lohginRole: role,
                    pageIndex: 0,
                groupName: gpName,
                  )),
          (Route<dynamic> route) => false);
    }
  }

/* Future<void> addTask() async
  {
    //{"taskId":1,"adminUserId":1,"memberUserId":[2],"groupId":1,"taskName":"Testing","taskPoint":10,"taskType":"One Time","custom":"Mon, Tue","task_description":"testing ","dueTime":"18:30:00","dueDate":"2021-03-03T18:30:00.000+00:00","createdDate":"2021-03-04T09:52:20.571+00:00"}
    DBTask dbTask = DBTask();
    dbTask.tId = 1;
    dbTask.assigneeId = 1;
    dbTask.memberId = 2;
    dbTask.taskName = 'Testing';
    dbTask.taskDescription = 'Testing Testing';
    dbTask.taskType = 'One Time';
    dbTask.custom = 'Mon,Tue';
    dbTask.dueDate = '04/03/2021';
    dbTask.dueTime = '17:00:00';
    dbTask..taskPoint = 10;
    var dbHelper = DatabaseHelper();
   await dbHelper.insertTask(dbTask).then((value) =>
    {
      print('Task Insert ${value}')
    });
  }*/

  Future deleteGroup(int groupId) async {
    bool result = await checkInternetConnection();
    if (result) {
      final response = await deleteGroupOnServer(groupId);
      if (response != null) {
        ServerResponse serverResponse =
            ServerResponse.fromJson(json.decode(response));
        if (serverResponse.success) {
          // delete groupTable
          // delete member table
          // delete task table
          var dbHelper = DatabaseHelper();
          await dbHelper.cleanDatabase();
          await clearSharedPreference();
        }
      }
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

/* void unSubscribeTopicMobile()
  {
    MyHomePage().createState().unSubscribeTopic("917709935591");
    MyHomePage().createState().subscribeTopic("917709935591");
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kPrimaryDark,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/chors_app_intro1.jpg',
              ),
              SizedBox(
                height: 40,
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "CHORES",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text("",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w700,
                        ))
                  ])
            ]),
      ),
    );
  }
}
