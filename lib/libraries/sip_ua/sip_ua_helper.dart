import 'dart:async';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/show.dart';
import 'package:logger/logger.dart';

import 'config.dart';
import 'constants.dart' as DartSIP_C;
import 'event_manager/event_manager.dart';
import 'logger.dart';
import 'message.dart';
import 'rtc_session.dart';
import 'socket.dart';
import 'stack_trace_nj.dart';
import 'transports/websocket_interface.dart';
import 'ua.dart';

class SIPUAHelper extends EventManager {
  bool firstTimeSpeakerOff = true;

  UA _ua;
  Settings _settings;
  UaSettings _uaSettings;
  @override
  final Log logger = Log();
  final Map<String, Call> _calls = {};

  RegistrationState _registerState =
      RegistrationState(state: RegistrationStateEnum.NONE);

  SIPUAHelper() {
    Log.loggingLevel = Level.debug;
  }

  set loggingLevel(Level loggingLevel) => Log.loggingLevel = loggingLevel;

  bool get registered {
    if (_ua != null) {
      return _ua.isRegistered();
    }
    return false;
  }

  bool get connected {
    if (_ua != null) {
      return _ua.isConnected();
    }
    return false;
  }

  RegistrationState get registerState => _registerState;

  void stop() async {
    if (_ua != null) {
      await _ua.stop();
    } else {
      Log.w('ERROR: stop called but not started, call start first.');
    }
  }

  void register() {
    assert(_ua != null,
        'register called but not started, you must call start first.');
    _ua.register();
  }

  void unregister([bool all = true]) {
    if (_ua != null) {
      assert(!registered, 'ERROR: you must call register first.');
      _ua.unregister(all: all);
    } else {
      Log.e('ERROR: unregister called, you must call start first.');
    }
  }

  Future<bool> call(String target, [bool voiceonly = false]) async {
    if (_ua != null && _ua.isConnected()) {
      _ua.call(target, _options(voiceonly));
      return true;
    } else {
      logger.error(
          'Not connected, you will need to register.', null, StackTraceNJ());
    }
    return false;
  }

  Call findCall(String id) {
    return _calls[id];
  }

