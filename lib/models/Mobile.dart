class Mobile {
  List<String> mobile;
  String countryCode;

  Mobile({this.mobile,this.countryCode});

  Mobile.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile'].cast<String>();
    countryCode = json['countryCode'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobile'] = this.mobile;
    data['countryCode'] = this.countryCode;
    return data;
  }
}