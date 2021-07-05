class Registration {
  int registrationId;
  String name;
  String mobile;
  String status;
  bool isChecked = false;

  Registration({this.registrationId, this.name, this.mobile, this.status});

  Registration.fromJson(Map<String, dynamic> json) {
    registrationId = json['registrationId'];
    name = json['name'];
    mobile = json['mobile'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['registrationId'] = this.registrationId;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['status'] = this.status;
    return data;
  }
}