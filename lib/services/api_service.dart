import 'dart:convert';
import 'package:chores_app/helper/dialog_helper.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/Mobile.dart';
import 'package:chores_app/models/ServerResponse.dart';
import 'package:chores_app/models/Task.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:http/http.dart' as http;
import 'package:chores_app/models/AddMember.dart';
import 'package:chores_app/models/TaskNotificationBody.dart';
import 'package:chores_app/models/TaskReceived.dart';

final String BASE_URL = 'http://128.199.26.79:8080/Chores/api/';
final String REGISTRATION = 'registration';
final String LOGIN = 'login';
final String MY_CONTACT_LIST = 'mycontactlist/users';
final String ADD_JOIN_MEMBER = 'group/join';
final String ACCEPT_REJECT_GROUP = 'group/join/accept/reject';
final String CREATE_TASK = 'task/create';
final String TASK_DELETE = 'delete/task/';
final String MEMBER_DELETE = 'delete/user/';
final String GROUP_DELETE = 'delete/group/';
final String TASK_COMPLETE_STATUS = 'task/complete';
final String GROUP_ACCEPTED_USER = 'group/{group_id}/accept/users'; // it fetch all members  accepted,rejected,pending
final String TASK_ACCEPT_REJECT = 'task/accept/reject/notificationall';
final String TASK_DATA_RECEIVED = 'task/data/received';
final String GROUP_DETAILS_MOBILE_WISE = 'user';

//http://128.199.26.79:8080/Chores/api/group/{id}/accept/users
//http://128.199.26.79:8080/Chores/api/task/accept/reject/notificationall
// ******************** Create Group ********************************

