import 'dart:convert';

import 'package:chores_app/component/background.dart';
import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/country_code/intl_phone_field.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/ServerResponse.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/create_group.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/ui/registration_screen.dart';
import 'package:chores_app/ui/selection_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/main.dart';
import '../database/entity/DbGroup.dart';
import '../models/AcceptedMembers.dart';
import 'package:chores_app/models/Group.dart';

import '../models/notificationBody/NotificationSaveData.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var mobileNumber, personName;

  Future<void> sendLoginDetailsOnServer(String mobile) async {
    var serverResponse = await loginWithMobile(mobile);
    if (serverResponse != null) {
      Navigator.pop(context);
      if (serverResponse.success) {
        if (serverResponse.status != null) {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(SP_MOBILE, mobile);
          print("subscription ${mobile.replaceAll("+", "").trim()}");
          MyHomePage()
              .createState()
              .subscribeTopic(mobile.replaceAll("+", "").trim());
          showAlertDialog(context, MSG_TITLE_CONGRATULATION, serverResponse);
        } else {
          showAlertDialog(context, MSG_TITLE_MESSAGE, serverResponse);
        }
      } else {
        showAlertDialog(context, MSG_TITLE_MESSAGE, serverResponse);
      }
    }
  }

  showAlertDialog(
      BuildContext context, String title, ServerResponse serverResponse) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        if (serverResponse.success) {
          Navigator.of(context).pop();
          _launchRegistrationScreen(serverResponse.status, 1);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(serverResponse.message),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _launchRegistrationScreen(String status, int type) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String role = await sharedPreferences.getString(SP_ROLE);
    if (type == 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RegistrationScreen()),
          (Route<dynamic> route) => false);
    } else {
      if (UNASSIGN == status) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SelectionScreen()),
            (Route<dynamic> route) => false);
      } else if (ASSIGN == status) {
        if (role == null) {
          getDataFromLogin();
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MainDashboardScreen(
                        lohginRole: role,
                        pageIndex: 0,
                      )),
              (Route<dynamic> route) => false);
        }
      }
    }
  }

  Future<void> getDataFromLogin() async {
    var dbHelper = DatabaseHelper();
    String role = null;
    SharedPreferences sp = await SharedPreferences.getInstance();
    await dbHelper.getAllLoginDetails().then((value) => {
          if (value != null)
            {
              saveDataInSharedPreference(
                  value.userId, value.role, value.mobile, value.name),
              role = value.role,
            }
          else
            {getGroupDataFromServer(dbHelper,sp,role)}
          // openNewScreen(dbHelper,sp,role),
        });
  }

  Future<void> getGroupDataFromServer(DatabaseHelper dbHelper, SharedPreferences sp, String role) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var serverResponse = await getGroupDataByMobileNoFromServer(mobileNumber);
    if (serverResponse != null) {
      MyGroup group = MyGroup.fromJson(json.decode(serverResponse));
      sp.setString(SP_ROLE, group.role);
      getGroupAndMemberByMobileFromServer(context, sp,group.userId, group.groupId);
    }else
      {
        openNewScreen(dbHelper, sp, role,"My Group");
      }
  }

  Future<void> getGroupDetail(
      DatabaseHelper dbHelper, SharedPreferences sp) async {
    await dbHelper.getSingleGroup().then((value) => {
          if (value != null)
            {
              sp.setString(SP_GROUP_ID, value.groupId.toString()),
            }
        });
  }

  Future<void> openNewScreen(
      DatabaseHelper dbHelper, SharedPreferences sp, String role,String gpName) async {
    if (role == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CreateGroup()),
          (Route<dynamic> route) => false);
    } else {
      await getGroupDetail(dbHelper, sp);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MainDashboardScreen(
                    lohginRole: role,
                    pageIndex: 0,
                groupName: gpName,
                  )),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
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
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Center(
                        child: Text(
                          BTN_LOGIN,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                              color: LightColors.kWhite),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: IntlPhoneField(
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        countryCodeTextColor: Colors.white,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Mobile Number Should Not Be Empty';
                          }
                          return null;
                        },
                        onChanged: (phone) {
                          print(phone.completeNumber);
                        },
                        onSaved: (s) {
                          mobileNumber = s.completeNumber;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your mobile number',
                          hintStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          fillColor: LightColors.kTitle,
                          prefixIcon: Icon(
                            Icons.phone,
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
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          _launchRegistrationScreen(null, 0);
                        },
                        child: Center(
                          child: Text(
                            NOT_USER,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: LightColors.kWhite),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: TextFormField(
                        autocorrect: true,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Name Should Not Be Empty';
                          }
                          return null;
                        },
                        onSaved: (s) {
                          personName = s.toString();
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.amber[200],
                          prefixIcon: Icon(
                            Icons.person,
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
                  ),*/
                  SizedBox(
                    height: 40.0,
                  ),
                  RoundedButton(
                    color: LightColors.kPrimaryDark,
                    text: BTN_LOGIN,
                    press: () async {
                      // collect field that data
                      // send data on server
                      // save login type (parent or kid) in shared preference
                      // navigate in dashboard
                      bool result = await checkInternetConnection();
                      if (result) {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            FocusScope.of(context).requestFocus(FocusNode());
                            CircularProgressIndicator(
                              backgroundColor: LightColors.kTitle,
                            );
                          });
                          showLoaderDialog(context);
                          sendLoginDetailsOnServer(mobileNumber);
                        } else {
                          setState(() {
                            showToast("Invalid fields");
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
      ),
    );
  }
}
