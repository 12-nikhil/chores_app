import 'package:chores_app/component/text_field_container.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final Color hintColor,textColor;

  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.hintColor = Colors.white,
    this.textColor = Colors.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        cursorColor:  Colors.amber[200],
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color:  Colors.amber[900],
          ),
          hintText: hintText,
          focusColor: Colors.white,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white)
        ),
        style: TextStyle(color: Colors.white,),

      ),
    );
  }
}
