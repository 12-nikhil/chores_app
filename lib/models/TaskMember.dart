class TaskMember {
  int memberId;
  String memberName;
  String memberMobile;
  int assigneeId;
  String assigneeName;
  String assigneeMobile;
  int taskId;
  int taskPoint;
  int groupId;
  String taskName;
  String taskType;
  String custom;
  String taskDescription;
  String dueDate;
  String dueTime;
  int scored;
  String status;
  DateTime taskDueDateTime;
  String lastUpdatedDate;

  TaskMember(
      {this.memberId,
      this.memberName,
      this.memberMobile,
      this.assigneeId,
      this.assigneeName,
      this.assigneeMobile,
      this.taskId,
      this.taskPoint,
      this.groupId,
      this.taskName,
      this.taskType,
      this.custom,
      this.taskDescription,
      this.dueTime,
      this.dueDate,
      this.scored,
      this.status
      ,this.taskDueDateTime,
      this.lastUpdatedDate});

  TaskMember.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    memberName = json['memberName'];
    memberMobile = json['memberMobile'];
    assigneeId = json['assigneeId'];
    assigneeName = json['assigneeName'];
    assigneeMobile = json['assigneeMobile'];
    taskId = json['taskId'];
    taskPoint = json['taskPoint'];
    taskName = json['taskName'];
    taskType = json['taskType'];
    custom = json['custom'];
    taskDescription = json['taskDescription'];
    dueDate = json['dueDate'];
    dueTime = json['dueTime'];
    scored = json['scored'];
    status = json['status'];
    taskDueDateTime = json['taskDueDateTime'];
    lastUpdatedDate = json['lastUpdatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberId'] = memberId;
    data['memberName'] = memberName;
    data['memberMobile'] = memberMobile;
    data['assigneeId'] = assigneeId;
    data['assigneeName'] = assigneeName;
    data['assigneeMobile'] = assigneeMobile;
    data['taskId'] = taskId;
    data['taskPoint'] = taskPoint;
    data['taskName'] = taskName;
    data['taskType'] = taskType;
    data['custom'] = custom;
    data['taskDescription'] = taskDescription;
    data['dueDate'] = dueDate;
    data['dueTime'] = dueTime;
    data['scored'] = scored;
    data['status'] = status;
    data['taskDueDateTime']= taskDueDateTime;
    data['lastUpdatedDate']= lastUpdatedDate;
    return data;
  }
}
