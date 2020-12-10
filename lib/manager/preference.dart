import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {

  static final PreferencesManager _singleton = PreferencesManager._internal();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  factory PreferencesManager() {
    return _singleton;
  }

  PreferencesManager._internal();

  Future<void> saveLogin(String displayName,name,password,email,domain,role,wss) async {

    final SharedPreferences prefs = await _prefs;
    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("displayName", displayName);
    prefs.setString("password", password);
    prefs.setString("domain", domain);
    prefs.setString("role", role);
    prefs.setString("wss", wss);

  }

  Future<void> clearPref() async {

    final SharedPreferences prefs = await _prefs;
    prefs.clear();

  }

  Future<void> saveCurrentCallerName(String name) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("currentCallerName", name);
  }

  Future<String> getCurrentCallerName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('currentCallerName') ?? "";
  }

  Future<String> getName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('name') ?? "";
  }



  Future<String> getDisplayName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('displayName') ?? "";
  }

  Future<String> getEmail() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('email') ?? "";
  }

  Future<String> getPassword() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('password') ?? "";
  }

  Future<String> getRole() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('role') ?? "";
  }

  Future<bool> isContactSavedFirstTime() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool('isContactSavedFirstTime') ?? false;
  }

  Future<void> saveIsContactSavedFirstTime(bool value) async {
    final SharedPreferences prefs = await _prefs;
     prefs.setBool('isContactSavedFirstTime',value);
  }

  Future<void> saveToken(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('token',value);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token') ?? "";
  }

  Future<String> getDomain() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('domain') ?? "";
  }

  Future<String> getWss() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('wss') ?? "";
  }

}