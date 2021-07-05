import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/TaskMember.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/ui/taskDetails.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneTimeTaskScreenTab extends StatefulWidget {
  @override
  _OneTimeTaskScreenTabState createState() => _OneTimeTaskScreenTabState();
}

class _OneTimeTaskScreenTabState extends State<OneTimeTaskScreenTab> {
  bool flag = false;
  bool insertItem = false;
  List<TaskMember> taskMemberList = List<TaskMember>();
  List<TaskMember> values = List<TaskMember>();
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  ScrollController _scrollController;
  BuildContext mContext;
  String loginRole;
  bool _isLoginAdmin = false;

  getAllTask() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });
  }

  ///Fetch data from database
  Future<List<TaskMember>> _getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int groupId = int.parse(sharedPreferences.getString(SP_GROUP_ID));
    String role = sharedPreferences.getString(SP_ROLE);
    /*setState(() {
      if ("Admin" == role) {
        _isLoginAdmin = true;
      } else {
        _isLoginAdmin = false;
      }
    });*/

    int userId = sharedPreferences.getInt(SP_USER_ID);
    var dbHelper = DatabaseHelper();
    // remove hard coded value after testing
    _listKey = GlobalKey();
    await dbHelper.getDbTaskByMemberId(userId).then((value) async {
      if (value != null && value.isNotEmpty) {
        await getTaskData(dbHelper, value);
        if (insertItem) {
          _listKey.currentState.insertItem(taskMemberList.length);
          insertItem = false;
        }
      }
      return null;
    });
    return taskMemberList.toSet().toList();
  }

  Future getTaskData(DatabaseHelper dbHelper, List<DBTask> value) async {
    for (DBTask task in value) {
      TaskMember taskMember = TaskMember();
      if (task.dueDate != null && task.dueDate.isNotEmpty) {
        taskMember.taskId = task.tId;
        taskMember.taskType = task.taskType;
        taskMember.taskName = task.taskName;
        taskMember.taskDescription = task.taskDescription;
        taskMember.taskPoint = task.taskPoint;
        taskMember.taskDueDateTime = getDateTimeDate(task.dueDate);
        taskMember.groupId = task.groupId;
        if(task.status==null)
        {
          taskMember.status = PENDING;
        }else {
          taskMember.status = task.status;
        }
        if (task.scored != null) {
          taskMember.scored = task.scored;
        } else {
          taskMember.scored = 0;
        }
        taskMember.custom = task.custom;
        taskMember.dueDate = task.dueDate;
        taskMember.dueTime = task.dueTime;
        taskMember.assigneeId = task.assigneeId;
        taskMember.memberId = task.memberId;
        await dbHelper
            .getDbMember(task.assigneeId)
            .then((dbMemberAssignee) async => {
                  taskMember.assigneeName = dbMemberAssignee.memberName,
                  taskMember.assigneeMobile = dbMemberAssignee.memberMobile,
                  await dbHelper.getDbMember(task.memberId).then((dbMember) => {
                        taskMember.memberName = dbMember.memberName,
                        taskMember.memberMobile = dbMember.memberMobile,
                        taskMemberList.add(taskMember)
                      })
                });
      }
    }
  }

  ///create List View with Animation
  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    mContext = context;
    values = snapshot.data;
    if (values != null && values.isNotEmpty) {
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
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  new Text(
                    values.taskName.toString(),
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  new Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          POINT,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      new InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          constraints: new BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 200),
                          child: new Text(
                            values.taskPoint.toString(),
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                          ),
                        ),
                      ),
                     /* Text(
                        SCORE,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          constraints: new BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 200),
                          child: new Text(
                            values.scored.toString(),
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),*/
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  new Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          DUE_DATE,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      new InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          constraints: new BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 200),
                          child: new Text(
                            values.dueDate.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  Row(
                    children: [
                      Text(
                        DUE_TIME,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          constraints: new BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 200),
                          child: new Text(
                            values.dueTime.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: new Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            ASSIGN_BY,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        new InkWell(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 200),
                            child: new Text(
                              values.assigneeName.toString(),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
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
                            padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            constraints: new BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width - 200),
                            child: new Text(
                              values.status.toString(),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          // below code commented cause - this page is only for members so no need to show delete button
         /* trailing: Column(
            children: <Widget>[
              Visibility(
                visible: _isLoginAdmin,
                child: Flexible(
                  fit: FlexFit.tight,
                  child: IconButton(
                      color: Colors.grey[500],
                      icon: new Icon(Icons.delete),
                      onPressed: () => onDelete(context, values, index)),
                ),
              ),
            ],
          ),*/
        ),
      ),
    );
  }

  /// Delete Click and delete item
  onDelete(BuildContext context, TaskMember values, int index) async {
    // first remove it from server
    if (checkInternetConnection() != null) {
      /*  var response = await deleteTaskOnServer(values.taskId);
      if (response != null) {*/
      var id = values.taskId;
      var dbHelper = DatabaseHelper();
      dbHelper.deleteTask(id).then((value) {
        TaskMember removedItem = taskMemberList.removeAt(index);

        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return _buildItem(context, removedItem, animation, index);
        };
        _listKey.currentState.removeItem(index, builder);
      });
      //}
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
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
    return getAllTask();
  }

}
