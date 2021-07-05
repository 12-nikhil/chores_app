import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:flutter/material.dart';

class AboutUSScreen extends StatefulWidget {
  const AboutUSScreen({Key key}) : super(key: key);

  @override
  _AboutUSScreenState createState() => _AboutUSScreenState();
}

class _AboutUSScreenState extends State<AboutUSScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(POPUP_ABOUT),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: Text(POPUP_ABOUT),
        ),
      ),
    );
  }
}
