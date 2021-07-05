import 'dart:convert';
import 'dart:math';

import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/group_member.dart';
import 'package:chores_app/ui/my_group_member_screen.dart';
import 'package:chores_app/ui/task_list_screen.dart';
import 'package:chores_app/ui/user_profile_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/ui/member_task_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final dynamic notification;
  final String notificationTitle;

  const AdminDashboardScreen(
      {Key key, this.notification, this.notificationTitle})
      : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  NotificationTaskComplete notificationTaskComplete;
  TextEditingController _textFieldController;
  String role;
  bool _isLoginTypeAdmin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSPData();
    if (widget.notification != null) {
      setState(() {
        notificationTaskComplete =
            NotificationTaskComplete.fromJson(json.decode(widget.notification));
      });
    }
  }

  Future<void> getSPData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loginRole = await sp.getString(SP_ROLE);
    setState(() {
      role = loginRole;
      if("Admin"==role)
        {
          _isLoginTypeAdmin = true;
        }
    });
  }

  void launchTaskScreen()
  {
    if("Admin"==role)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskListScreen()));
      }
    else if("Member"==role){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MemberTaskListScreen()));
    }
  }

  Widget showTaskStatusDialog(BuildContext context,
      NotificationTaskComplete taskComplete, bool result) {
    // set up the button
    // set up the AlertDialog
    String msg = taskComplete.memberName +
        " is complete his/her task" +
        "\n Points - ${taskComplete.taskPoint}";
    var score;
    AlertDialog alert = AlertDialog(
      title: Text(taskComplete.taskName),
      content: Column(
        children: [
          Text(msg),
          TextField(
            onChanged: (value) {
              setState(() {
                score = value;
              });
            },
            controller: _textFieldController,
            decoration: InputDecoration(hintText: ENTER_TASK_SCORE),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.green,
          textColor: Colors.white,
          child: Text('OK'),
          onPressed: () {
            setState(() {
              if (checkInternetConnection() != null) {
                Navigator.pop(context);
              } else {
                showToast(INTERNET_NOT_CONNECTED_MSG);
              }
            });
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notificationTitle != null) {
      // var title = getNotificationTitle("1");
      Future.delayed(Duration.zero,
          () => showTaskStatusDialog(context, notificationTaskComplete, true));
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Dashboard",
            style: TextStyle(color: Colors.white),
          ),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              }),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen()));
                  },
                  child: Icon(
                    Icons.person_pin,
                    color: Colors.white,
                    size: 35.0,
                  ),
                )),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyGroupMember()));
                    /*  Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => MyGroupMember()),
                            (Route<dynamic> route) => false);*/
                  },
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundColor: LightColors.kPrimaryDark,
                    child: Text(
                      'My Group',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                   launchTaskScreen();
                  },
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundColor: LightColors.kPrimaryDark,
                    child: Text(
                      'Task',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _isLoginTypeAdmin,
              child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TaskListScreen()));
                /* Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => TaskListScreen()),
                        (Route<dynamic> route) => false);*/
              },
              child: CircleAvatar(
                radius: 60.0,
                backgroundColor: LightColors.kPrimaryDark,
                child: Text(
                  'My Task',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
