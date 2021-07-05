import 'dart:convert';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/ServerResponse.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/login_screen.dart';
import 'package:chores_app/utils/sp_chores.dart';
import 'package:flutter/material.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'add_task_screen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String loginRole;
  var groupName = 'Group Name';
  DBMember dbMember = DBMember();
  var taskCount = 0;
  int taskScore = 0, _groupCount = 0;
  bool _isAdmin = false;
  String memberName = 'Name';
  var memberMobile = 'Mobile Number';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    try {
      String role = await getUserRole();
      int userId = await getUserId();
      var member = await getMemberData(userId);
      var gname = await getGroupDetails(member.groupId);
      var taskList = await getTaskList(userId);
      var gpCount = await getAllGroupCount();
      int score = 0;
      if (taskList.isNotEmpty) {
        for (DBTask dbTask in taskList) {
          if (ACCEPT == dbTask.status) {
            score = score + dbTask.taskPoint;
          }
        }
      }

      setState(() {
        loginRole = role;
        dbMember = member;
        groupName = gname.name;
        taskCount = taskList.length;
        taskScore = score;
        setState(() {
          memberName = dbMember.memberName;
          memberMobile = dbMember.memberMobile;
          _groupCount = gpCount;
        });
        if ("Admin" == role) {
          _isAdmin = true;
        }
      });
    } catch (error) {
      print(error);
    }
  }

  Future<DBMember> getMemberData(int userId) async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.getDbMemberByUserId(userId);
  }

  Future<DBGroup> getGroupDetails(int group_id) async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.getGroup(group_id);
  }

  Future<int> getAllGroupCount() async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.getAllGroupCount();
  }

  Future<void> removeAccountFromServer(DBMember dbMember) async {
    bool result = await checkInternetConnection();
    if (result) {
      final response = await deleteGroupOnServer(dbMember.groupId);
      if (response != null) {
        Navigator.pop(context);
        ServerResponse serverResponse =
            ServerResponse.fromJson(json.decode(response));
        if (serverResponse.success) {
          // delete groupTable
          // delete member table
          // delete task table
          var dbHelper = DatabaseHelper();
          await dbHelper.cleanDatabase();
          await clearSharedPreference();
          await Future.delayed(Duration(seconds: 2));

          Navigator.of(context).pushAndRemoveUntil(
            // the new route
            MaterialPageRoute(
              builder: (BuildContext context) => LoginScreen(),
            ),

            // this function should return true when we're done removing routes
            // but because we want to remove all other screens, we make it
            // always return false
            (Route route) => false,
          );
        }
      }
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }
  List<Widget> setWidgetList()
  {
    List<Widget> list;
    if("Admin"==loginRole) {
       list = [
        headerChild('Group', _groupCount),
        headerChild('Task', taskCount),
      ];
    }else{
       list = [
        headerChild('Group', _groupCount),
        headerChild('Task', taskCount),
        headerChild('Total Score', taskScore),
      ];
    }
    return list;
  }

  // ignore: missing_return
  Widget showAlertDialog(BuildContext context, DBMember dbMember) {
    // set up the button
    // ignore: non_constant_identifier_names
    Widget YesButton = FlatButton(
      child: Text(DIALOG_OK),
      onPressed: () {
        Navigator.of(context).pop();
        showLoaderDialog(context);
        removeAccountFromServer(dbMember);
      },
    );
    // ignore: non_constant_identifier_names
    Widget NoButton = FlatButton(
      child: Text(DIALOG_CANCEL),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(DIALOG_CONFIRMATION),
      content: Text(ACCOUNT_REMOVE_MESSAGE),
      actions: [
        YesButton,
        NoButton,
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

  /*Future<int> getTaskList(int userId) async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.getDbTaskCountByMemberId(userId);
  }*/
  Future<List<DBTask>> getTaskList(int userId) async {
    var dbHelper = DatabaseHelper();
    List<DBTask> taskList;
    if ("Admin" == loginRole) {
      taskList = await dbHelper.getDBAllTask();
    } else {
      taskList = await dbHelper.getDbTaskListByMemberId(userId);
    }
    return taskList;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return new Container(
      child: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(colors: [
              LightColors.kPrimaryDark,
              LightColors.kPrimaryDark,
            ], begin: Alignment.topCenter, end: Alignment.center)),
          ),
          new Scaffold(
            backgroundColor: Colors.transparent,
            body: new Container(
              child: new Stack(
                children: <Widget>[
                  new Align(
                    alignment: Alignment.center,
                    child: new Padding(
                      padding: new EdgeInsets.only(top: _height / 15),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new CircleAvatar(
                            backgroundImage:
                                //assets/images/chores_app_group1.png
                                new AssetImage(
                                    "assets/images/chores_app_profile.png"),
                            radius: _height / 10,
                          ),
                          new SizedBox(
                            height: _height / 30,
                          ),
                          new Text(
                            memberName,
                            style: new TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(top: _height / 2.2),
                    child: new Container(
                      color: Colors.white,
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                        top: _height / 2.6,
                        left: _width / 20,
                        right: _width / 20),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                new BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 2.0,
                                    offset: new Offset(0.0, 2.0))
                              ]),
                          child: new Padding(
                            padding: new EdgeInsets.all(_width / 20),
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  headerChild('Group', _groupCount),
                                  headerChild('Task', taskCount),
                                  headerChild('Total Score', taskScore),
                                ]),
                          ),
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(top: _height / 20),
                          child: new Column(
                            children: <Widget>[
                              infoChild(_width, Icons.call, memberMobile),
                              infoChild(_width, Icons.group, groupName),
                              Visibility(
                                visible: _isAdmin,
                                child: new GestureDetector(
                                  onTap: () {
                                    showAlertDialog(context, dbMember);
                                  },
                                  child: new Padding(
                                    padding:
                                        new EdgeInsets.only(top: _height / 30),
                                    child: new Container(
                                      width: _width / 3,
                                      height: _height / 20,
                                      decoration: new BoxDecoration(
                                          color: LightColors.kValueColor,
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(
                                                  _height / 40)),
                                          boxShadow: [
                                            new BoxShadow(
                                                color: Colors.black87,
                                                blurRadius: 2.0,
                                                offset: new Offset(0.0, 1.0))
                                          ]),
                                      child: Center(
                                        child: new Text(REMOVE_ACCOUNT,
                                            style: new TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget headerChild(String header, int value) => new Expanded(
          child: new Column(
        children: <Widget>[
          new Text(header),
          new SizedBox(
            height: 8.0,
          ),
          new Text(
            '$value',
            style: new TextStyle(
                fontSize: 14.0,
                color: LightColors.kValueColor,
                fontWeight: FontWeight.bold),
          )
        ],
      ));

  Widget infoChild(double width, IconData icon, data) => new Padding(
        padding: new EdgeInsets.only(bottom: 8.0),
        child: new InkWell(
          child: new Row(
            children: <Widget>[
              new SizedBox(
                width: width / 10,
              ),
              new Icon(
                icon,
                color: LightColors.kValueColor,
                size: 36.0,
              ),
              new SizedBox(
                width: width / 20,
              ),
              new Text(data)
            ],
          ),
          onTap: () {
            print('Info Object selected');
          },
        ),
      );
}
