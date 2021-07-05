import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/TaskMember.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/models/TaskNotificationBody.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskMember taskMember;

  const TaskDetailsPage({Key key, this.taskMember}) : super(key: key);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  var score = 0;
  var _isDateVisible = false;
  var _isCustomVisible = false;
  var _isSubmitButtonVisible = false;
  var _isAcceptRejectVisible = false;
  var _isNameVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataFromSharedPreference();
    setState(() {
      if (widget.taskMember.scored != null) {
        score = widget.taskMember.scored;
        if (score > 0) {
          widget.taskMember.status = "Success";
        }
      }
      if ("One Time" == widget.taskMember.taskType) {
        _isDateVisible = true;
        _isCustomVisible = false;
      } else {
        _isDateVisible = false;
        _isCustomVisible = true;
      }
    });
  }

  void _getDataFromSharedPreference() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var loginType = sp.getString(SP_ROLE);
    var mobile = sp.getString(SP_MOBILE);
    setState(() {
      if ("Admin" == loginType) {
        _isSubmitButtonVisible = false;
        _isNameVisible = true;
        if (COMPLETE_TASK_STATUS == widget.taskMember.status) {
          _isAcceptRejectVisible = true;
        } else {
          _isAcceptRejectVisible = false;
        }
      } else if (widget.taskMember.memberMobile == mobile) {
        if (widget.taskMember.status == null ||
            PENDING == widget.taskMember.status) {
          _isSubmitButtonVisible = true;
        } else {
          _isSubmitButtonVisible = false;
        }
      }
    });
  }

  Future<void> _submitTask(TaskMember taskMember, String status) async {
    if (checkInternetConnection() != null) {
      showLoaderDialog(context);
      TaskNotificationBody taskNotificationBody = TaskNotificationBody();
      taskNotificationBody.taskId = taskMember.taskId;
      taskNotificationBody.adminId = taskMember.assigneeId;
      taskNotificationBody.memberId = taskMember.memberId;
      taskNotificationBody.memberName = taskMember.memberName;
      taskNotificationBody.adminMobileNo = taskMember.assigneeMobile;
      taskNotificationBody.taskPoint = taskMember.taskPoint;
      taskNotificationBody.taskName = taskMember.taskName;
      taskNotificationBody.status = status;
      var response = await sendTaskStatusOnServer(taskNotificationBody);

      if (response != null) {
        setState(() {
          _isSubmitButtonVisible = false;
        });
        dismissDialog(context);
        saveTaskStatusInLocalDB(taskMember.taskId, COMPLETE_TASK_STATUS, 0);
      } else {
        dismissDialog(context);
        showToast(TASK_COMPLETE_STATUS_ERROR);
      }
    } else {
      dismissDialog(context);
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

  Future<void> saveStatusOnServer(
      int taskId, int userId, String status, int score, int groupId) async {
    //Navigator.pop(context);
    dismissDialog(context);
    if (checkInternetConnection() != null) {
      await sendTaskAcceptReject(taskId, userId, status, score, groupId)
          .then((value) => {
                saveTaskStatusInLocalDB(taskId, status, score).then((value) => {
                      //Navigator.pop(context),
                      resetUi(),
                      showToastMessage(status),
                      //Navigator.pop(context),
                      _launchMainDashboardScreen(widget.taskMember.taskType),
                    })
              });
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

  void showToastMessage(String status) {
    switch (status) {
      case SUBMITTED:
        showToast(TOAST_TASK_SUBMITTED);
        break;
      case ACCEPT:
        showToast(TOAST_TASK_ACCEPTED);
        break;
      case REJECT:
        showToast(TOAST_TASK_REJECTED);
        break;
    }
  }

  dismissDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    //Navigator.pop(context);
    //Navigator.pop(context, true);
    // Navigator.of(context).pop();
  }

  Future<void> _launchMainDashboardScreen(String taskType) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String role = await sp.getString(SP_ROLE);
    String gpName = await sp.getString(SP_GROUP_NAME);
    int index = 1;
    if ('Recurring' == taskType.trim()) {
      index = 2;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(
                  lohginRole: role,
                  pageIndex: index,
              groupName: gpName,
                )),
        (Route<dynamic> route) => false);
  }

  Future resetUi() async {
    setState(() {
      _isAcceptRejectVisible = false;
    });
  }

  Future<int> saveTaskStatusInLocalDB(
      int taskId, String status, int score) async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.updateTaskStatus(taskId, status, score);
    /* await dbHelper.updateTaskStatus(taskId, status, score).then((value) => {
          showToast(TASK_COMPLETE_STATUS_SEND),});*/
  }

  void setDateState(String status) {
    setState(() {
      if ("Pending" == status) {
        _isSubmitButtonVisible = false;
      }
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text(" Please wait..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightColors.kPrimaryDark,
        title: (Text(
          'Task Detail',
          style: TextStyle(color: Colors.white),
        )),
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0)),
              Visibility(
                visible: true,
                child: Text(
                  widget.taskMember.taskName.toString(),
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: LightColors.kTitle,
                  ),
                  textAlign: TextAlign.center,
                ),
              ), // member name
             /* Padding(
                padding: EdgeInsets.fromLTRB(12.0, 5.0, 0.0, 5.0),
                child: Text(
                  widget.taskMember.taskName.toString(),
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ), */// task name
              Padding(
                padding: EdgeInsets.fromLTRB(12.0, 5.0, 0.0, 5.0),
                child: Text(
                  widget.taskMember.taskDescription.toString(),
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                  textAlign: TextAlign.left,
                ),
              ), // task description
              Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
           Visibility(
             visible: _isNameVisible,
             child:   Card(
                 child: Padding(
                   padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                   child: Row(
                     children: [
                       Expanded(
                         child: Row(
                           children: [
                             Text(
                               FOR,
                               style: TextStyle(
                                   fontSize: 16.0, fontWeight: FontWeight.bold),
                             ),
                             Padding(
                                 padding:
                                 EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0)),
                             Text(
                               widget.taskMember.memberName.toString(),
                               style: TextStyle(fontSize: 18.0),
                             ),
                           ],
                         ),
                       )
                     ],
                   ),
                 )),
           ), // Task for y
              Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
              Card(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                BY,
                                style: TextStyle(
                                    fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0)),
                              Text(
                                widget.taskMember.assigneeName.toString(),
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0)),
              Card(
                color: Colors.grey[400],
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              POINT,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0)),
                            Text(
                              widget.taskMember.taskPoint.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 25.0),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ), // task points
              Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 5.0)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                 child: Column(
                   children: [
                     Visibility(
                       visible: _isDateVisible,
                       child: Row(
                         children: [
                           Icon(Icons.date_range),
                           Padding(
                               padding: EdgeInsets.fromLTRB(
                                   10.0, 5.0, 10.0, 5.0)),
                           Text(
                             getDateTimeWithWeek(widget.taskMember.dueDate.toString()),
                             style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 18.0,
                                 color: Colors.blue),
                           ),
                         ],
                       ),
                     ),
                     Visibility(
                       visible: _isCustomVisible,
                       child: Row(
                         children: [
                           Text(
                             REPEAT,
                             style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 18.0),
                           ),
                           Padding(
                               padding:
                               EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0)),
                           Text(
                             widget.taskMember.custom.toString(),
                             style: TextStyle(
                                 letterSpacing: 2.0,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 18.0,
                                 color: Colors.blue),
                           ),
                         ],
                       ),
                     ),
                   ],
                   ),
                 ),
              ), // task date
              Padding(padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time),
                      /* Text(
                        COMPLETION_TIME,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),*/
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0)),
                      Text(
                        widget.taskMember.dueTime.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ), // task time
              Visibility(
                visible: _isSubmitButtonVisible,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                    child: RoundedButton(
                      color: LightColors.kPrimaryDark,
                      text: COMPLETE_TASK,
                      press: () async {
                        _submitTask(widget.taskMember, COMPLETE_TASK_STATUS);
                      },
                    )),
              ),
              Visibility(
                visible: _isAcceptRejectVisible,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0)),
                    Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: RoundedButton(
                          color: LightColors.kPrimaryDark,
                          text: ACCEPT,
                          press: () async {
                            // your code
                            //if (score > 0) {
                            //if (score <= widget.taskMember.taskPoint) {
                            showLoaderDialog(context);
                            saveStatusOnServer(
                                widget.taskMember.taskId,
                                widget.taskMember.memberId,
                                ACCEPT,
                                widget.taskMember.taskPoint,
                                widget.taskMember.groupId);
                            /*} else {
                                    showToast(
                                        TOAST_MSG_SCORE_NOT_GREATER_THAN_POINTS);
                                  }*/
                            /* } else {
                                  showToast(TOAST_MSG_INVALID_SCORE_FIELD);
                                }*/
                          },
                        )),
                        SizedBox(width: 15),
                        Expanded(
                            child: RoundedButton(
                          color: LightColors.kPrimaryDark,
                          text: REJECT,
                          press: () async {
                            // your code
                            showLoaderDialog(context);
                            saveStatusOnServer(
                                widget.taskMember.taskId,
                                widget.taskMember.memberId,
                                REJECT,
                                0,
                                widget.taskMember.groupId);
                          },
                        )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),

    );
  }
}
