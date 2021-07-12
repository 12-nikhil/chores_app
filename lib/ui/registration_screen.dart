import 'package:chores_app/component/background.dart';
import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/country_code/intl_phone_field.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/selection_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/main.dart';


class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  var mobileNumber, personName;
  Future<void> sendRegistrationDetailsOnServer(String mobile,
      String name) async {
    var serverResponse = await registerNameMobile(mobile, name);
    if (serverResponse != null) {
      Navigator.pop(context);
      if (serverResponse.success) {
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        sharedPreferences.setString(SP_MOBILE, mobile);
        sharedPreferences.setString(SP_NAME, name);
        MyHomePage().createState().subscribeTopic(mobile.replaceAll("+", "").trim());
        showAlertDialog(context, MSG_TITLE_CONGRATULATION, serverResponse.message,
            serverResponse.success);
      } else {
        showAlertDialog(
            context, MSG_TITLE_MESSAGE, serverResponse.message, serverResponse.success);
      }
    }
  }

  showAlertDialog(BuildContext context, String title, String message,
      bool result) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        if (result) {
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SelectionScreen()),
                  (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
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
                          fillColor: Colors.amber[200],
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
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    color: LightColors.kPrimaryDark,
                    text: "Register",
                    press: () async {
                      // collect field that data
                      // send data on server
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
                          sendRegistrationDetailsOnServer(
                              mobileNumber, personName);
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