Future<dynamic> createGroup(
    String groupName, String personName, String mobileNumber) async {
  String url = "${BASE_URL}group/create";
  Map<String, String> userCredential = {
    'mobile': mobileNumber,
    'name': personName,
    'groupName': groupName
  };
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(userCredential), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    print("Register response ${response}");
    if (response != null && response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  } catch (error) {
    print(error);
    return null;
  }
  /*var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;*/
}
// ********************** Login *************************************************
Future<ServerResponse> loginWithMobile(
    String mobileNumber) async {
  String url = "${BASE_URL}${LOGIN}/${mobileNumber}";

  try {
    final response = await http
        .get(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print('Login Response ${response.body}');
      return ServerResponse.fromJson(json.decode(response.body));
    } else {
      return ServerResponse.fromJson(json.decode(response.body));
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Register Name and Mobile ********************************
Future<ServerResponse> registerNameMobile(
     String mobileNumber,String personName) async {
  String url = "${BASE_URL}${REGISTRATION}";
  Map<String, String> userCredential = {
    'mobile': mobileNumber,
    'name': personName,
  };
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(userCredential), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      return ServerResponse.fromJson(json.decode(response.body));
    } else {
        return ServerResponse.fromJson(json.decode(response.body));
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Task Data Received *****************************
Future<ServerResponse> taskDataReceived(
    List<dynamic> taskIds,int groupId,int userId) async {
  String url = "${BASE_URL}${TASK_DATA_RECEIVED}";
  TaskReceived taskReceived = TaskReceived();
  taskReceived.taskId = taskIds;
  taskReceived.groupId = groupId.toString();
  taskReceived.userId = userId.toString();
  /*Map<String, dynamic> userCredential = {
    'taskId': taskIds,
    'groupId': groupId.toString(),
    'userId': userId.toString()
  };*/
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(taskReceived), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("task data received response ${response.body}");
      return ServerResponse.fromJson(json.decode(response.body));
    } else {
      return ServerResponse.fromJson(json.decode(response.body));
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Match Contact List ********************************
Future<dynamic> getMatchList(
   Mobile mobile) async {
  String url = "${BASE_URL}${MY_CONTACT_LIST}";
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(mobile), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {

      return response.body;
    } else {
      if(response.body.contains("success")==true){
        ServerResponse serverResponse =
        ServerResponse.fromJson(json.decode(response.body));
        // showMyDialog(context, "Warning", serverResponse.message);
        showToast(serverResponse.message);
      }else{
        return response.body;
      }
    }
  } catch (error) {
    print(error);
    return null;
  }
}

// ******************** Join Group (Add Member) ********************************
Future<dynamic> addMemberJoinGroup(AddGroup addGroup) async {
  String url = "${BASE_URL}${ADD_JOIN_MEMBER}";
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  print("Add Group member ${addGroup}");
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(addGroup), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Group Join Invitation Accept Reject ********************************
Future<dynamic> acceptRejectStatus(String status,int userId,int adminId) async {
  String url = "${BASE_URL}${ACCEPT_REJECT_GROUP}";
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  print("Accept/Reject URL ${url}");
  Map<String, dynamic> userCredential = {
    'status': status,
    'userId': userId,
    'adminId': adminId,
  };
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(userCredential), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Accept/ Reject Response ${response.body}");
      return response.body;
    } else {
      return response.body;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Create New Task ********************************
Future<dynamic> createTaskOnServer(
    Task task) async {
  String url = "${BASE_URL}${CREATE_TASK}";
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  //print("Task json response ${jsonEncoder.convert(task)}");
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(task), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Fetch Group by Group Id ********************************
Future<dynamic> getGroupDataFromServer(
    int groupId) async {
  String url = "${BASE_URL}group/${groupId}/accept/users";
  print("URL  ${url}");
  try {
    final response = await http
        .get(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Group Detail ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Task Accept / Reject ********************************
// {"taskId":"2","userId":"2", "status":"Accept/Reject", "score":"5"}
Future<dynamic> sendTaskAcceptReject(int taskID,int userId,String status,int score,int groupId
   ) async {
  String url = "${BASE_URL}${TASK_ACCEPT_REJECT}";
  print("URL  ${url}");
  Map<String,dynamic> map ={'taskId':taskID,'userId':userId, 'status':status, 'score':score,'groupId':groupId};
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url, body: jsonEncoder.convert(map),headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Task accept reject ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Delete Task ********************************

Future<dynamic> deleteTaskOnServer(
    int taskId,int groupId) async {
  String url = "${BASE_URL}${TASK_DELETE}${taskId}/${groupId}";
  print("URL  ${url}");
  try {
    final response = await http
        .delete(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Task delete ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}

// ******************** Delete User ********************************
Future<dynamic> deleteUserOnServer(
    int memberId) async {
  String url = "${BASE_URL}${MEMBER_DELETE}${memberId}";
  print("URL  ${url}");
  try {
    final response = await http
        .delete(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Member delete ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ******************** Delete Group ********************************
Future<dynamic> deleteGroupOnServer(
    int groupId) async {
  String url = "${BASE_URL}${GROUP_DELETE}${groupId}";
  print("URL  ${url}");
  try {
    final response = await http
        .delete(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Group delete ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}

// ******************** Send task Status ********************************

Future<dynamic> sendTaskStatusOnServer(
    TaskNotificationBody taskNotificationBody) async {
  String url = "${BASE_URL}${TASK_COMPLETE_STATUS}";
  print("URL  ${url}");
  print("TaskNotificationBody  ${taskNotificationBody}");
  JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  try {
    final response = await http
        .post(url,body: jsonEncoder.convert(taskNotificationBody), headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Task complete ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
// ********************** Mobile number wise group details
Future<dynamic> getGroupDataByMobileNoFromServer(
    String mobileNo) async {
  String url = "${BASE_URL}${GROUP_DETAILS_MOBILE_WISE}/${mobileNo}";
  print("URL  ${url}");
  try {
    final response = await http
        .get(url, headers: {
      "Content-Type": "application/json",
    }).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Group Detail ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
/*Future<dynamic> getAlubumFromServer() async {
  String url = "http://demoapi.fractalite.com/api/persons?criteria=";
  print("URL  ${url}");
  try {
    final response = await http
        .get(url).timeout(new Duration(seconds: 30));
    if (response != null && response.statusCode == 200) {
      print("Album Detail ${response.body}");
      return response.body;
    }else{
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}*/
