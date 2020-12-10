class ChatRoom {

  String _roomId;
  String _user1;
  String _user2;


  ChatRoom(this._roomId, this._user1, this._user2,);


  String get roomId => _roomId;
  String get user1 => _user1;
  String get user2 => _user2;


  set roomId(String value) {
    this.roomId = value;
  }

  set user1(String value) {
    this._user1 = value;
  }
  set user2(String value) {
    this._user2 = value;
  }

}