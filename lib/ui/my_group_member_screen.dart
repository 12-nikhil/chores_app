import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/add_task_screen.dart';
import 'package:chores_app/ui/contactsPage.dart';
import 'package:chores_app/utils/Utils.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGroupMember extends StatefulWidget {
  @override
  _MyGroupMemberState createState() => _MyGroupMemberState();
}

class _MyGroupMemberState extends State<MyGroupMember> {
  String title;
  bool flag = false;
  bool insertItem = false;
  bool _isFloatingButtonVisible = false;
  List<DBMember> memberList = List<DBMember>();
  List<DBMember> values;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isRoleAdmin = false;
  ScrollController _scrollController;
  String empty_msg = MEMBER_NOT_FOUND;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSPData();
    _scrollController = new ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  Future<void> getSPData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loginRole = await sp.getString(SP_ROLE);
    setState(() {
      title = sp.getString(SP_GROUP_NAME);
      if (loginRole == null) {
        empty_msg = GROUP_NOT_FOUND;
      } else if ("Admin" == loginRole) {
        _isRoleAdmin = true;
        _isFloatingButtonVisible = true;
      } else {
        empty_msg = MEMBER_NOT_FOUND;
      }
    });
  }

  /*getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });
  }*/
  getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });
  }

  ///Fetch data from database
  Future<List<DBMember>> _getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String mobile = await sp.getString(SP_MOBILE);
    int groupId = await int.parse(sp.getString(SP_GROUP_ID));

    var dbHelper = DatabaseHelper();
    await dbHelper.getAllMemberFilterByMobile(mobile).then((value) {
      if (value != null && value.isNotEmpty) {
        memberList = value;
        if (insertItem) {
          _listKey.currentState.insertItem(values.length);
          insertItem = false;
        }
      }
      return null;
    });

    return memberList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),*/
      body: getAllUser(),
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Visibility(
        visible: _isFloatingButtonVisible,
        child: new FloatingActionButton(
          backgroundColor: LightColors.kPrimary,
          onPressed: () => {checkPermission()},
          child: new Icon(
            Icons.group_add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> checkPermission() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ContactsPage()),
          (Route<dynamic> route) => false);
    } else {
      //If permissions have been denied show standard cupertino alert dialog
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text('Permissions error'),
                content: Text('Please enable contacts access '
                    'permission in system settings'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.permanentlyDenied;
    } else {
      return permission;
    }
  }

  ///create List View with Animation
  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    values = snapshot.data;
    if (values != null && values.isNotEmpty) {
      /* values.sort((a, b) {
        return a[name].toLowerCase().compareTo(b[name].toLowerCase());
      });*/
      showProgress();
      return new AnimatedList(
          key: _listKey,
          controller: _scrollController,
          shrinkWrap: true,
          initialItemCount: values.length,
          itemBuilder: (BuildContext context, int index, animation) {
            return _buildItem(values[index], animation, index);
          });
    } else {
      return Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(empty_msg),
          ),
        ),
      );
    }
  }

  ///Construct cell for List View
  Widget _buildItem(DBMember values, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: EdgeInsets.all(10.0),
        child: ListTile(
          onTap: () => {} /*onItemClick(values)*/,
          title: Row(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: LightColors.kPrimary,
                      child: Text(
                        values.memberName.substring(0, 1).toUpperCase(),
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0)),
                  new Row(
                    children: <Widget>[
                      /* Icon(Icons.account_circle),*/
                      Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                      new InkWell(
                        child: Container(
                          constraints: new BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 200),
                          child: Text(
                            values.memberName,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0)),
                  new Row(
                    children: <Widget>[
                      /*Icon(Icons.phone),*/
                      Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                      new InkWell(
                        child: new Text(
                          values.memberMobile.toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 0.0)),
                      new InkWell(
                        child: Container(
                          child: new Text(
                            values.memberRole,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: "Admin" == values.memberRole
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _isRoleAdmin,
                        child: IconButton(
                            alignment: Alignment.topRight,
                            color: Colors.grey[400],
                            icon: new Icon(Icons.delete),
                            onPressed: () =>
                                showAlertDialog(context, values, index)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                    child: new InkWell(
                      child: Container(
                        child: new Text(
                          values.memberStatus,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            children: <Widget>[
              Flexible(
                  fit: FlexFit.tight,
                  child: Visibility(
                    visible: _isRoleAdmin,
                    child: IconButton(
                        color: LightColors.kPrimaryDark,
                        icon: new Icon(Icons.arrow_forward_ios),
                        onPressed: () => onAddTask(values, index)),
                  )),
              /* Flexible(
                fit: FlexFit.tight,
                child: IconButton(
                    color: Colors.grey[400],
                    icon: new Icon(Icons.delete),
                    onPressed: () => onDelete(values, index)),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  onAddTask(DBMember values, int index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String role = sp.getString(SP_ROLE);
    if ("Admin" == role) {
      if (ACCEPT == values.memberStatus) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ADDTaskScreen(
                      dbMember: values,
                    )));
      } else {
        showToast(TOAST_MSG_NOT_AUTHENTICATED_USER);
      }
    }
  }

  /// Delete Click and delete item
  onDelete(DBMember values, int index) async {
    // first remove it from server
    if (checkInternetConnection() != null) {
      showLoaderDialog(context);
      var response = await deleteUserOnServer(values.uId);
      if (response != null) {
        var id = values.uId;
        print("User id ${id}");
        //var dbHelper = DatabaseHelper();
        //dbHelper.deleteMember(id).then((value) {
        DBMember removedItem = memberList.removeAt(index);

        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return _buildItem(removedItem, animation, index);
        };
        _listKey.currentState.removeItem(index, builder);
        Navigator.of(context).pop();
        //  });
      }
    } else {
      showToast(INTERNET_NOT_CONNECTED_MSG);
    }
  }

  Widget showAlertDialog(BuildContext context, DBMember dbMember, int index) {
    // set up the button
    // ignore: non_constant_identifier_names
    Widget YesButton = FlatButton(
      child: Text(DIALOG_OK),
      onPressed: () {
        Navigator.of(context).pop();
        onDelete(dbMember, index);
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
