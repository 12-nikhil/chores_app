import 'dart:async';

import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/TaskMember.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/taskDetails.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_task_screen.dart';

class TaskHistoryScreen extends StatefulWidget {
  final String loginRole;

  const TaskHistoryScreen({Key key, this.loginRole}) : super(key: key);

  @override
  _TaskHistoryScreenTabState createState() => _TaskHistoryScreenTabState();
}

class _TaskHistoryScreenTabState extends State<TaskHistoryScreen> {
  bool flag = false;
  bool insertItem = false;
  List<TaskMember> taskMemberList = List<TaskMember>();
  List<TaskMember> values;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  ScrollController _scrollController;
  BuildContext mContext;
  StreamController<List<TaskMember>> streamController;

  @override
  void initState() {
    super.initState();
    streamController = new StreamController<List<TaskMember>>.broadcast();
  }

  getAllTask() {
    return StreamBuilder<List<TaskMember>>(
        stream: _getData().asStream(),
        builder: (context, snapshot) {
          return createListView(context, snapshot);
        });
    /*  builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });*/
  }

  @override
  void dispose() {
    super.dispose();
  }

  /* getAllTask() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });
  }*/

  ///Fetch data from database
  Future<List<TaskMember>> _getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int groupId = int.parse(sharedPreferences.getString(SP_GROUP_ID));
    String role = sharedPreferences.getString(SP_ROLE);
    int userId = sharedPreferences.getInt(SP_USER_ID);
    print("SP GroupId ${groupId}");
    var dbHelper = DatabaseHelper();
    // remove hard coded value after testing
    if ('Admin' == role) {
      await dbHelper.getDbTaskByGroupId(groupId).then((value) async {
        if (value != null) {
          await getTaskData(dbHelper, value);
          if (insertItem) {
            _listKey.currentState.insertItem(taskMemberList.length);
            insertItem = false;
          }
        }
        return null;
      });
    } else {
      await dbHelper.getDbTaskByMemberId(userId).then((value) async {
        if (value != null) {
          await getTaskData(dbHelper, value);
          if (insertItem) {
            _listKey.currentState.insertItem(taskMemberList.length);
            insertItem = false;
          }
        }
        return null;
      });
    }
// extra code
    if (taskMemberList.length > 0) {
      streamController.sink.add(taskMemberList);
    }
    return taskMemberList;
  }

  Future getTaskData(DatabaseHelper dbHelper, List<DBTask> value) async {
    for (DBTask task in value) {
      TaskMember taskMember = TaskMember();
      if(task.dueDate!=null && task.dueDate.isNotEmpty)
        {
          DateTime dateTime = getDateTimeDate(task.dueDate);
          DateTime currentDate = getDateTimeDate(getCurrentDate());
          if(dateTime.isBefore(currentDate)) {
            if (PENDING == task.status || SUBMITTED == task.status) {
              taskMember.taskId = task.tId;
              taskMember.taskType = task.taskType;
              taskMember.taskName = task.taskName;
              taskMember.taskDescription = task.taskDescription;
              taskMember.taskPoint = task.taskPoint;
              taskMember.groupId = task.groupId;
              if (task.status == null) {
                taskMember.status = PENDING;
              } else {
                taskMember.status = task.status;
              }
              if (task.lastUpdatedDate != null &&
                  task.lastUpdatedDate.isNotEmpty) {
                taskMember.lastUpdatedDate = getDateTimeWithWeek(task.lastUpdatedDate);
                taskMember.taskDueDateTime =
                    getDateTimeDate(task.lastUpdatedDate);
              }
              taskMember.custom = task.custom;
              taskMember.dueDate = task.dueDate;
              taskMember.dueTime = task.dueTime;
              taskMember.assigneeId = task.assigneeId;
              taskMember.memberId = task.memberId;
              await dbHelper
                  .getDbMember(task.assigneeId)
                  .then((dbMemberAssignee) async =>
              {
                taskMember.assigneeName = dbMemberAssignee.memberName,
                taskMember.assigneeMobile = dbMemberAssignee.memberMobile,
                await dbHelper.getDbMember(task.memberId).then((dbMember) =>
                {
                  taskMember.memberName = dbMember.memberName,
                  taskMember.memberMobile = dbMember.memberMobile,
                  taskMemberList.add(taskMember)
                })
              });
            }
          }
        }
    }
    // streamController.add(taskMemberList);
  }

  ///create List View with Animation
  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    mContext = context;
    values = snapshot.data;
    if (values != null && values.length > 0) {
      values.sort((a, b) => b.taskDueDateTime.compareTo(a.taskDueDateTime));
      showProgress();
      return new AnimatedList(
          key: _listKey,
          controller: _scrollController,
          shrinkWrap: true,
          initialItemCount: values.length,
          itemBuilder: (BuildContext context, int index, animation) {
            return _buildItem(context, values[index], animation, index);
          });
    } else {
      return Container(
        child: Center(
          child: Text(
            TASK_NOT_FOUND,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
  }

  Widget _buildItem(BuildContext context, TaskMember values,
      Animation<double> animation, int index) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(width: 10, color: Colors.transparent)),
        child: ListTile(
          onTap: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskDetailsPage(
                          taskMember: values,
                        )))
          } /*onItemClick(values)*/,
          title: Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(5.0, 0, 0, 5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0)),
                  Padding(padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                  child:  new Text(
                    values.taskName.toString(),
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),),
                  Padding(padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                  child: new Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          UPDATED_DATE,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      new InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(5.0, 0, 20.0, 0),
                          constraints: new BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width - 200),
                          child: new Text(
                            values.lastUpdatedDate.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                    child: new Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            FOR,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        new InkWell(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            constraints: new BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width - 200),
                            child:
                            Visibility(
                              visible: "Admin" == widget.loginRole ? true : false,
                              child: new Text(
                                values.memberName.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                    child: new Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            BY,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        new InkWell(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 200),
                            child: new Text(
                              values.assigneeName.toString(),

                              textAlign: TextAlign.left,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                    child: new Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            STATUS,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        new InkWell(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 0, 50.0, 0),
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 200),
                            child: new Text(
                              values.status.toString(),
                              style: TextStyle(
                                  color: ACCEPT == values.status.toString()
                                      ? LightColors.kGreen
                                      : LightColors.kRed),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0)),
                ],
              ),
            ],
          ),
          trailing:
          Visibility(
            visible: SUBMITTED==values.status?true:false,
            child: Column(
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: IconButton(
                      color: LightColors.kGreen,
                      icon: new Icon(Icons.check_circle_outline,color: LightColors.kGreen,),
                      onPressed: () => showAlertDialog(context, values, index)),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  /// Delete Click and delete item
  onDelete(BuildContext context, TaskMember values, int index) async {
    // first remove it from server
    if (checkInternetConnection() != null) {
      var response = await deleteTaskOnServer(values.taskId, values.groupId);
      if (response != null) {
        var id = values.taskId;
        var dbHelper = DatabaseHelper();
        dbHelper.deleteTask(id).then((value) {
          TaskMember removedItem = taskMemberList.removeAt(index);

          AnimatedListRemovedItemBuilder builder = (context, animation) {
            return _buildItem(context, removedItem, animation, index);
          };
          _listKey.currentState.removeItem(index, builder);
        });
      }
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

  Widget showAlertDialog(BuildContext context, TaskMember values, int index) {
    // set up the button
    // ignore: non_constant_identifier_names
    Widget YesButton = FlatButton(
      child: Text(DIALOG_OK),
      onPressed: () {
        Navigator.of(context).pop();
        showLoaderDialog(context);
        onDelete(context, values, index);
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

  showProgress() {
    return ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.black38,
      borderRadius: 5.0,
      text: 'Loading...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(POPUP_TASK_HISTORY),
        centerTitle: true,
      ),
      body: getAllTask(),
    );
  }
}
