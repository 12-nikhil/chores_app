import 'dart:convert';

import 'package:chores_app/component/background.dart';
import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbLogin.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/Group.dart';
import 'package:chores_app/models/ServerResponse.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/group_member.dart';
import 'package:chores_app/ui/my_group_member_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/helper/dialog_helper.dart';
import 'package:http/http.dart' as http;

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  String groupName;
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> createGroupOnServer(
      String groupName, String name, String mobileNumber) async {
    if (_formKey.currentState.validate()) {
      //dynamic response = await createGroup(groupName, name,mobileNumber);
      String url = "${BASE_URL}group/create";
      Map<String, String> userCredential = {
        'mobile': mobileNumber,
        'name': name,
        'groupName': groupName
      };
      JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
      try {
        final response = await http
            .post(url, body: jsonEncoder.convert(userCredential), headers: {
          "Content-Type": "application/json",
        }).timeout(new Duration(seconds: 30));
        try {
          Navigator.pop(context);  //  pop dialog box .
          if (response != null && response.statusCode == 200) {
            MyGroup group = MyGroup.fromJson(json.decode(response.body));
            if (group != null) {
              saveGroupDataInSharedPreference(group.groupId.toString(), group.userId, group.role, groupName); // save to shared preference
              saveLoginDataInLocal(context, group);
              saveGroupDataInLocal(context, group);
            }
          } else {
            ServerResponse serverResponse =
                ServerResponse.fromJson(json.decode(response.body));
            showMyDialog(context, MSG_TITLE_WARNING, serverResponse.message);
          }
        } catch (error) {
          print(error);
        }
      } catch (error) {
        showMyDialog(context, DIALOG_WARNING, DIALOG_SOMETHING_WRONG);
      }
    } else {
      showMyDialog(context, DIALOG_WARNING, DIALOG_SOMETHING_WRONG);
    }
  }

  void saveGroupDataInLocal(BuildContext context, MyGroup group) async {
    DBGroup dbGroup = DBGroup();
    dbGroup.groupId = group.groupId;
    dbGroup.name = group.groupName;
    dbGroup.mobile = group.mobile;
    var dbHelper = DatabaseHelper();
    dbHelper.insert(dbGroup).then((value) => {
          saveMemberDataInLocal(context, dbHelper, group),
        });
  }

  Future<void> saveMemberDataInLocal(
      BuildContext context, DatabaseHelper dbHelper, MyGroup group) async {
    DBMember dbMember = DBMember();
    dbMember.uId = group.userId;
    dbMember.groupId = group.groupId;
    dbMember.memberName = group.name;
    dbMember.memberMobile = group.mobile;
    dbMember.memberRole = group.role;
    dbMember.memberCreationDate = group.createdDate;
    dbMember.memberStatus = group.status;
    dbHelper.insertMember(dbMember).then((value) => {lauchScreen(context)});
  }

  Future<void> lauchScreen(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => GroupMembers(
                  callingFrom: "C",         //calling type
                )),
        (Route<dynamic> route) => false);
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
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: LightColors.kPrimary,
        body: Form(
          key: _formKey,
          child: Background(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: new BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 40.0, // soften the shadow
                                spreadRadius: 5.0, //extend the shadow
                                offset: Offset(
                                  10.0, // Move to right 10  horizontally
                                  10.0, // Move to bottom 10 Vertically
                                ),
                              )
                            ],
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    "assets/images/chores_app_group1.png")))),
                  ),
                  /* ClipRect(
            child: Image.asset(  "assets/images/chores_app_group1.png",
              height: 150.0,
              width: 100.0,
            ),
            clipper: Cli,
          ),*/
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: TextFormField(
                        autocorrect: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Group Name Should Not Be Empty';
                          }
                          return null;
                        },
                        onSaved: (s) {
                          groupName = s.toString();
                        },
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your group name',
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: LightColors.kTitle,
                          prefixIcon: Icon(
                            Icons.group,
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    color: LightColors.kPrimaryDark,
                    text: "CREATE GROUP",
                    press: () async {
                      // collect field that data
                      // send data on server
                      // save login type (parent or kid) in shared preference
                      // navigate in dashboard
                      bool result = await checkInternetConnection();
                      print("Internet connection ${result}");
                      if (result) {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            // show progress dialog
                            FocusScope.of(context).requestFocus(FocusNode());
                            CircularProgressIndicator(
                              backgroundColor: LightColors.kTitle,
                            );
                          });
                          showLoaderDialog(context);
                          SharedPreferences sp =
                              await SharedPreferences.getInstance();
                          var mobile = sp.getString("mobile");
                          var name = sp.getString("name");
                          createGroupOnServer(groupName, name, mobile);
                        } else {
                          setState(() {
                            showToast("Invalid Text");
                          });
                        }
                      } else {
                        setState(() {
                          showToast(INTERNET_NOT_CONNECTED_MSG);
                        });
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: new FloatingActionButton.extended(
          backgroundColor: LightColors.kPrimaryDark,
          label: Text(
            LABEL_SKIP,
            style: TextStyle(color: LightColors.kWhite),
          ),
          icon: Icon(Icons.skip_next,color: LightColors.kWhite,),
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyGroupMember()),
            ),
          },
        ),
      ),
    );
  }

  Future<void> saveLoginDataInLocal(BuildContext context, MyGroup group) async {
    DbLogin dbLogin = DbLogin();
    dbLogin.userId = group.userId;
    dbLogin.name = group.name;
    dbLogin.mobile = group.mobile;
    dbLogin.role = group.role;
    var dbHelper = DatabaseHelper();
    await dbHelper.insertLogin(dbLogin).then((value) => {
          print('Login details save successfully ${value.role} ${value.userId}')
        });
  }
}
