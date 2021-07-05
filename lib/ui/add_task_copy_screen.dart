import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/models/Task.dart';
import 'package:chores_app/ui/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:chores_app/ui/chip_display/multi_select_chip_display.dart';
import 'package:chores_app/ui/dialog/multi_select_dialog_field.dart';
import 'package:chores_app/ui/timepicker/constants.dart';
import 'package:chores_app/ui/timepicker/daynight_timepicker.dart';
import 'package:chores_app/ui/weekday_selector.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:chores_app/utils/multi_select_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ADDTaskCopyScreen extends StatefulWidget {
  final DBMember dbMember;
  final String calligType;

  const ADDTaskCopyScreen({Key key, this.dbMember, this.calligType})
      : super(key: key);

  @override
  _ADDTaskCopyScreenState createState() => _ADDTaskCopyScreenState();
}

class _ADDTaskCopyScreenState extends State<ADDTaskCopyScreen> {
  Task task = new Task();
  final _formKey = GlobalKey<FormState>();
  final _multiSelectKey = GlobalKey<FormFieldState>();
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  bool iosStyle = true;
  List<DBMember> memberList = [];
  List<DBMember> selectedMemberList = [];
  final textDateController = TextEditingController();
  var textTimeController = TextEditingController();
  var _items;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("DbMember ${widget.dbMember.id} ${widget.dbMember.uId}");
    _getTime();
    _getMemberData();
  }

  Future<List<DBMember>> _getMemberData() async {
    var dbHelper = DatabaseHelper();
    List<DBMember> dbMemberList = List<DBMember>();
    await dbHelper.getAllMember().then((value) {
      print("Members ${value}");
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
        .map((member) => MultiSelectItem<DBMember>(member, member.memberName,member.memberMobile))
        .toList();
    return memberList;
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  void _getTime() {
    final String formattedDateTime =
        DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
    setState(() {
      print('Current Time ${formattedDateTime}');
    });
  }

  Future onTaskCreateOnServer(DBMember selectedMember) async {
    var dbHelper = DatabaseHelper();
    SharedPreferences sp = await SharedPreferences.getInstance();
    print("mobile ${sp.getString("mobile")}");
    await dbHelper.getDbMemberByMobile(sp.getString("mobile")).then((value) => {
      print("assignee id ${value}"),
          saveDataOnServer(selectedMember,value, sp),
        });
  }

  void saveDataOnServer(DBMember selectedMember,DBMember dbMember, SharedPreferences sp) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*backgroundColor: Colors.amber[300],*/
      appBar: AppBar(
        title: Text(
          'New Task',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amber[900],
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
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
                  TaskName('Enter Task Name', 1, task),
                  SizedBox(
                    height: 10.0,
                  ),
                  /*SubmissionTime(),*/
                  TaskName('Enter Task Description', 3, task),
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
                          //task.taskPoint = s.toString();
                        },
                        decoration: InputDecoration(
                          hintText: 'Set task point',
                          hintStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.star,
                            color: Colors.amber[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.grey[400], width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.grey[400],width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                 /* Text('Set task point',
                      style: Theme.of(context).textTheme.title),
                  SizedBox(
                    height: 10.0,
                  ),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                      task.taskPoint = rating.toString();
                    },
                  ),*/

                  SizedBox(
                    height: 10.0,
                  ),
                  RadioGroup(
                    task: task,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  FlatButton(onPressed: (){
                    showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2019, 1),
                        lastDate: DateTime(2021,12),
                        builder: (BuildContext context, Widget picker){
                          return Theme(
                            //TODO: change colors
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.amber[600],
                                onPrimary: Colors.white,
                                surface: Colors.amber,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor:Colors.white,
                            ),
                            child: picker,);
                        })
                        .then((selectedDate) {
                      //TODO: handle selected date
                      if(selectedDate!=null){
                        setState(() {
                          textDateController.text = selectedDate.toString();
                        });
                      }
                    });
                  }, child: Text(
                    'Set Date'
                  ),
                  ),
                 TextField(
                   controller: textDateController,
                 ),
                 /* GestureDetector(
                    child: TextField(
                      controller: textDateController,
                    ),
                    onTap: (){
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019, 1),
                          lastDate: DateTime(2021,12),
                          builder: (BuildContext context, Widget picker){
                            return Theme(
                              //TODO: change colors
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.deepPurple,
                                  onPrimary: Colors.white,
                                  surface: Colors.pink,
                                  onSurface: Colors.yellow,
                                ),
                                dialogBackgroundColor:Colors.green[900],
                              ),
                              child: picker,);
                          })
                          .then((selectedDate) {
                        //TODO: handle selected date
                        if(selectedDate!=null){
                          setState(() {
                            textDateController.text = selectedDate.toString();
                          });
                        }
                      });
                    },
                  ),*/
                  FlatButton(
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).push(
                        showPicker(
                          context: context,
                          value: _time,
                          onChange: onTimeChanged,
                          minuteInterval: MinuteInterval.ONE,
                          disableHour: false,
                          disableMinute: false,
                          minMinute: 1,
                          maxMinute: 59,
                          // Optional onChange to receive value as DateTime
                          onChangeDateTime: (DateTime dateTime) {
                            var dateTimeString = dateTime.toString().split(" ");
                            task.dueDate = dateTimeString[0];
                            task.dueTime = dateTimeString[1];
                            setState(() {
                              textTimeController.text = dateTimeString[1].toString();
                            });
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Set task time',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextField(
                    controller: textTimeController,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  WeekDaySelectScreen(mTask: task,),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  MultiSelectBottomSheetField<DBMember>(
                    key: _multiSelectKey,
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
                      /*List<String> names = values.map((e) => e.memberName).toList();
                      if (names.contains("Frog")) {
                        return "Frogs are weird!";
                      }
                      return null;*/
                    },
                    onConfirm: (values) {
                      setState(() {
                        selectedMemberList = values;
                        print("Selected Member Count ${selectedMemberList.length}");
                      });
                      _multiSelectKey.currentState.validate();
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (item) {
                        setState(() {
                          memberList.remove(item);
                        });
                        _multiSelectKey.currentState.validate();
                      },
                    ),
                  ),
                 /* MultiSelectDialogField(
                    onConfirm: (val) {
                      memberList = val;
                      print("Confirm member ${memberList[0].memberName} ${memberList[0].memberRole}");
                    },
                    items: _items,
                    initialValue:
                    memberList, // setting the value of this in initState() to pre-select values.
                  ),*/
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    color: Colors.amber[900],
                    text: "CREATE TASK",
                    press: () async {
                      setState(() {
                       task.custom = task.custom.replaceAll("[", "").replaceAll("]", "").trim();
                      });
                      /*task.memberUserId = widget.dbMember.uId as List<int>;
                      onTaskCreateOnServer(widget.dbMember);*/
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
          fillColor: Colors.amber[200],
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

  const RadioGroup({Key key, this.task}) : super(key: key);

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
        Text('Select task type ',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
              } else {
                radioButtonItem = '';
                id = -1;
                isDailySelect = false;
                widget.task.taskType = radioButtonItem;
              }
            });
          },
        ),
        Text(
          'One Time',
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
        Text('Recurring'),
      ],
    );
  }
}

