import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/utils.dart';
import 'package:huna/widgets/my_colors.dart';
import "package:huna/utils/string_extension.dart";

import '../constant.dart';

class Conference extends StatefulWidget {
  @override
  _Conference createState() => new _Conference();
}

class _Conference extends State<Conference> {
  var connected = true;
  var audioMuted = false;
  var speakerOn = true;
  var camOff = false;
  var count = 0;

  var isCallControlsVisible  = false;
  var isWebViewVisible = false;
  var isCallSetupUiVisible = true;
  var isJoinLoading = false;
  var isBackButtonVisible = true;

  InAppWebViewController webView;

  var userName = " ";

  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    getName();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  deactivate() {
    super.deactivate();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: isCallControlsVisible?  Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              child: Container(
                child: connected ? getCallUIButtons() : Container(),
              )) : Container(),
          body:  Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black54, colorAccent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft),
            ),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
              Visibility(
                visible: isWebViewVisible,
                maintainState: true,
                maintainSize: true,
                maintainAnimation: true,
                maintainInteractivity: true,
                child:  webViewUI(),
              ),

              Visibility(
                visible: isCallSetupUiVisible,
                child: callSetupUI(),
              ),
            ],)


          ),
        ),
      ),
    );
  }

  callSetupUI() {

    double marginLeft = 12, marginRight = 12, iconSize = 30;

    return Container(
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        SizedBox(height: 50,width: 10,),
        AvatarGlow(
          glowColor: Colors.white,
          endRadius: 55.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          animate: true,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: Material(
            elevation: 2.0,
            shape: CircleBorder(
              side: BorderSide(width: 2, color: Colors.white),
            ),

            child: CircleAvatar(
              radius: 50,
              backgroundColor: colorAccent,
              child: Text(getFirstLetter(userName),
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                      color: Colors.white)),
            ),
          ),
        ),

        SizedBox(height: 180,width: 10,),

        Container(
          width: 220,
          height: 60,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          padding: const EdgeInsets.all(15.0),
          decoration: new BoxDecoration(
            //you can get rid of below line also
            borderRadius: new BorderRadius.circular(10.0),
            //below line is for rectangular shape
            shape: BoxShape.rectangle,
            //you can change opacity with color here(I used black) for rect
            color: Colors.black.withOpacity(0.5),
            //I added some shadow, but you can remove boxShadow also.,
          ),
          child: Padding(
              padding: const EdgeInsets.all(1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                    child: InkWell(
                      child: camOff
                          ? Icon(Icons.videocam_off,
                          color: Colors.white, size: iconSize)
                          : Icon(Icons.videocam, color: Colors.white, size: iconSize),
                      onTap: () {
                        setState(() {
                          camOff = !camOff;
                        });
                        //widget.onButtonPress("MuteAudio");
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                    child: InkWell(
                      child: audioMuted
                          ? Icon(Icons.mic_off,
                          color: Colors.white, size: iconSize)
                          : Icon(Icons.mic, color: Colors.white, size: iconSize),
                      onTap: () {
                        setState(() {
                          audioMuted = !audioMuted;
                        });
                        //widget.onButtonPress("MuteAudio");
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                    child: InkWell(
                      child: speakerOn
                          ? Icon(Icons.volume_up,
                          color: Colors.white, size: iconSize)
                          : Icon(Icons.volume_down,
                          color: Colors.white, size: iconSize),
                      onTap: () {
                        setState(() {
                          speakerOn = !speakerOn;
                        });
                        // widget.onButtonPress("Speaker");
                      },
                    ),
                  ),

                ],
              ))),

        SizedBox(height: 10,width: 10,),

        Container(
            width: 80,
            height: 45,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            decoration: new BoxDecoration(
              //you can get rid of below line also
              borderRadius: new BorderRadius.circular(5.0),
              //below line is for rectangular shape
              shape: BoxShape.rectangle,
              //you can change opacity with color here(I used black) for rect
              color: Colors.black.withOpacity(0.5),
              //I added some shadow, but you can remove boxShadow also.,
            ),
            child: Padding(
                padding: const EdgeInsets.all(1),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[

                    InkWell(
                      onTap: (){ joinConference(); },
                      child: Visibility(
                        visible: !isJoinLoading,
                          child: Text('Join',style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)),
                    ),

                    Visibility(
                        visible: isJoinLoading,
                        child: Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor : AlwaysStoppedAnimation(Colors.white),
                          ),
                        ))

                  ],
                ))),

        SizedBox(height: 50,width: 10,),
        InkWell(
          onTap: endCall,
          child: Container(
              width: 100,
              height: 40,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              decoration: new BoxDecoration(
                //you can get rid of below line also
                borderRadius: new BorderRadius.circular(5.0),
                //below line is for rectangular shape
                shape: BoxShape.rectangle,
                //you can change opacity with color here(I used black) for rect
                color: Colors.black.withOpacity(0.1),
                //I added some shadow, but you can remove boxShadow also.,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[

                      Visibility(
                             visible:  true,
                            child: Text('Cancel',style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),)),


                    ],
                  ))),
        )

      ],
    ),);

  }

  webViewUI() {

    return Container(
      margin: const EdgeInsets.only(top: 30),
        child: InAppWebView(
            //initialUrl: 'https://SuperficialWatchfulKeys.brijeshdhaka.repl.co',
          initialFile: "assets/html/main.html",
          initialHeaders: {},
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
            debuggingEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            javaScriptCanOpenWindowsAutomatically: true,
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
          )),
          onWebViewCreated: (InAppWebViewController controller) {
            webView = controller;
            addListener();
          //  controller.evaluateJavascript(source: str);

          },
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onLoadStart: (InAppWebViewController controller, String url) {
            setState(() {
              this.url = url;
            });
          },
          onLoadStop: (InAppWebViewController controller, String url) async {
            setState(() {
              this.url = url;
             // startConnect();
            });
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
        ),
    );
  }

  getCallUIButtons() {

    double marginLeft = 12, marginRight = 12, iconSize = 30;

    return Container(
        width: 250,
        height: 60,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        padding: const EdgeInsets.all(15.0),
        decoration: new BoxDecoration(
          //you can get rid of below line also
          borderRadius: new BorderRadius.circular(10.0),
          //below line is for rectangular shape
          shape: BoxShape.rectangle,
          //you can change opacity with color here(I used black) for rect
          color: Colors.black.withOpacity(0.5),
          //I added some shadow, but you can remove boxShadow also.
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black26,
              blurRadius: .0,
              offset: new Offset(1.0, 1.0),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Container(
                  margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                  child: InkWell(
                    child: camOff
                        ? Icon(Icons.videocam_off,
                        color: Colors.white, size: iconSize)
                        : Icon(Icons.videocam, color: Colors.white, size: iconSize),
                    onTap: () {
                      setState(() {
                        camOff = !camOff;
                        if(webView!=null){
                          webView.evaluateJavascript(source: "muteUnMuteMyStream($audioMuted, $camOff)");
                        }
                      });
                      //widget.onButtonPress("MuteAudio");
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                  child: InkWell(
                    child: audioMuted
                        ? Icon(Icons.mic_off,
                            color: Colors.white, size: iconSize)
                        : Icon(Icons.mic, color: Colors.white, size: iconSize),
                    onTap: () {
                      setState(() {
                        audioMuted = !audioMuted;
                        if(webView!=null){
                           webView.evaluateJavascript(source: "muteUnMuteMyStream($audioMuted, $camOff)");
                        }
                      });
                      //widget.onButtonPress("MuteAudio");
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                  child: InkWell(
                    child: speakerOn
                        ? Icon(Icons.volume_up,
                            color: Colors.white, size: iconSize)
                        : Icon(Icons.volume_down,
                            color: Colors.white, size: iconSize),
                    onTap: () {
                      setState(() {
                        speakerOn = !speakerOn;
                        if(webView!=null){
                         // webView.evaluateJavascript(source: "connectOrDisConnectCall()");
                        }
                      });
                      // widget.onButtonPress("Speaker");
                    },
                  ),
                ),
                Visibility(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
                    child: InkWell(
                      child:
                          Icon(Icons.call_end, color: Colors.red, size: iconSize),
                      onTap: () {
                        endCall();
                      },
                    ),
                  ),
                )
              ],
            )));
  }

  void addListener() {

    webView.addJavaScriptHandler(
        handlerName: "allEventHandler",
        callback: (args) {
          print("From the JavaScript side:");
          print(args);

            if ( args.first["identifire"] == "connected" ) {
              print("Success :)");
              if (count == 0) {
                webView.evaluateJavascript(source: "connectOrDisConnectCall()");
                count = 1;
              }
            }

            if ( args.first["identifire"] == "streamAdded") {
              print("StreamAdded Success :) :) :)");
              showWebView();

            }

        });
  }

  void startConnect() {
    if(webView!=null) {
      isBackButtonVisible = false;
      webView.evaluateJavascript(source: "startConnect()");
    }else{
      setState(() {
        isJoinLoading = false;
      });
    }
  }

  void endCall() {
    print("END");
    if(webView!=null) {
      webView.evaluateJavascript(source: "connectOrDisConnectCall()");
    }
    Navigator.pop(context);
  }

  void joinConference() {
    setState(() {
      isJoinLoading = true;
      startConnect();

    });
  }

  showWebView(){
    setState(() {
      isCallSetupUiVisible  = false;
      isCallControlsVisible = true;
      isWebViewVisible = true;
      isJoinLoading = false;
    });
  }

  getName() {

    var pref = PreferencesManager();
    Future.wait([pref.getDisplayName(), pref.getEmail()])
        .then((value) => {
      setState(() {
        if (value[0].isNotEmpty) {
          userName = value[0].capitalize();
        }

      })
    });
  }


}
