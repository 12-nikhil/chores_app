
import 'package:chores_app/component/rounded_button.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/create_group.dart';
import 'package:chores_app/ui/my_group_member_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Scaffold(
      body:  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.3, 0.3, 0.7, 0.2],
            colors: [
              LightColors.kPrimary,
              LightColors.kPrimary,
              LightColors.kPrimary,
              LightColors.kPrimary
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              WEL_COME,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.white,
                  decoration: TextDecoration.none),
            ),
            SizedBox(height: size.height * 0.07),
            Image.asset(
              WEL_COME_ICON,
              fit: BoxFit.fill,
            ),
            SizedBox(height: size.height * 0.10),
            RoundedButton(
              text: CREATE_GROUP,
              color: LightColors.kPrimaryDark,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CreateGroup();
                    },
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.03),
          ],
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
    );
  }
}
