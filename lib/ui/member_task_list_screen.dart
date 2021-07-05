import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/add_task_screen.dart';
import 'package:chores_app/ui/recurringTaskScreenTab.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';
import 'package:chores_app/ui/pastTaskScreenTab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/ui/onTimeTaskScreenTab.dart';

class MemberTaskListScreen extends StatefulWidget {

  @override
  _MemberTaskListScreenState createState() => _MemberTaskListScreenState();
}

class _MemberTaskListScreenState extends State<MemberTaskListScreen> {
  String role;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var loginType = getRoleFromSP();
    setState(() {
      role = loginType.toString();
    });
  }

  Future<dynamic> getRoleFromSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_ROLE);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: LightColors.kPrimary,
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  text: 'One Time',
                ),
                Tab(
                  text: 'Recurring',
                ),
              ],
            ),
            title: Text('Task List'),
            leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: TabBarView(
            children: [
              OneTimeTaskScreenTab(),
              //UpcomingTaskBody()
              RecurringTaskScreenTab(),
            ],
          ),
        /*  floatingActionButton: new FloatingActionButton(
            backgroundColor: Colors.amber[500],
            onPressed: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ADDTaskScreen())),
            },
            child: new Icon(
              Icons.note_add_sharp,
              color: Colors.white,
            ),
          ),*/
        ),
      ),
    );
  }
}