  void start(UaSettings uaSettings) async {
    if (_ua != null) {
      logger.warn(
          'UA instance already exist!, stopping UA and creating a new one...');
      _ua.stop();
    }

    _uaSettings = uaSettings;

    _settings = Settings();
    var socket = WebSocketInterface(
        uaSettings.webSocketUrl, uaSettings.webSocketSettings);
    _settings.sockets = [socket];
    _settings.uri = uaSettings.uri;
    _settings.password = uaSettings.password;
    _settings.ha1 = uaSettings.ha1;
    _settings.display_name = uaSettings.displayName;
    _settings.authorization_user = uaSettings.authorizationUser;
    _settings.user_agent = uaSettings.userAgent ?? DartSIP_C.USER_AGENT;

    try {
      _ua = UA(_settings);
      _ua.on(EventSocketConnecting(), (EventSocketConnecting event) {
        logger.debug('connecting => ' + event.toString());
        _notifyTransportStateListeners(
            TransportState(TransportStateEnum.CONNECTING));
      });

      _ua.on(EventSocketConnected(), (EventSocketConnected event) {
        logger.debug('connected => ' + event.toString());
        _notifyTransportStateListeners(
            TransportState(TransportStateEnum.CONNECTED));
      });

      _ua.on(EventSocketDisconnected(), (EventSocketDisconnected event) {
        logger.debug('disconnected => ' + (event.cause.toString()));
        _notifyTransportStateListeners(TransportState(
            TransportStateEnum.DISCONNECTED,
            cause: event.cause));
      });

      _ua.on(EventRegistered(), (EventRegistered event) {
        logger.debug('registered => ' + event.cause.toString());
        _registerState = RegistrationState(
            state: RegistrationStateEnum.REGISTERED, cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua.on(EventUnregister(), (EventUnregister event) {
        logger.debug('unregistered => ' + event.cause.toString());
        _registerState = RegistrationState(
            state: RegistrationStateEnum.UNREGISTERED, cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua.on(EventRegistrationFailed(), (EventRegistrationFailed event) {
        logger.debug('registrationFailed => ' + (event.cause.toString()));
        _registerState = RegistrationState(
            state: RegistrationStateEnum.REGISTRATION_FAILED,
            cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua.on(EventNewRTCSession(), (EventNewRTCSession event) {
        logger.debug('newRTCSession => ' + event.toString());
        var session = event.session;
        if (session.direction == 'incoming') {
          // Set event handlers.
          session
              .addAllEventHandlers(_options()['eventHandlers'] as EventManager);
        }
        _calls[event.id] =
            Call(event.id, session, CallStateEnum.CALL_INITIATION);
        _notifyCallStateListeners(
            event, CallState(CallStateEnum.CALL_INITIATION));
      });

      this._ua.on(EventNewMessage(), (EventNewMessage event) {
        logger.debug('newMessage => ' + event.toString());
        //Only notify incoming message to listener
        if (event.message.direction == 'incoming') {
          SIPMessageRequest message = new SIPMessageRequest(
              event.message, event.originator, event.request);
          _notifyNewMessageListeners(message);
        }
      });

      _ua.start();
    } catch (event, s) {
      logger.error(event.toString(), null, s);
    }
  }

  Map<String, Object> buildCallOptions([bool voiceonly = false]) =>
      _options(voiceonly);

  Map<String, Object> _options([bool voiceonly = false]) {
    // Register callbacks to desired call events
    var eventHandlers = EventManager();
    eventHandlers.on(EventCallConnecting(), (EventCallConnecting event) {
      logger.debug('call connecting');
      handelFailedAndOther("connecting") ;
      _notifyCallStateListeners(event, CallState(CallStateEnum.CONNECTING));
    });
    eventHandlers.on(EventCallProgress(), (EventCallProgress event) {
      logger.debug('call is in progress');
      _notifyCallStateListeners(event,
          CallState(CallStateEnum.PROGRESS, originator: event.originator));
    });
    eventHandlers.on(EventCallFailed(), (EventCallFailed event) {

      handelFailedAndOther(event.cause.cause,event.originator) ;

      logger.debug('call failed with cause: ' + (event.cause.toString()));
      _notifyCallStateListeners(
          event,
          CallState(CallStateEnum.FAILED,
              originator: event.originator, cause: event.cause));
      _calls.remove(event.id);
    });
    eventHandlers.on(EventCallEnded(), (EventCallEnded event) {
      handelFailedAndOther("other") ;
      logger.debug('call ended with cause: ' + (event.cause.toString()));
      _notifyCallStateListeners(
          event,
          CallState(CallStateEnum.ENDED,
              originator: event.originator, cause: event.cause));
      _calls.remove(event.id);
    });
    eventHandlers.on(EventCallAccepted(), (EventCallAccepted event) {
      logger.debug('call accepted');
      handelFailedAndOther("Accepted") ;
      _notifyCallStateListeners(event, CallState(CallStateEnum.ACCEPTED));
    });
    eventHandlers.on(EventCallConfirmed(), (EventCallConfirmed event) {
      logger.debug('call confirmed');
      _notifyCallStateListeners(event, CallState(CallStateEnum.CONFIRMED));
    });
    eventHandlers.on(EventCallHold(), (EventCallHold event) {
      logger.debug('call hold');
      _notifyCallStateListeners(
          event, CallState(CallStateEnum.HOLD, originator: event.originator));
    });
    eventHandlers.on(EventCallUnhold(), (EventCallUnhold event) {
      logger.debug('call unhold');
      _notifyCallStateListeners(
          event, CallState(CallStateEnum.UNHOLD, originator: event.originator));
    });
    eventHandlers.on(EventCallMuted(), (EventCallMuted event) {
      logger.debug('call muted');
      _notifyCallStateListeners(
          event,
          CallState(CallStateEnum.MUTED,
              audio: event.audio, video: event.video));
    });
    eventHandlers.on(EventCallUnmuted(), (EventCallUnmuted event) {
      logger.debug('call unmuted');
      _notifyCallStateListeners(
          event,
          CallState(CallStateEnum.UNMUTED,
              audio: event.audio, video: event.video));
    });
    eventHandlers.on(EventStream(), (EventStream event) async {
      // Wating for callscreen ready.
      Timer(Duration(milliseconds: 100), () {
        _notifyCallStateListeners(
            event,
            CallState(CallStateEnum.STREAM,
                stream: event.stream, originator: event.originator));
      });
    });
    eventHandlers.on(EventCallRefer(), (EventCallRefer refer) async {
      logger.debug('Refer received, Transfer current call to => ${refer.aor}');
      _notifyCallStateListeners(
          refer, CallState(CallStateEnum.REFER, refer: refer));
      //Always accept.
      refer.accept((session) {
        logger.debug('New session initialized.');
      }, _options(true));
    });

    var _defaultOptions = {
      'eventHandlers': eventHandlers,
      'pcConfig': {'iceServers': _uaSettings.iceServers},
      'mediaConstraints': {
        'audio': true,
        'video': voiceonly
            ? false
            : {
                'mandatory': {
                  'minWidth': '640',
                  'minHeight': '480',
                  'minFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': List<dynamic>(),
              }
      },
      'rtcOfferConstraints': {
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': !voiceonly,
        },
        'optional': List<dynamic>(),
      },
      'rtcAnswerConstraints': {
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': true,
        },
        'optional': List<dynamic>(),
      },
      'rtcConstraints': {
        'mandatory': Map<dynamic, dynamic>(),
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      },
      'sessionTimersExpires': 300
    };
    return _defaultOptions;
  }

  Message sendMessage(String target, String body,
      [Map<String, dynamic> options]) {
    return this._ua.sendMessage(target, body, options);
  }

  void terminateSessions(Map<String, dynamic> options) {
    this._ua.terminateSessions(options);
  }

  Set<SipUaHelperListener> _sipUaHelperListeners = Set<SipUaHelperListener>();

  void addSipUaHelperListener(SipUaHelperListener listener) {
    _sipUaHelperListeners.add(listener);
  }

  void removeSipUaHelperListener(SipUaHelperListener listener) {
    _sipUaHelperListeners.remove(listener);
  }

  void _notifyTransportStateListeners(TransportState state) {
    _sipUaHelperListeners.forEach((listener) {
      listener.transportStateChanged(state);
    });
  }

  void _notifyRegsistrationStateListeners(RegistrationState state) {
    _sipUaHelperListeners.forEach((listener) {
      listener.registrationStateChanged(state);
    });
  }

  void _notifyCallStateListeners(CallEvent event, CallState state) {
    var call = _calls[event.id];
    if (call == null) {
      logger.e('Call ${event.id} not found!');
      return;
    }
    call.state = state.state;
    _sipUaHelperListeners.forEach((listener) {
      listener.callStateChanged(call, state);
    });
  }

  void _notifyNewMessageListeners(SIPMessageRequest msg) {
    _sipUaHelperListeners.forEach((listener) {
      listener.onNewMessage(msg);
    });
  }

  void handelFailedAndOther(String event, [String originator = ""]) {}

}

enum CallStateEnum {
  NONE,
  STREAM,
  UNMUTED,
  MUTED,
  CONNECTING,
  PROGRESS,
  FAILED,
  ENDED,
  ACCEPTED,
  CONFIRMED,
  REFER,
  HOLD,
  UNHOLD,
  CALL_INITIATION
}

class Call {
  String _id;
  CallStateEnum _stateEnum;
  RTCSession session;
  Call(this._id, this.session, this._stateEnum);

  set state(CallStateEnum state) {
    _stateEnum = state;
  }

  CallStateEnum get state => _stateEnum;

  String get id => _id;

  void answer(Map<String, Object> options) {
    assert(session != null, 'ERROR(answer): rtc session is invalid!');
    session.answer(options);
  }

  void blindRefer(String target) {

    assert(session != null, 'ERROR(refer): rtc session is invalid!');
    var refer = session.refer(target);

    refer.on(EventReferTrying(), (EventReferTrying data) {
      Show.showToast("Transferring...", false);

    });
    refer.on(EventReferProgress(), (EventReferProgress data) {
      Show.showToast("In Progress...", false);

    });
    refer.on(EventReferAccepted(), (EventReferAccepted data) {
      Show.showToast("Confirmed...", false);
      session.terminate();
    });
    refer.on(EventReferFailed(), (EventReferFailed data) {
      Show.showToast("Failed...", false);
    });

  }

  void attendedRefer(String target) {

    assert(session != null, 'ERROR(refer): rtc session is invalid!');

    var refer = session.refer(target);

    refer.on(EventReferTrying(), (EventReferTrying data) {
      Show.showToast("Transferring...", false);
    });
    refer.on(EventReferProgress(), (EventReferProgress data) {
      Show.showToast("In Progress...", false);
    });
    refer.on(EventReferAccepted(), (EventReferAccepted data) {
      Show.showToast("Confirmed...", false);
     // session.terminate();
    });
    refer.on(EventReferFailed(), (EventReferFailed data) {
      Show.showToast("Failed...", false);
    });

  }

  void hangup() {
    assert(session != null, 'ERROR(hangup): rtc session is invalid!');

    session.terminate();
  }

  void hold() {
    assert(session != null, 'ERROR(hold): rtc session is invalid!');
    session.hold();
  }

  void unhold() {
    assert(session != null, 'ERROR(unhold): rtc session is invalid!');
    session.unhold();
  }

  void mute([bool audio = true, bool video = true]) {
    assert(session != null, 'ERROR(mute): rtc session is invalid!');
    session.mute(audio, video);
  }

  void unmute([bool audio = true, bool video = true]) {
    assert(session != null, 'ERROR(umute): rtc session is invalid!');
    session.unmute(audio, video);
  }

  void sendDTMF(String tones) {
    assert(session != null, 'ERROR(sendDTMF): rtc session is invalid!');
    session.sendDTMF(tones);
  }

  String get remote_display_name {
    assert(session != null,
        'ERROR(get remote_identity): rtc session is invalid!');
    if (session.remote_identity != null &&
        session.remote_identity.display_name != null) {
      return session.remote_identity.display_name;
    }
    return '';
  }

  String get remote_identity {
    assert(session != null,
        'ERROR(get remote_identity): rtc session is invalid!');
    if (session.remote_identity != null &&
        session.remote_identity.uri != null &&
        session.remote_identity.uri.user != null) {
      return session.remote_identity.uri.user;
    }
    return '';
  }

  String get local_identity {
    assert(
        session != null, 'ERROR(get local_identity): rtc session is invalid!');
    if (session.local_identity != null &&
        session.local_identity.uri != null &&
        session.local_identity.uri.user != null) {
      return session.local_identity.uri.user;
    }
    return '';
  }

  String get direction {
    assert(session != null, 'ERROR(get direction): rtc session is invalid!');
    if (session.direction != null) {
      return session.direction.toUpperCase();
    }
    return '';
  }
}

class CallState {

  CallStateEnum state;
  ErrorCause cause;
  String originator;
  bool audio;
  bool video;
  MediaStream stream;
  EventCallRefer refer;
  CallState(this.state,
      {this.originator,
      this.audio,
      this.video,
      this.stream,
      this.cause,
      this.refer});
}

enum RegistrationStateEnum {
  NONE,
  REGISTRATION_FAILED,
  REGISTERED,
  UNREGISTERED,
}

class RegistrationState {
  RegistrationStateEnum state;
  ErrorCause cause;
  RegistrationState({this.state, this.cause});
}

enum TransportStateEnum {
  NONE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
}

class TransportState {
  TransportStateEnum state;
  ErrorCause cause;
  TransportState(this.state, {this.cause});
}

class SIPMessageRequest {
  dynamic request;
  String originator;
  Message message;
  SIPMessageRequest(this.message, this.originator, this.request);
}

abstract class SipUaHelperListener {
  void transportStateChanged(TransportState state);
  void registrationStateChanged(RegistrationState state);
  void callStateChanged(Call call, CallState state);
  //For SIP new messaga coming
  void onNewMessage(SIPMessageRequest msg);
}

class WebSocketSettings {
  /// Add additional HTTP headers, such as:'Origin','Host' or others
  Map<String, dynamic> extraHeaders = {};


  /// `User Agent` field for dart http client.
  String userAgent;

  /// Don‘t check the server certificate
  /// for self-signed certificate.
  bool allowBadCertificate = false;
}

class UaSettings {
  String webSocketUrl;
  WebSocketSettings webSocketSettings = WebSocketSettings();

  /// `User Agent` field for sip message.
  String userAgent;
  String uri;
  String authorizationUser;
  String password;
  String ha1;
  String displayName;

  List<Map<String, String>> iceServers = [
    {'url': 'stun:stun.l.google.com:19302'},
// turn server configuration example.
//    {
//      'url': 'turn:123.45.67.89:3478',
//      'username': 'change_to_real_user',
//      'credential': 'change_to_real_secret'
//    },
  ];
}
