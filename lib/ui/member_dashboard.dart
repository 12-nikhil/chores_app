import 'dart:convert';

import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/ui/my_group_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MemberDashboard extends StatefulWidget {
  final dynamic notification;
  final bool isNewMember;

  const MemberDashboard({Key key, this.notification, this.isNewMember}) : super(key: key);
  @override
  _MemberDashboardState createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  NotificationGroupJoin groupJoin;
  NotificationTaskComplete taskStatus;
  DBGroup dbGroup;
  String groupName;
  int count;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isNewMember != null) {
     NotificationGroupJoin notificationGroupJoin =
          NotificationGroupJoin.fromJson(json.decode(widget.notification));
      if(notificationGroupJoin!=null)
        {
          setState(() {
            groupJoin = notificationGroupJoin;
            getGroupDetailById();

          });
        }
    } else {
      // var body = widget.notification['data']['body'] ?? '';
      NotificationTaskComplete  notificationTaskComplete =
          NotificationTaskComplete.fromJson(json.decode(widget.notification));
      if(notificationTaskComplete!=null)
      {
        setState(() {
          taskStatus = notificationTaskComplete;
        });
      }
    }
    setState(() {
      if(dbGroup!=null)
        {
          groupName = dbGroup.name;
        }
    });
  }

  Future getGroupDetailById()async{
    var dbHelper = DatabaseHelper();
    await dbHelper.getGroup(groupJoin.group_id).then((value) => {
      dbGroup = value,
      getMemberDetailById(),
    });
  }
  Future getMemberDetailById()async{
    var dbHelper = DatabaseHelper();
    await dbHelper.getDbMemberCountByGroupId(groupJoin.group_id).then((value) => {
      count = value,
    });

  }

  @override
  Widget build(BuildContext context) {

    final memberThumbnail = new Container(
      margin: new EdgeInsets.symmetric(vertical: 10.0),
      alignment: FractionalOffset.centerLeft,
      child: Container(
          width: 92.0,
          height: 92.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                  fit: BoxFit.fill, image: new AssetImage("assets/images/chores_app_group1.png",)
                  )
          )
      ),
    );

    final taskThumbnail = new Container(
      margin: new EdgeInsets.symmetric(vertical: 10.0),
      alignment: FractionalOffset.centerLeft,
      child: Container(
          width: 92.0,
          height: 92.0,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill, image: new AssetImage("assets/images/task_list.png",)
              )
          )
      ),
    );
    final baseTextStyle = const TextStyle(fontFamily: 'Poppins');
    final regularTextStyle = baseTextStyle.copyWith(
        color: Colors.white, fontSize: 9.0, fontWeight: FontWeight.w400);
    final subHeaderTextStyle = regularTextStyle.copyWith(fontSize: 12.0);
    final headerTextStyle = baseTextStyle.copyWith(
        color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600);

    final memberCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(height: 4.0),
          new Text("groupName", style: headerTextStyle),
          new Container(height: 10.0),
          new Text("count.toString()", style: subHeaderTextStyle),
          new Container(
              margin: new EdgeInsets.symmetric(vertical: 4.0),
              height: 1.0,
              width: 18.0,
              color: Colors.amber[400]),
        ],
      ),
    );

    final taskCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(height: 4.0),
          new Text("Task ", style: headerTextStyle),
          new Container(height: 10.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
               children: [
                 Text("Complete ", style: subHeaderTextStyle),
                 SizedBox(
                   height: 20.0,
                 ),
                 Text("60 ", style: subHeaderTextStyle),
               ],
              ),
              Column(
                children: [
                  Text("Pending ", style: subHeaderTextStyle),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("60 ", style: subHeaderTextStyle),
                ],
              )
            ],
          ),
          new Container(
              margin: new EdgeInsets.symmetric(vertical: 4.0),
              height: 1.0,
              width: 18.0,
              color: Colors.amber[400]),
        ],
      ),
    );

    final MemberCard = new Container(
      child: new GestureDetector(
        onTap: ()
        {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              MyGroupMember()), (Route<dynamic> route) => false);
        },
        child: Container(
          child: memberCardContent,
          height: 144.0,
          margin: new EdgeInsets.only(left: 46.0),
          decoration: new BoxDecoration(
            color: Colors.amber[300],
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: new Offset(0.0, 10.0),
              ),
            ],
          ),
        ),
      ),
    );

    final TaskCard = new Container(
      child: new GestureDetector(
        onTap: ()
        {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              MyGroupMember()), (Route<dynamic> route) => false);
        },
        child: Container(
          child: taskCardContent,
          height: 144.0,
          margin: new EdgeInsets.only(left: 46.0),
          decoration: new BoxDecoration(
            color: Colors.amber[300],
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: new Offset(0.0, 10.0),
              ),
            ],
          ),
        ),
      ),
    );


    return Scaffold(
      appBar: AppBar(title: Text('Dashboard',style: TextStyle(color: Colors.white),),
          actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 35.0,
              ),
            )),
      ]),
      body: Center(
        child:Column(
          children: [
            Container(
                height: 150.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: new Stack(
                  children: <Widget>[
                    MemberCard,
                    memberThumbnail,
                  ],
                )
            ),
            Container(
                height: 150.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: new Stack(
                  children: <Widget>[
                    TaskCard,
                    taskThumbnail,
                  ],
                )
            ),
          ],
        )
      )
    );
  }
}
