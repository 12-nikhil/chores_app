import 'dart:convert';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/GroupMember.dart';
import 'package:chores_app/models/Mobile.dart';
import 'package:chores_app/models/Registration.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/services/internet_connectivity.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/models/AddMember.dart';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DbMember.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Iterable<Contact> _contacts;
  List<Contact> _contactList = List<Contact>();
  List<Contact> selectedContactList = [];
  List<CustomContact> _uiCustomContacts = List<CustomContact>();
  List<CustomContact> _allContacts = List<CustomContact>();
  List<String> mobileNumberList = List<String>();

  List<Registration> registerMobileList = List<Registration>();
  var isSelected = false;
  var isChecked = false;
  var mycolor = Colors.white;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    //var contactList = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
    _populateContacts(contacts);
  }

  void _populateContacts(Iterable<Contact> contacts) {
    _contactList = contacts.where((item) => item.displayName != null).toList();
    _contactList.sort((a, b) => a.displayName.compareTo(b.displayName));
    _allContacts =
        _contactList.map((contact) => CustomContact(contact: contact)).toList();
    _uiCustomContacts = _allContacts;
    /* setState(() {
      _uiCustomContacts = _allContacts;
    });*/
    getList();
  }

  void getList() {
    for (var i = 0; i < _uiCustomContacts.length; i++) {
      CustomContact _contact = _uiCustomContacts[i];
      var _phonesList = _contact.contact.phones.toList();
      if (_phonesList.length > 0) {
        mobileNumberList.add(_phonesList[0]
            .value
            .replaceAll("-", "")
            .replaceAll(" ", "")
            .trim());
      }
    }
    sendMobileNUmberToServer(mobileNumberList);
  }

  Future<void> sendMobileNUmberToServer(List<String> mList) async {
    SharedPreferences sPs = await SharedPreferences.getInstance();
    String cCode = sPs.getString(SP_COUNTRY_CODE);
    Mobile mobile = Mobile(mobile: mList, countryCode: cCode);
    var response = await getMatchList(mobile);
    setState(() {
      if (response != null) {
        var responseJson = jsonDecode(response) as List;
        registerMobileList = responseJson
            .map((tagJson) => Registration.fromJson(tagJson))
            .toList();

        print("Reg list ${registerMobileList[0].mobile}");
      }
    });
  }

  Future<void> _onSubmit() async {
    List<JoinUsersRequest> groupMemberList = List<JoinUsersRequest>();
    if(registerMobileList.isNotEmpty) {
      for (Registration reg in registerMobileList) {
        JoinUsersRequest groupMember = JoinUsersRequest();
        if (reg.isChecked) {
          groupMember.name = reg.name;
          groupMember.mobile = reg.mobile;
          groupMember.role = "Member";
          //groupMember.role = reg.status;
          groupMemberList.add(groupMember);
        }
      }
      if(groupMemberList.length>0) {
        SharedPreferences sharedPreferences = await SharedPreferences
            .getInstance();
        String groupId = sharedPreferences.getString(SP_GROUP_ID);
        String adminName = sharedPreferences.getString(SP_NAME);
        String adminMobileNo = sharedPreferences.getString(SP_MOBILE);
        int adminId = sharedPreferences.getInt(SP_USER_ID);

        AddGroup addGroup =
        AddGroup(groupId: groupId,
            adminId: adminId,
            adminName: adminName,
            adminMobileNo: adminMobileNo,
            joinUsersRequest: groupMemberList);
        var response = await addMemberJoinGroup(addGroup);
        if (response
            .toString()
            .isNotEmpty) {
          GroupMember group = GroupMember.fromJson(json.decode(response));
          saveDataInLocalDB(group);
        } else {
          Navigator.of(context).pop();
          showToast(ERROR);
        }
      }else{
        Navigator.of(context).pop();
        showToast(MEMBER_NOT_SELECTED);
      }
    }else{
      Navigator.of(context).pop();
      showToast(MEMBER_NOT_FOUND);
    }
  }

  Future<void> saveDataInLocalDB(GroupMember groupMember) async {
    var dbHelper = DatabaseHelper();
    List<UserInfo> userInfoList = groupMember.userInfo;
    createUserInfo(dbHelper, userInfoList,groupMember);
  }

  void createUserInfo(DatabaseHelper dbHelper, List<UserInfo> userInfoList,GroupMember groupMember) {
    int count = 0;
    for (UserInfo userInfo in userInfoList) {
      count++;
      DBMember dbMember = DBMember();
      dbMember.uId = userInfo.userId;
      dbMember.groupId = groupMember.groupId;
      dbMember.memberName = userInfo.name;
      dbMember.memberMobile = userInfo.mobile;
      dbMember.memberRole = userInfo.role;
      dbMember.memberStatus = userInfo.status;
      dbMember.memberCreationDate = userInfo.createdDate;
      dbHelper.insertMember(dbMember).then((value) => {
            if (count == userInfoList.length)
              {
                openAdminDashboard(),
              }
          });
    }
  }

  void openAdminDashboard() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("memberSave", "Saved");
    String role = await sp.getString(SP_ROLE);
    showToast(MEMBER_ADD_REQUEST_SEND_SUCCESSFULLY);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(lohginRole: role,pageIndex: 0,)),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightColors.kPrimary,
        title: (Text(
          MY_CONTACTS,
          style: TextStyle(color: Colors.white),
        )),
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
      body: _contacts != null
          //Build a list view of all contacts, displaying their avatar and
          // display name
          ? ListView.builder(
              itemCount: registerMobileList?.length,
              itemBuilder: (BuildContext context, int index) {
                Registration _contact = registerMobileList[index];
                //var _phonesList = _contact.contact.phones.toList();
                return _buildCard(_contact);
              },
            )
          : Center(child: const CircularProgressIndicator()),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: LightColors.kPrimary,
        onPressed: () => {
          if (checkInternetConnection() != null)
            {showLoaderDialog(context), _onSubmit()}
          else
            {showToast(INTERNET_NOT_CONNECTED_MSG)}
        },
        child: new Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }

  Card _buildCard(Registration c) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: (c.mobile != null)
                ? CircleAvatar(
                    /*backgroundImage: MemoryImage(c.contact.avatar),*/
                    backgroundColor: LightColors.kPrimary,
                    child: Text(
                      c.name[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : CircleAvatar(
                    child: Text((c.name.toUpperCase()),
                        style: TextStyle(color: Colors.white)),
                  ),
            title: Text(c.name ?? ""),
            subtitle: Text(c.mobile),
            trailing: Column(children: <Widget>[
              Checkbox(
                  activeColor: LightColors.kPrimary,
                  value: c.isChecked,
                  onChanged: (bool value) {
                    setState(() {
                      c.isChecked = value;
                    });
                  }),
            ]),
          ),
          /*  RadioGroup(
            registration: c,
          ),*/
        ],
      ),
    );
  }
}

