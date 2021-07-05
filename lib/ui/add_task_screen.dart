import 'dart:convert';

import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/Task.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:chores_app/ui/chip_display/multi_select_chip_display.dart';
import 'package:chores_app/ui/dialog/multi_select_dialog_field.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/ui/timepicker/constants.dart';
import 'package:chores_app/ui/timepicker/daynight_timepicker.dart';
import 'package:chores_app/ui/weekday_selector.dart';
import 'package:chores_app/utils/Utils.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:chores_app/utils/multi_select_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:chores_app/models/TaskResponse.dart';

class ADDTaskScreen extends StatefulWidget {
  final DBMember dbMember;
  final String calligType;

  const ADDTaskScreen({Key key, this.dbMember, this.calligType})
      : super(key: key);

  @override
  _ADDTaskScreenState createState() => _ADDTaskScreenState();
}

class _ADDTaskScreenState extends State<ADDTaskScreen> {
  Task task = new Task();
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  bool iosStyle = true;
  List<DBMember> memberList = [];
  List<DBMember> selectedMemberList = [];
  List<int> selectedMemberIdList = [];
  final textDateController = TextEditingController();
  final textFromDateController = TextEditingController();
  final textToController = TextEditingController();
  var textTimeController = TextEditingController();
  var _items;

  String radioButtonItem;

  // Group Value for Radio Button.
  int idOneTime = -1, idRecurring = -2;
  bool isDailySelect = false;
  bool isCustomSelect = false;

