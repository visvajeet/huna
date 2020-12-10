
class ContactsModel {

	String _asteriskUsername;
	String _id;
	String _name;
	String _number;
	String _email;
	String _color;
	int _isSaved = 0;
	String _profilePic;


	ContactsModel(this._asteriskUsername, this._id,this._name, this._number, this._color, this._email,this._isSaved,this._profilePic);

	String get id => _id;

	String get asteriskUsername => _asteriskUsername;

	String get name => _name;

	String get number => _number;

	String get email => _email;

	String get color => _color;

	String get profilePic => _profilePic;

	int get saved => _isSaved;


	set name(String name) {
		if (name.length <= 255) {
			this._name = name;
		}
	}
	set number(String number) {
		if (number.length <= 255) {
			this._number = number;
		}
	}

	set color(String color) {
			this._color = color;
	}

	set email(String email) {
		this._email = email;
	}

	set profilePic(String profilePic) {
		this.profilePic = profilePic;
	}

	// Convert a Note object into a Map object
	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['name'] = _name;
		map['number'] = _number;
		map['email'] = _email;
		map['color'] = _color;
		map['profilePic'] = _profilePic;
		map['is_saved'] = _isSaved;
		map['asteriskUsername'] = _asteriskUsername;

		return map;
	}

	// Extract a Note object from a Map object
	// Extract a Note object from a Map object
	ContactsModel.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'] as String;
		this._name = map['name'] as String;
		this._number = map['number'] as String;
		this._email = map['email'] as String;
		this._color = map['color'] as String;
		this._color = map['color'] as String;
		this._profilePic = map['profilePic'] as String;
		this._asteriskUsername = map['asteriskUsername'] as String;
	}
}









