class NotificationTaskRecurringIDs {
  String fromDate;
  String toDate;
  int recurringTaskId;
  List<String> taskIds;

  NotificationTaskRecurringIDs(
      {this.fromDate, this.toDate, this.recurringTaskId, this.taskIds});

  NotificationTaskRecurringIDs.fromJson(Map<String, dynamic> json) {
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    recurringTaskId = json['recurringTaskId'];
    taskIds = json['taskIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['recurringTaskId'] = this.recurringTaskId;
    data['taskIds'] = this.taskIds;
    return data;
  }
}