  var _isAppbarVisible = false;
  var _isDateRangeVisible = false;
  var _isDateVisible = false;
  var _isWeekDayVisible = false;
  var _isMemberSelectionVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      if (widget.dbMember != null) {
        _isMemberSelectionVisible = false;
        _isAppbarVisible = true;
      } else {
        _isMemberSelectionVisible = true;
        _isAppbarVisible = false;
      }
    });
    _getTime();
    _getMemberData();
  }

  void showWidget() {
    setState(() {
      _isDateVisible = true;
      _isDateRangeVisible = false;
      _isWeekDayVisible = false;
      if (idOneTime == 1 || idRecurring == 2) {
        idRecurring = -2;
        isCustomSelect = false;
      }
    });
  }

  void hideWidget() {
    setState(() {
      _isDateVisible = false;
      _isDateRangeVisible = true;
      _isWeekDayVisible = true;
      if (idRecurring == 2) {
        idOneTime = -1;
        isDailySelect = false;
      }
    });
  }

  Future<List<DBMember>> _getMemberData() async {
    var dbHelper = DatabaseHelper();
    List<DBMember> dbMemberList = List<DBMember>();
    await dbHelper.getAllMember().then((value) {
      for (DBMember dbMember in value) {
        if ("Member" == dbMember.memberRole) {
          dbMemberList.add(dbMember);
        }
      }
    });
    setState(() {
      memberList = dbMemberList;
    });
    _items = memberList
        .map((member) => MultiSelectItem<DBMember>(
            member, member.memberName, member.memberMobile))
        .toList();
    return memberList;
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  void _getTime() {
    final String formattedDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
    final String formattedTime =
        DateFormat('HH:mm aa').format(DateTime.now()).toString();
    setState(() {
      textDateController.text = formattedDate;
      textTimeController.text = formattedTime;
      task.dueDate = formattedDate;
      task.dueTime = formattedTime;
      print('Current Time ${formattedDate} ${formattedTime}');
    });
  }

  Future onTaskCreateOnServer(
      BuildContext context, DBMember selectedMember) async {
    if (checkInternetConnection() != null) {
      /* if ("One Time" == task.taskType) {
        if (task.dueDate == null) {}
      }*/
      var dbHelper = DatabaseHelper();
      //if (isTaskValid()) {
      showLoaderDialog(context);
      SharedPreferences sp = await SharedPreferences.getInstance();
      int userId = await sp.getInt(SP_USER_ID);
      await dbHelper.getDbMemberByUserId(userId).then((value) => {
            task.groupId = value.groupId,
            saveDataOnServer(context, selectedMember, value, sp),
          });
    }
    //}
    else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

  bool isTaskValid() {
    if (task.taskName == null) {
      showToast(TOAST_MSG_ENTER_VALID_TASK_NAME);
      return false;
    }
    if (task.taskDescription == null) {
      showToast(TOAST_MSG_ENTER_VALID_TASK_DESCRIPTION);
      return false;
    }
    if (task.taskPoint == null || task.taskPoint < 0) {
      showToast(TOAST_MSG_ENTER_VALID_TASK_POINT);
      return false;
    }
    if ("One Time" == task.taskType) {
      if (task.dueDate == null) {
        showToast(TOAST_MSG_ENTER_DUE_DATE);
        return false;
      }
    } else {
      if (task.custom == null) {
        showToast(TOAST_MSG_SELECT_REPEAT_DAYS);
        return false;
      }
      if(task.fromDate==null)
        {
          showToast(TOAST_MSG_ENTER_START_DATE);
          return false;
        }
      if(task.toDate==null)
      {
        showToast(TOAST_MSG_ENTER_END_DATE);
        return false;
      }
    }
    if (task.dueTime == null) {
      showToast(TOAST_MSG_ENTER_DUE_TIME);
      return false;
    }
    return true;
  }

  void saveDataOnServer(BuildContext context, DBMember selectedMember,
      DBMember dbMember, SharedPreferences sp) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      task.adminUserId = dbMember.uId;
      if (task.dueTime == null) {
        task.dueTime = textTimeController.text;
      }
      List<String> selectedDate = [];
      if (RECURRING == task.taskType) {
        DateTime from = getDateTimeDate(textFromDateController.text);
        DateTime to = getDateTimeDate(textToController.text);
        task.fromDate = textFromDateController.text;
        task.toDate = textToController.text;
        List<DateTime> selectedDateList = getDaysInBetween(from, to);
        var weekDayList = task.custom.split(",");
        selectedDate = getRecurringDateTime(selectedDateList, weekDayList);
      }
      task.selectedDate = selectedDate;
      task.status = PENDING;
      if (isTaskValid()) {
        var responseTask = await createTaskOnServer(task);
        if (responseTask != null) {
          var responseJson = jsonDecode(responseTask) as List;
          //taskList = responseJson;
          print({"Task response ${responseJson}"});
          dismissDialog(context);
          List<TaskResponse> taskList = await responseJson
              .map((tagJson) => TaskResponse.fromJson(tagJson))
              .toList();
          // save task List in local db
          if (taskList != null) {
            showToast(SEND);
            _launchMainDashboardScreen(task.taskType);
            /*if (taskList.length > 0) {
              var dbHelper = DatabaseHelper();
              int count = 0;
              for (TaskResponse task in taskList) {
                DBTask dbTask = DBTask();
                dbTask.tId = task.taskId;
                dbTask.assigneeId = task.adminUserId;
                //List<dynamic> memberList = task.memberUserId;
                dbTask.memberId = task.memberUserId;
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
                          showToast(SEND),
                          _launchMainDashboardScreen(dbTask.taskType),
                        }
                    });
              }
            }*/
          } else {
            //dismissDialog(context);
            showToast(SOMETHING_WENT_WRONG);
          }
        } else {
          dismissDialog(context);
          showToast(ERROR);
        }
      } else {
        dismissDialog(context);
      }
    } else {
      dismissDialog(context);
    }
  }

  Future<void> _launchMainDashboardScreen(String taskType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String role = await sharedPreferences.getString(SP_ROLE);
    int index = 1;
    if ('Recurring' == taskType.trim()) {
      index = 2;
    }

    print('going to dashboard');
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(
                  lohginRole: role,
                  pageIndex: index,
                )),
        (Route<dynamic> route) => false);
  }

  dismissDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    //Navigator.pop(context);
    //Navigator.pop(context, true);
    // Navigator.of(context).pop();
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
      /*backgroundColor: Colors.amber[300],*/
      appBar: _isAppbarVisible
          ? AppBar(
              title: Text(
                'New Task',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: LightColors.kPrimaryDark,
              leading: new IconButton(
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  TaskName(ENTER_TASK_NAME, 1, task),
                  SizedBox(
                    height: 10.0,
                  ),
                  /*SubmissionTime(),*/
                  TaskName(ENTER_TASK_DESCRIPTION, 3, task),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    children: [
                      TextFormField(
                        autocorrect: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Point Should Not Be Empty';
                          }
                          return null;
                        },
                        onSaved: (s) {
                          var point = int.parse(s);
                          task.taskPoint = point;
                        },
                        decoration: InputDecoration(
                          hintText: SET_POINTS,
                          hintStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.star,
                            color: LightColors.kPrimary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide:
                                BorderSide(color: Colors.grey[400], width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide:
                                BorderSide(color: Colors.grey[400], width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  /* RadioGroup(
                    task: task,
                    isDateSelect: _isDateVisible,
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(SELECT_TYPE,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Radio(
                        value: 1,
                        groupValue: idOneTime,
                        toggleable: isDailySelect,
                        onChanged: (val) {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            if (idOneTime == -1) {
                              radioButtonItem = 'One Time';
                              idOneTime = 1;
                              isDailySelect = true;
                              // isCustomSelect = false;
                              task.taskType = radioButtonItem;
                              showWidget();
                              //widget.isDateSelect = true;
                            } else {
                              radioButtonItem = '';
                              idOneTime = -1;
                              isDailySelect = false;
                              task.taskType = radioButtonItem;
                              //widget.isDateSelect = false;
                              hideWidget();
                            }
                          });
                        },
                      ),
                      Text(
                        'One Time',
                      ),
                      Radio(
                        value: 2,
                        groupValue: idRecurring,
                        toggleable: isCustomSelect,
                        onChanged: (val) {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            if (idRecurring == -2) {
                              radioButtonItem = 'Recurring';
                              idRecurring = 2;
                              isCustomSelect = true;
                              //isDailySelect = false;
                              task.taskType = radioButtonItem;
                              hideWidget();
                            } else {
                              radioButtonItem = '';
                              idRecurring = -2;
                              isCustomSelect = false;
                              task.taskType = radioButtonItem;
                              showWidget();
                            }
                          });
                        },
                      ),
                      Text('Recurring'),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Visibility(
                      visible: _isDateVisible,
                      child: Column(
                        children: [
                          Text(
                            SET_DATE,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            expands: false,
                            controller: textDateController,
                            keyboardType: TextInputType.datetime,
                            enabled: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.date_range_outlined,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 0)),
                          lastDate: DateTime(2021, 12),
                          builder: (BuildContext context, Widget picker) {
                            return Theme(
                              //TODO: change colors
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: LightColors.kTitle,
                                  onPrimary: Colors.white,
                                  surface: LightColors.kTitle,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: picker,
                            );
                          }).then((selectedDate) {
                        //TODO: handle selected date
                        if (selectedDate != null) {
                          print("Selected date from add task ${selectedDate}");
                          setState(() {
                            final DateFormat formatter =
                                DateFormat('dd/MM/yyyy');
                            final String formatted =
                                formatter.format(selectedDate);
                            print(formatted); // something like 2013-04-20
                            textDateController.text = formatted;
                            task.dueDate = formatted;
                          });
                        }
                      });
                    },
                  ),
                  Visibility(
                    visible: _isDateRangeVisible,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Visibility(
                            visible: true,
                            child: Column(
                              children: [
                               /* Text(
                                  SET_DATE_FROM,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                                TextField(
                                  expands: false,
                                  controller: textFromDateController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: SET_DATE_FROM,
                                    prefixIcon: Icon(
                                      Icons.date_range_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate:
                                    DateTime.now().subtract(Duration(days: 0)),
                                lastDate: DateTime(2021, 12),
                                builder: (BuildContext context, Widget picker) {
                                  return Theme(
                                    //TODO: change colors
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: LightColors.kTitle,
                                        onPrimary: Colors.white,
                                        surface: LightColors.kTitle,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: picker,
                                  );
                                }).then((selectedDate) {
                              //TODO: handle selected date
                              if (selectedDate != null) {
                                print("date from add task ${selectedDate}");
                                setState(() {
                                  final DateFormat formatter =
                                      DateFormat('dd/MM/yyyy');
                                  final String formatted =
                                      formatter.format(selectedDate);
                                  print(formatted); // something like 2013-04-20
                                  textFromDateController.text = formatted;
                                  //task.dueDate = formatted;
                                });
                              }
                            });
                          },
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        GestureDetector(
                          child: Visibility(
                            visible: true,
                            child: Column(
                              children: [
                               /* Text(
                                  SET_DATE_TO,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                                TextField(
                                  expands: false,
                                  controller: textToController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: SET_DATE_TO,
                                    prefixIcon: Icon(
                                      Icons.date_range_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate:
                                    DateTime.now().subtract(Duration(days: 0)),
                                lastDate: DateTime(2021, 12),
                                builder: (BuildContext context, Widget picker) {
                                  return Theme(
                                    //TODO: change colors
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: LightColors.kTitle,
                                        onPrimary: Colors.white,
                                        surface: LightColors.kTitle,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: picker,
                                  );
                                }).then((selectedDate) {
                              //TODO: handle selected date
                              if (selectedDate != null) {
                                print("date to add task ${selectedDate}");
                                setState(() {
                                  final DateFormat formatter =
                                      DateFormat('dd/MM/yyyy');
                                  final String formatted =
                                      formatter.format(selectedDate);
                                  print(formatted); // something like 2013-04-20
                                  textToController.text = formatted;
                                  //task.dueDate = formatted;
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        Text(
                          SET_TIME,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: textTimeController,
                          enabled: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        showPicker(
                          context: context,
                          value: _time,
                          onChange: onTimeChanged,
                          minuteInterval: MinuteInterval.ONE,
                          disableHour: false,
                          disableMinute: false,
                          minMinute: 0,
                          maxMinute: 59,
                          // Optional onChange to receive value as DateTime
                          onChangeDateTime: (DateTime dateTime) {
                            //var dateTimeString = dateTime.toString().split(" ");
                            print("Selected time ${dateTime}");
                            setState(() {
                              var fmt = DateFormat("hh:mm aa").format(dateTime);
                              textTimeController.text = fmt;
                              task.dueTime = fmt;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Visibility(
                    visible: _isWeekDayVisible,
                    child: WeekDaySelectScreen(
                      mTask: task,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Visibility(
                    visible: _isMemberSelectionVisible,
                    child: MultiSelectBottomSheetField<DBMember>(
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      title: Text(MEMBER),
                      buttonText: Text(SELECT_MEMBER),
                      items: _items,
                      searchable: true,
                      validator: (values) {
                        if (values == null || values.isEmpty) {
                          return "Required";
                        }
                      },
                      onConfirm: (values) {
                        setState(() {
                          selectedMemberList = values;
                          for (DBMember dbMember in selectedMemberList) {
                            selectedMemberIdList.add(dbMember.uId);
                          }
                          task.memberUserId = selectedMemberIdList;
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (item) {
                          setState(() {
                            memberList.remove(item);
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    color: LightColors.kPrimaryDark,
                    text: "CREATE TASK",
                    press: () async {
                      if (task != null) {
                        setState(() {
                          if (task.custom != null) {
                            task.custom = task.custom
                                .replaceAll("[", "")
                                .replaceAll("]", "")
                                .trim();
                          }
                        });
                        if (widget.dbMember != null) {
                          List<int> memberIdArray = List<int>();
                          memberIdArray.add(widget.dbMember.uId);
                          task.memberUserId = memberIdArray;
                        }
                        onTaskCreateOnServer(context, widget.dbMember);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskName extends StatelessWidget {
  final String title;
  final int lines;
  final Task task;

  const TaskName(this.title, this.lines, this.task, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        autocorrect: true,
        onSaved: (value) {
          if (lines == 1) {
            task.taskName = value.toString();
          } else {
            task.taskDescription = value.toString();
          }
        },
        maxLines: lines,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20.0),
          hintText: title,
          hintStyle: TextStyle(color: Colors.black),
          fillColor: LightColors.kTitle,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.grey[400], width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}

class RadioGroup extends StatefulWidget {
  final Task task;
  bool isDateSelect;

  RadioGroup({Key key, this.task, this.isDateSelect}) : super(key: key);

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String radioButtonItem;

  // Group Value for Radio Button.
  int id = -1, idMember = -2;
  bool isDailySelect = false;
  bool isCustomSelect = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(SELECT_TYPE, style: TextStyle(fontWeight: FontWeight.bold)),
        Radio(
          value: 1,
          groupValue: id,
          toggleable: isDailySelect,
          onChanged: (val) {
            setState(() {
              if (id == -1) {
                radioButtonItem = 'One Time';
                id = 1;
                isDailySelect = true;
                widget.task.taskType = radioButtonItem;
                widget.isDateSelect = true;
              } else {
                radioButtonItem = '';
                id = -1;
                isDailySelect = false;
                widget.task.taskType = radioButtonItem;
                widget.isDateSelect = false;
              }
            });
          },
        ),
        Text(
          ONE_TIME,
        ),
        Radio(
          value: 2,
          groupValue: id,
          toggleable: isDailySelect,
          onChanged: (val) {
            setState(() {
              if (id == -2) {
                radioButtonItem = 'Recurring';
                id = 2;
                isCustomSelect = true;
                widget.task.taskType = radioButtonItem;
              } else {
                radioButtonItem = '';
                id = -2;
                isCustomSelect = false;
                widget.task.taskType = radioButtonItem;
              }
            });
          },
        ),
        Text(RECURRING),
      ],
    );
  }
}

class WeekDaySelectScreen extends StatelessWidget {
  final Task mTask;

  WeekDaySelectScreen({
    Key key,
    this.mTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examples = <Widget>[
      DisabledExample(
        mTask: mTask,
      ),
      // TODO: use with setstate
    ];
    return Column(children: [
      ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.all(12),
        separatorBuilder: (_, __) => Divider(height: 24),
        itemBuilder: (_, index) => examples[index],
        itemCount: examples.length,
      ),
    ]);
  }
}

class DisabledExample extends StatefulWidget {
  final Task mTask;

  const DisabledExample({
    Key key,
    this.mTask,
  }) : super(key: key);

  @override
  _DisabledExampleState createState() => _DisabledExampleState();
}

class _DisabledExampleState extends State<DisabledExample> {
  //final values = <bool>[false, false, false, false, false, false, false];
  final values = List.filled(7, false);
  List<String> weekList = List<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExampleTitle(SELECT_WEEK_DAYS),
        SizedBox(
          height: 5.0,
        ),
        WeekdaySelector(
          selectedFillColor: LightColors.kTitle,
          onChanged: (v) {
            var week = intDayToEnglish(v);
            setState(() {
              values[v % 7] = !values[v % 7];
              if (weekList.contains(week)) {
                weekList.remove(week.toString());
              } else {
                weekList.add(week.toString());
                setState(() {
                  widget.mTask.custom = weekList.toString();
                });
              }
            });
          },
          values: values,
        ),
      ],
    );
  }
}

class ExampleTitle extends StatelessWidget {
  final String title;

  const ExampleTitle(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }
}

/// Print the integer value of the day and the day that it corresponds to in English.
///
/// It's added to the example so that you can always see and verify that the
/// code is correct.
printIntAsDay(int day) {
  print('Received integer: $day. Corresponds to day: ${intDayToEnglish(day)}');
  var week = intDayToEnglish(day);
}

String intDayToEnglish(int day) {
  if (day % 7 == DateTime.monday % 7) return 'Mon';
  if (day % 7 == DateTime.tuesday % 7) return 'Tue';
  if (day % 7 == DateTime.wednesday % 7) return 'Wed';
  if (day % 7 == DateTime.thursday % 7) return 'Thu';
  if (day % 7 == DateTime.friday % 7) return 'Fri';
  if (day % 7 == DateTime.saturday % 7) return 'Sat';
  if (day % 7 == DateTime.sunday % 7) return 'Sun';
  throw '🐞 This should never have happened: $day';
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
      return alert;
    },
  );
}
