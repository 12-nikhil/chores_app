import 'dart:collection';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/HomeTaskScreenTab.dart';
import 'package:chores_app/ui/about_us_screen.dart';
import 'package:chores_app/ui/add_task_screen.dart';
import 'package:chores_app/ui/my_group_member_screen.dart';
import 'package:chores_app/ui/onTimeTaskScreenTab.dart';
import 'package:chores_app/ui/pastTaskScreenTab.dart';
import 'package:chores_app/ui/recurringTaskScreenTab.dart';
import 'package:chores_app/ui/taskHistoryScreen.dart';
import 'package:chores_app/ui/upcomingTaskScreenTab.dart';
import 'package:chores_app/ui/user_profile_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDashboardScreen extends StatefulWidget {
  final String lohginRole;
  final int pageIndex;
  final String groupName;

  const MainDashboardScreen({Key key, this.lohginRole, this.pageIndex, this.groupName})
      : super(key: key);

  @override
  _MainDashboardScreenState createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String title = "Home";
  String groupName = "MyGroup";
  int _index = 0;
  String type = "A";
  ListQueue<int> _navigationQueue = ListQueue();
  bool canBack = true;
  String _selectedItem = POPUP_MY_ACCOUNT;
  List _options = [POPUP_MY_ACCOUNT, POPUP_TASK_HISTORY, POPUP_ABOUT];

  @override
  void initState() {
    super.initState();
    _index = widget.pageIndex;
    setPageTitle();
    //getGroupNameFromLocalDB();
  }

  int getData() {
    print('GetData');
    return setPageIndex(widget.pageIndex);
  }

  Future<void> getGroupNameFromLocalDB() async {
    /* SharedPreferences sp = await SharedPreferences.getInstance();
    int groupId = int.parse(sp.getString(SP_GROUP_ID));*/
    var dbHelper = DatabaseHelper();
    await dbHelper.getSingleGroup().then((value) => {
          if (value != null)
            {
              //setGroupName(value.name),
              /*if(_index==3)
            {
             // groupName = value.name,
             setGroupName(value.name),
            }*/
            }
        });
  }

 /* void setGroupName(String name) {
    setState(() {
      print("name ${name}");
      groupName = name;
    });
  }*/

  /* Future<int> getData() {
    print('GetData');
    return Future.delayed(Duration(seconds: 2), () {
      return setPageIndex(widget.pageIndex);
    });
  }*/

  Future<bool> _onWillPop() async {
    if (canBack) {
      SystemNavigator.pop();
    }
    if (_navigationQueue.isEmpty) return true;

    setState(() {
      // _index = _navigationQueue.last;
      // _navigationQueue.removeLast();
      if (_index > 0) {
        _index = 0;
        goToWidget2(_index);
        _navigationQueue.clear();
      } else {
        return false;
      }
    });
    return false;
  }

  int setPageIndex(int currentIndex) {
    print('Page Index ${currentIndex}');
    if ("A" == type) {
      if (currentIndex != null) {
        _index = currentIndex;
      } else {
        _index = 0;
      }
      goToWidget2(_index);
    }
    return _index;
  }

  setPageTitle() {
    setState(() {
      if(widget.groupName!=null) {
        groupName =widget.groupName;
      }
      setTitlePage(_index);
    });
    /* String t = setTitlePage(_index);
    title = t;*/
  }

  void goToWidget2(int currentIndex) {
    print('Current Index ${currentIndex}');
    setState(() {
      _index = currentIndex;
      setPageTitle();
      /* String t = setTitlePage(currentIndex);
      title = t;*/
    });
    /* final BottomNavigationBar navigationBar = globalKey.currentWidget;
      navigationBar.onTap(_index);*/
  }

  Widget body() {
    print('Index ${_index}');
    switch (_index) {
      case 0:
        _navigationQueue.add(0);
        canBack = true;
        return HomeTaskScreenTab();
        break;
      case 1:
        _navigationQueue.add(1);
        canBack = false;
        if ("Admin" == widget.lohginRole) {
          return UpcomingTaskScreenTab();
        } else {
          return OneTimeTaskScreenTab();
        }
        break;
      case 2:
        canBack = false;
        _navigationQueue.add(2);
        if ("Admin" == widget.lohginRole) {
          return PastTaskScreenTab();
        } else {
          return RecurringTaskScreenTab();
        }
        break;
      case 3:
        _navigationQueue.add(3);
        canBack = false;
        return MyGroupMember();
        break;
      case 4:
        _navigationQueue.add(4);
        canBack = false;
        return ADDTaskScreen();
        break;
    }
  }

  String setTitlePage(int index) {
    switch (index) {
      case 0:
        title = "Home";
        break;
      case 1:
        title = "One Time Task";
        break;
      case 2:
        title = "Repeat Task";
        break;
      case 3:
        title = groupName;
        //getGroupNameFromLocalDB();
        break;
      case 4:
        title = "Add Task";
        break;
    }
    return title;
  }

  /* String setTitlePage(int index) {
    switch (index) {
      case 0:
        return "Home";
        break;
      case 1:
        return "One Time Task";
        break;
      case 2:
        return "Repeat Task";
        break;
      case 3:
        return "My Group";
        break;
      case 4:
        return "Add Task";
        break;
    }
  }*/

  void handlePopupClick(String value) {
    switch (value) {
      case POPUP_MY_ACCOUNT:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
      case POPUP_TASK_HISTORY:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskHistoryScreen(
                      loginRole: widget.lohginRole,
                    )));
        break;
      case POPUP_ABOUT:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AboutUSScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if ("Admin" == widget.lohginRole) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: LightColors.kPrimary,
            centerTitle: true,
            actions: [
              PopupMenuButton(
                itemBuilder: (BuildContext bc) {
                  return _options
                      .map((day) => PopupMenuItem(
                            child: Text(day),
                            value: day,
                          ))
                      .toList();
                },
                onSelected: (value) {
                  setState(() {
                    handlePopupClick(value);
                  });
                },
              ),
            ],
            /* actions: <Widget>[
              IconButton(
                icon: Icon(Icons.person_pin),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfileScreen()));
                },
              ),
            ],*/
          ),
          body: body(),
          /* body: FutureBuilder(
          builder: (context, snapshot) {
            return body();
          },
          future: getData(),
        ),*/
          bottomNavigationBar: new BottomNavigationBar(
            currentIndex: _index,
            backgroundColor: Colors.green,
            selectedItemColor: Colors.blue,
            onTap: (index) => {setPageIndex(index)},
            items: [
              new BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: LightColors.kPrimary,
                ),
                title: Text('Home'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(
                  Icons.event,
                  color: LightColors.kPrimary,
                ),
                title: Text('One Time'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(
                  Icons.repeat_one_outlined,
                  color: LightColors.kPrimary,
                ),
                title: Text('Repeat'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(
                  Icons.group,
                  color: LightColors.kPrimary,
                ),
                title: Text('My Group'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_box_outlined,
                  color: LightColors.kPrimary,
                ),
                title: Text('Add Task'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            title: Text(title),
            backgroundColor: LightColors.kPrimary,
            centerTitle: true,
            actions: [
              PopupMenuButton(
                itemBuilder: (BuildContext bc) {
                  return _options
                      .map((day) => PopupMenuItem(
                            child: Text(day),
                            value: day,
                          ))
                      .toList();
                },
                onSelected: (value) {
                  setState(() {
                    handlePopupClick(value);
                  });
                },
              ),
            ]),
        body: body(),
        /*body: FutureBuilder(
          builder: (context, snapshot) {
            return body();
          },
          future: getData(),
        ),*/
        bottomNavigationBar: new BottomNavigationBar(
          currentIndex: setPageIndex(_index),
          backgroundColor: Colors.green,
          selectedItemColor: Colors.blue,
          onTap: (index) => setPageIndex(index),
          items: [
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: LightColors.kPrimary,
              ),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.event,
                color: LightColors.kPrimary,
              ),
              title: Text('One Time'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.repeat_one_outlined,
                color: LightColors.kPrimary,
              ),
              title: Text('Repeat'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
                color: LightColors.kPrimary,
              ),
              title: Text('My Group'),
            ),
          ],
        ),
      );
    }
  }
}