class RadioGroup extends StatefulWidget {
  final Registration registration;

  const RadioGroup({Key key, this.registration}) : super(key: key);

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String radioButtonItem;
  Registration reg;

  // Group Value for Radio Button.
  int id = -1, idMember = -2;
  bool isAdminSelect = false;
  bool isMemberSelect = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reg = widget.registration;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Select Role ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Radio(
          value: 1,
          groupValue: id,
          toggleable: isAdminSelect,
          onChanged: (val) {
            setState(() {
              if (id == -1) {
                radioButtonItem = 'Admin';
                id = 1;
                reg.status = radioButtonItem;
                isAdminSelect = true;
              } else {
                radioButtonItem = '';
                id = -1;
                reg.status = null;
                isAdminSelect = false;
              }
            });
          },
        ),
        Text(
          'Admin',
        ),
        Radio(
          value: 2,
          groupValue: id,
          toggleable: isMemberSelect,
          onChanged: (val) {
            setState(() {
              if (id == -2) {
                radioButtonItem = 'Member';
                id = 2;
                reg.status = radioButtonItem;
                isMemberSelect = true;
              } else {
                radioButtonItem = '';
                id = -2;
                reg.status = null;
                isMemberSelect = false;
              }
            });
          },
        ),
        Text('Member'),
      ],
    );
  }
}

class CustomContact {
  final Contact contact;
  bool isChecked;
  bool isRegister;

  CustomContact({
    this.contact,
    this.isChecked = false,
    this.isRegister = false,
  });
}
