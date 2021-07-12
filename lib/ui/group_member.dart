import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/contactsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupMembers extends StatefulWidget {
  final String callingFrom;

  const GroupMembers({Key key, this.callingFrom}) : super(key: key);

  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  String get name => null;

  String get mobile => null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkPermission();
  }

  Future<void> checkPermission() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => ContactsPage()),
              (Route<dynamic> route) => false);
    } else {
      //If permissions have been denied show standard cupertino alert dialog
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              CupertinoAlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kPrimary,
    );
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {

    await Permission.contacts.request();
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
}
