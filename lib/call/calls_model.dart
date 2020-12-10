

class CallsModel {

	String _asteriskUsername;
	String _id;
	String _name;
	String _number;
	String _callType;
	String _date;
	String _duration;
	String _color;
	int _isSaved = 0;
	String _email;
	String _profilePic;


	CallsModel(this._asteriskUsername, this._id,this._isSaved,this._name, this._number, this._callType, this._date, this._duration,this._color, this._profilePic, this._email );

	String get id => _id;

	String get email => _email;

	String get asteriskUsername => _asteriskUsername;

	String get name => _name;

	String get number => _number;

	String get callType => _callType;

	String get date => _date;

	String get duration => _duration;

	String get color => _color;

	int get saved => _isSaved;

	String get profilePic => _profilePic;


	set duration(String duration) {
		this._duration = duration;
	}


	// Convert a Note object into a Map object
	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		map['id'] = _id;
		map['name'] = _name;
		map['number'] = _number;
		map['call_type'] = _callType;
		map['date'] = _date;
		map['duration'] = _duration;
		map['email'] = _email;
		map['color'] = _color;
		map['asteriskUsername'] = _asteriskUsername;
		map['profilePic'] = _profilePic;

		return map;
	}

	// Extract a Note object from a Map object
	CallsModel.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'] as String;
		this._name = map['name'] as String;
		this._number = map['number'] as String;
		this._callType = map['call_type'] as String;
		this._date = map['date'] as String;
		this._duration= map['duration'] as String;
		this._email= map['email'] as String;
		this._color= map['color'] as String;
		this._color= map['profilePic'] as String;
		this._asteriskUsername= map['asteriskUsername'] as String;
	}
}









