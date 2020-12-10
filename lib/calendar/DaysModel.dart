class DaysModel {
  bool sun ;
  bool mon ;
  bool tue ;
  bool wed ;
  bool thu ;
  bool fri ;
  bool sat ;

  DaysModel(
      {this.sun, this.mon, this.tue, this.wed, this.thu, this.fri, this.sat});

  DaysModel.fromJson(Map<String, dynamic> json) {
    sun = json['sun'];
    mon = json['mon'];
    tue = json['tue'];
    wed = json['wed'];
    thu = json['thu'];
    fri = json['fri'];
    sat = json['sat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sun'] = this.sun;
    data['mon'] = this.mon;
    data['tue'] = this.tue;
    data['wed'] = this.wed;
    data['thu'] = this.thu;
    data['fri'] = this.fri;
    data['sat'] = this.sat;
    return data;
  }
}
