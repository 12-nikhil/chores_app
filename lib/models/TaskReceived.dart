class TaskReceived{
  List<int> taskId = List();
  String groupId;
  String userId;

  TaskReceived({this.taskId,this.groupId,this.userId});

  TaskReceived.fromJson(Map<String, dynamic> json) {
    taskId = json['taskId'].cast<int>();
    groupId = json['groupId'].cast<String>();
    userId = json['userId'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taskId'] = this.taskId;
    data['groupId'] = this.groupId;
    data['userId'] = this.userId;
    return data;
  }
}