/*class DropDownMember extends StatefulWidget {
  final Task task;
  final List<DBMember> memberList;
  final String callingType;

  const DropDownMember({
    Key key,
    this.task,
    this.memberList,
    this.callingType,
  }) : super(key: key);

  @override
  _DropDownMemberState createState() => _DropDownMemberState();
}

class _DropDownMemberState extends State<DropDownMember> {
  List<String> kidsList = []; // Option 2
  String selectedKids;
  DBMember selectedMember;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.callingType != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExampleTitle('Assign to'),
          Container(
            padding: EdgeInsets.all(5.0),
            *//* decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.0, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        ),*//*
            child: DropdownButton(
              hint: Text('Please Select Member'),
              // Not necessary for Option 1
              value: selectedKids,
              onChanged: (newValue) {
                setState(() {
                  // selectedKids = newValue;
                  selectedMember = newValue;
                  selectedKids = selectedMember.memberName;
                  // widget.task.memberUserId = selectedMember.id.toString();
                });
              },
              items: widget.memberList.map((location) {
                return DropdownMenuItem(
                  child: new Text(location.memberName),
                  value: location.memberName,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}*/

class WeekDaySelectScreen extends StatelessWidget {
  final Task mTask;
  WeekDaySelectScreen({Key key, this.mTask,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examples = <Widget>[
      DisabledExample(mTask: mTask,),
      // TODO: use with setstate
    ];
    return Column(
        children: [
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
  const DisabledExample({Key key, this.mTask,}) : super(key: key);
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
        ExampleTitle('Select Week Day'),
        SizedBox(height: 5.0,),
        WeekdaySelector(
          selectedFillColor: Colors.amber[800],
          onChanged: (v) {
            var week = intDayToEnglish(v);
            print("Week selected ${week}");
            setState(() {
              values[v % 7] = !values[v % 7];
              if(weekList.contains(week))
              {
                weekList.remove(week.toString());
              }
              else{
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
      child: Text(title, style: Theme.of(context).textTheme.title,),
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
showLoaderDialog(BuildContext context){
  AlertDialog alert=AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 7),child:Text(" Please wait..." ),),
      ],),
  );
  showDialog(barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return WillPopScope(
        child: alert,
        onWillPop: () => Future.value(false),
      );
    },
  );
}

