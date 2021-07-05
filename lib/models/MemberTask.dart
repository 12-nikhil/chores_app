import 'package:chores_app/models/Members.dart';
import 'package:chores_app/models/TaskAssignee.dart';
import 'package:chores_app/models/TaskMember.dart';

class MemberTask
{
  int taskId;
  int adminUserId;
  TaskMember taskMember;
  TaskAssignee taskAssignee;
  int taskPoint;
  int groupId;
  String taskName;
  String taskType;
  String custom;
  String taskDescription;
  String dueDate;
  String dueTime;
}