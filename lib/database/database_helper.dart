import 'package:huna/auth/user_model.dart';
import 'package:huna/call/calls_model.dart';
import 'package:huna/chat/chat_history_model.dart';
import 'package:huna/chat/chat_model.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const PROFILE_PIC = "profilePic";

const ID = "id";
const EMAIL = "email";
const NAME = "name";
const NUMBER = "number";
const IS_SAVED = "is_saved";
const CONTACT_TABLE = 'contact_table';
const COLOR = 'color';

const DURATION = "duration";
const DATE = "date";
const CALL_TYPE = "call_type";
const CALL_TABLE = 'call_table';

const FULL_NAME = 'FullName';
const USER_EMAIL =  'UserEmail' ;
const USER_PHONE = "UserPhone";
const PROFILE_IMAGE = "ProfileImage";
const ASTERISK_USER_NAME =  'asteriskUsername' ;
const ASTERISK_USER_PASSWORD =  'asteriskPassword' ;
const ORGANIZATION_NAME =  'organizationName' ;
const DOMAIN =  'domain' ;
const ROLE =  'role' ;
const LOGIN_COUNTER =  'loginCounter' ;
const IAT =  'iat' ;
const EXP =  'exp' ;
const USER_TABLE = 'user_table';


class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database



	String msg = "msg";
	String name = "name";
	String msgType = "msgType";
	String url = "url";
	String sender = "sender";
	String uuid = "uuid";
	String dateTime = "dateTime";
	String time = "time";
	String isRead = "isRead";


	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();

		String path = p.join(directory.toString(),'my.db');

		// Open/create the database at a given path
		var myDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return myDatabase;
	}

	void _createDb(Database db, int newVersion) async {
		await db.execute('CREATE TABLE $CONTACT_TABLE($ID TEXT PRIMARY KEY, $ASTERISK_USER_NAME TEXT, $NAME TEXT, $IS_SAVED INTEGER, $EMAIL TEXT, $COLOR TEXT, $NUMBER TEXT,$PROFILE_PIC TEXT)');
		await db.execute('CREATE TABLE $CALL_TABLE($ASTERISK_USER_NAME TEXT, $ID TEXT, $COLOR TEXT, $NAME TEXT, $PROFILE_PIC TEXT, $NUMBER TEXT,$CALL_TYPE TEXT, $EMAIL TEXT, $DATE	 TEXT, $DURATION TEXT)');
		await db.execute('CREATE TABLE $USER_TABLE($ASTERISK_USER_NAME TEXT PRIMARY KEY, '
				'$FULL_NAME TEXT, $USER_EMAIL TEXT, $USER_PHONE TEXT, $PROFILE_IMAGE TEXT, $ASTERISK_USER_PASSWORD TEXT,$ORGANIZATION_NAME TEXT, '
				'$DOMAIN TEXT,  $LOGIN_COUNTER TEXT, $IAT INTEGER, $EXP INTEGER, $ROLE TEXT)');

	}

	// Fetch Operation: Get all table objects from database
	Future<List<Map<String, dynamic>>> getTableMapList(String tableName,String orderBy, {String where,String sortBy= 'ASC'} ) async {
		Database db = await this.database;
		var result;
		if(where !=null) {
			 result =  await db.query(tableName, orderBy: '$orderBy $sortBy',  where: '$ASTERISK_USER_NAME = ?', whereArgs: [where]);
		}else{
			 result = await db.query(tableName, orderBy: '$orderBy $sortBy');

		}
		return result;
	}

	// Fetch Operation: Get all table objects from database where clause
	Future<List<Map<String, dynamic>>> getTableMapListWhere(String tableName,String orderBy, String where, {String sortBy= 'ASC'}) async {
		var asteriskName = await Future.value(PreferencesManager().getName());
		Database db = await this.database;
		var result = await db.query(tableName, orderBy: '$orderBy $sortBy',  where: "$NUMBER = ? AND $ASTERISK_USER_NAME = ?"  , whereArgs: [where,asteriskName]);
		return result;
	}


	// Insert Contact
	Future<int> insertContact(ContactsModel contact) async {
		Database db = await this.database;
		var result = await db.insert(CONTACT_TABLE, contact.toMap(),conflictAlgorithm: ConflictAlgorithm.replace,);
		return result;
	}

	// Insert Call
	Future<int> insertCall(CallsModel call) async {
		Database db = await this.database;
		var result = await db.insert(CALL_TABLE, call.toMap());
		return result;
	}

	// Update Call
	Future<int> updateCall(CallsModel call) async {
		var db = await this.database;
		var result = await db.update(CALL_TABLE, call.toMap(), where: '$ID = ?', whereArgs: [call.id]);
		return result;
	}

	// add User
	Future<int> addUser(Map<String,dynamic> userMap) async {
		Database db = await this.database;
		var result = await db.insert(USER_TABLE, userMap,conflictAlgorithm: ConflictAlgorithm.replace,);
		return result;
	}


	// Update Contact
	Future<int> updateContact(ContactsModel contact) async {
		var db = await this.database;
		var result = await db.update(CONTACT_TABLE, contact.toMap(), where: '$ID = ?', whereArgs: [contact.id]);
		return result;
	}

	// Delete Contact
	Future<int> deleteContact(String id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $CONTACT_TABLE WHERE $ID = $id');
		return result;
	}

	// Get Contacts
	Future<List<ContactsModel>> getContactList(String asteriskName) async {

		var asteriskName = await Future.value(PreferencesManager().getName());
		var contactMapList = await getTableMapList(CONTACT_TABLE, NAME,where: asteriskName); // Get 'Map List' from database
		int count = contactMapList.length;         // Count the number of map entries in db table
		List<ContactsModel> contactList = List<ContactsModel>();
		// For loop to create a 'contact List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			contactList.add(ContactsModel.fromMapObject(contactMapList[i]));
		}
		return contactList;
	}

	Future<List<dynamic>> getContact(String id) async {
		Database db = await this.database;
		var result = await db.query('$CONTACT_TABLE WHERE $ID = $id LIMIT 1');
		return result;
	}

	Future<dynamic> deleteAllFromTable(String tableName) async {
		Database db = await this.database;
		var result =  await db.execute("DELETE FROM $tableName");
		return result;
	}



	// Get Calls
	Future<List<CallsModel>> getCallListAll(String asteriskName) async {

		var callMapList = await getTableMapList(CALL_TABLE, DATE,where: asteriskName,sortBy: 'DESC', ); // Get 'Map List' from database
		int count = callMapList.length;         // Count the number of map entries in db table
		List<CallsModel> callList = List<CallsModel>();
		// For loop to create a 'contact List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			callList.add(CallsModel.fromMapObject(callMapList[i]));
		}
		return callList;
	}

	// Get Calls from only specific number
	Future<List<CallsModel>> getCallListOfNumber(String number) async {

		var callMapList = await getTableMapListWhere(CALL_TABLE, DATE, number,sortBy: 'DESC'); // Get 'Map List' from database
		int count = callMapList.length;         // Count the number of map entries in db table
		List<CallsModel> callList = List<CallsModel>();
		// For loop to create a 'contact List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			callList.add(CallsModel.fromMapObject(callMapList[i]));
		}
		return callList;
	}

	// Get Users
	Future<List<UserModel>> getUserList() async {

		var mapList = await getTableMapList(USER_TABLE,ASTERISK_USER_NAME); // Get 'Map List' from database
		int count = mapList.length;         // Count the number of map entries in db table
		List<UserModel> userList = List<UserModel>();
		// For loop to create a 'contact List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			userList.add(UserModel.fromMapObject(mapList[i]));
		}
		return userList;
	}





}







