class ChatHistoryModel {

  String _email;
  String _msg;
  String _name;
  String _dateTime;
  int _uuid;
  int _isRead ;

  ChatHistoryModel(this._email, this._msg, this._dateTime,this._uuid,this._name,this._isRead);



  String get email => _email;

  String get msg => _msg;
  String get name => _name;
  String get dateTime => _dateTime;
  int get isRead => _isRead;
  int get uuid => _uuid;



  set message(String value) {
    this._msg = value;
  }

  set isRead(int value) {
    this._isRead = value;
  }

  set name(String value) {
    this._name = value;
  }

  set dateTime (String value) {
    this._dateTime = value;
  }

  set uuid (int value) {
    this._uuid = value;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();

    map['msg'] = _msg;
    map['dateTime'] = _dateTime;
    map['uuid'] = _uuid;
    map['name'] = _name;
    map['isRead'] = _isRead;
    map['email'] = _email;

    return map;
  }

  // Extract a Note object from a Map object
  // Extract a Note object from a Map object
  ChatHistoryModel.fromMapObject(Map<String, dynamic> map) {
    this._msg = map['msg'] as String;
    this._name = map['name'] as String;
    this._dateTime = map['dateTime'] as String;
    this._uuid = map['uuid'] as int;
    this._isRead = map['isRead'] as int;
    this._email= map['email'] as String;

  }
}