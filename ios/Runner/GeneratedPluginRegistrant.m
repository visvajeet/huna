//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<adhara_socket_io/AdharaSocketIoPlugin.h>)
#import <adhara_socket_io/AdharaSocketIoPlugin.h>
#else
@import adhara_socket_io;
#endif

#if __has_include(<audioplayers/AudioplayersPlugin.h>)
#import <audioplayers/AudioplayersPlugin.h>
#else
@import audioplayers;
#endif

#if __has_include(<custom_switch_button/CustomSwitchButtonPlugin.h>)
#import <custom_switch_button/CustomSwitchButtonPlugin.h>
#else
@import custom_switch_button;
#endif

#if __has_include(<emoji_picker/EmojiPickerPlugin.h>)
#import <emoji_picker/EmojiPickerPlugin.h>
#else
@import emoji_picker;
#endif

#if __has_include(<file_picker/FilePickerPlugin.h>)
#import <file_picker/FilePickerPlugin.h>
#else
@import file_picker;
#endif

#if __has_include(<flutter_custom_dialog/FlutterCustomDialogPlugin.h>)
#import <flutter_custom_dialog/FlutterCustomDialogPlugin.h>
#else
@import flutter_custom_dialog;
#endif

#if __has_include(<flutter_inappwebview/InAppWebViewFlutterPlugin.h>)
#import <flutter_inappwebview/InAppWebViewFlutterPlugin.h>
#else
@import flutter_inappwebview;
#endif

#if __has_include(<flutter_webrtc/FlutterWebRTCPlugin.h>)
#import <flutter_webrtc/FlutterWebRTCPlugin.h>
#else
@import flutter_webrtc;
#endif

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<path_provider/FLTPathProviderPlugin.h>)
#import <path_provider/FLTPathProviderPlugin.h>
#else
@import path_provider;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<phone_state_i/PhoneState_iPlugin.h>)
#import <phone_state_i/PhoneState_iPlugin.h>
#else
@import phone_state_i;
#endif

#if __has_include(<screen_keep_on/ScreenKeepOnPlugin.h>)
#import <screen_keep_on/ScreenKeepOnPlugin.h>
#else
@import screen_keep_on;
#endif

#if __has_include(<shared_preferences/FLTSharedPreferencesPlugin.h>)
#import <shared_preferences/FLTSharedPreferencesPlugin.h>
#else
@import shared_preferences;
#endif

#if __has_include(<sqflite/SqflitePlugin.h>)
#import <sqflite/SqflitePlugin.h>
#else
@import sqflite;
#endif

#if __has_include(<wc_flutter_share/WcFlutterSharePlugin.h>)
#import <wc_flutter_share/WcFlutterSharePlugin.h>
#else
@import wc_flutter_share;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AdharaSocketIoPlugin registerWithRegistrar:[registry registrarForPlugin:@"AdharaSocketIoPlugin"]];
  [AudioplayersPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioplayersPlugin"]];
  [CustomSwitchButtonPlugin registerWithRegistrar:[registry registrarForPlugin:@"CustomSwitchButtonPlugin"]];
  [EmojiPickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"EmojiPickerPlugin"]];
  [FilePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FilePickerPlugin"]];
  [FlutterCustomDialogPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterCustomDialogPlugin"]];
  [InAppWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"InAppWebViewFlutterPlugin"]];
  [FlutterWebRTCPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterWebRTCPlugin"]];
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [PhoneState_iPlugin registerWithRegistrar:[registry registrarForPlugin:@"PhoneState_iPlugin"]];
  [ScreenKeepOnPlugin registerWithRegistrar:[registry registrarForPlugin:@"ScreenKeepOnPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
  [WcFlutterSharePlugin registerWithRegistrar:[registry registrarForPlugin:@"WcFlutterSharePlugin"]];
}

@end
