import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:huna/call/calls_model.dart';
import 'package:huna/constant.dart';
import 'package:huna/contacts/add_contact.dart';
import 'package:huna/contacts/contact_info.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/chat_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class ContactsPage extends StatefulWidget {

  final SIPUAHelper _helper;
  ContactsPage(this._helper, {Key key}) : super(key: key);

  @override
  _ContactsPage createState() => _ContactsPage();
}

class _ContactsPage extends State<ContactsPage> {

  SIPUAHelper get helper => widget._helper;

  TextEditingController _searchController = TextEditingController();
  String filter = "";

  DatabaseHelper db = DatabaseHelper();
  List<ContactsModel> contactsList;
  int count = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => {
    if (contactsList == null) {
        contactsList = List<ContactsModel>(),
    updateContacts()
  }
    }
    );

    _searchController.addListener(() {
      setState(() {
        filter = _searchController.text;
        updateContacts();
        print("AAA" + filter);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;



    return Scaffold(
      body: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: Column(
          children: <Widget>[
            _header(),
            Expanded(
              child: getContactList(),
            )
          ],
        ),
      ),
    );
  }

  _header() {
    return IntrinsicHeight(
        child:
            new Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Flexible(
        child: Card(
            margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            elevation: 4,
            child: Theme(
              data: Theme.of(context).copyWith(
                primaryColor: colorAccent,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'search_contacts'.tr(),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                ),
              ),
            )),
        flex: 4,
      ),
      Flexible(
        child: Padding(
            padding: EdgeInsets.only(left: 5, right: 15, top: 15, bottom: 15),
            child: RaisedButton(
              elevation: 4,
              color: colorAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                navigateToAddContact();
              },
            )),
      )
    ]));
  }

  ListView getContactList() {
    return ListView.builder(
      itemCount: contactsList == null ? 1 : contactsList.length + 1,
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100),
      itemBuilder: (BuildContext context, int position) {
        if (position == 0) {
          // return the header
          var countStr =
              count > 0 ? 'all_contacts'.tr() + " (${count.toString()})" : "";
          return Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10,bottom: 5),
              child: new Text(
                countStr,
                textAlign: TextAlign.end,
                style: TextStyle(
                    letterSpacing: 0.5,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ));
        }
        position -= 1;
        return Card(
          color: Colors.white,
          elevation: 0.5,

          child: Container(
            key: PageStorageKey('myScrollable'),
            child: ExpansionTile(
              initiallyExpanded: false,

              trailing: Icon(
                Icons.face,
                size: 0.0,
              ),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 15.0),
                    child: InkWell(
                      onTap: () {navigateToContactInfoPage(contactsList[position]);},
                      child: CircleAvatar(
                        radius: 22,
                          backgroundImage:
                          NetworkImage(this.contactsList[position].profilePic),
                        backgroundColor:
                            Color(int.parse(this.contactsList[position].color)),
                        child: this.contactsList[position].profilePic.isNotEmpty ? Container() : Text(
                          getFirstLetter(this.contactsList[position].name),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white))
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(this.contactsList[position].name,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      SizedBox(height: 1),
                      Text(this.contactsList[position].number,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54)),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  )
                ],
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        CallManager().makeCall(helper,contactsList[position].id,isVideoCall: false);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 23,
                      icon: Icon(Icons.message, color: Colors.cyan),
                      onPressed: () {
                        ChatManger().makeChat(context, helper, contactsList[position].id, contactsList[position].name, contactsList[position].email);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 28,
                      icon: Icon(Icons.videocam, color: Colors.green),
                      onPressed: () { CallManager().makeCall(helper,contactsList[position].id,isVideoCall: true);},
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.info, color: Colors.grey),
                      onPressed: () {
                        navigateToContactInfoPage(contactsList[position]);
                      },
                    ),
                    IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        addContact(contactsList[position]);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigateToContactInfoPage(ContactsModel contactsList) async {

    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
         return ContactInfoPage(helper,contactsList);
    }));

    if (result == true) {
      _searchController.text = "";
      updateContacts();
    }
  }

  void navigateToAddContact() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddContactPage();
    }));

    if (result == true) {
      _searchController.text = "";
      updateContacts();
    }
  }


  void updateContacts() {
    final Future<Database> dbFuture = db.initializeDatabase();
    var asteriskName = PreferencesManager().getName().toString();
    dbFuture.then((database) {
      Future<List<ContactsModel>> contactListFuture = db.getContactList(asteriskName);
      contactListFuture.then((list) {
        print(list.toString());
        setState(() {
          if (filter.isNotEmpty) {
            var list = this
                .contactsList
                .where(
                    (x) => x.name.toLowerCase().contains(filter.toLowerCase()))
                .toList();
            this.contactsList = list;
            this.count = list.length;
          } else {
            list.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            this.contactsList = list;
            this.count = list.length;
          }
        });
      });
    });
  }

   addContact(ContactsModel contact) async {

     var userMail = await   PreferencesManager().getEmail();
     var loginUserCallerId = await PreferencesManager().getName();

    Show.showLoading(context);

    var body = {
      "user" : userMail,
      'emailId': contact.email,
      "loginUserCallerId" : loginUserCallerId

    };

    print("ADD CONTACT");
    print(body);

    final apiAddContact = await http.post(ADD_CONTACT, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    if (apiAddContact.statusCode == 200) {

      Map<String, dynamic> map = jsonDecode(apiAddContact.body);

      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

      if(map['response'] == "SUCCESS") {

        Show.hideLoading();
        Show.showToast('contact_saved'.tr(),false);

      }

    }else{
      Show.hideLoading();
      Show.showToast('Something went wrong, Please try again later', false);
    }

  }
}
