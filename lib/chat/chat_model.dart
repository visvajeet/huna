class ChatMessages {
  String firstPerson;
  String secondPerson;
  String message;
  String from;
  String createdOn;
  String seenStatus;
  String deletedStatus;

  ChatMessages(
      {this.firstPerson,
        this.secondPerson,
        this.message,
        this.from,
        this.createdOn,
        this.seenStatus,
        this.deletedStatus});

  ChatMessages.fromJson(Map<String, dynamic> json) {
    firstPerson = json['firstPerson'];
    secondPerson = json['secondPerson'];
    message = json['message'];
    from = json['from'];
    createdOn = json['createdOn'];
    seenStatus = json['seenStatus'];
    deletedStatus = json['deletedStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstPerson'] = this.firstPerson;
    data['secondPerson'] = this.secondPerson;
    data['message'] = this.message;
    data['from'] = this.from;
    data['createdOn'] = this.createdOn;
    data['seenStatus'] = this.seenStatus;
    data['deletedStatus'] = this.deletedStatus;
    return data;
  }
}