import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:huna/utils/show.dart';

class SoundPlayer  {

  static AudioCache cache = AudioCache();
  static var incomingRingTone = "sounds/ringtone.mp3";
  static var chatSound = "sounds/chat_sound.wav";
  static var busyRingTone = "sounds/busy.mp3";
  static var outgoing = "sounds/outgoing.mp3";
  static var dtmfSounds =  "sounds/dtmf/dtmf-";
  static var notFound =  "sounds/notfound.mp3";

  static AudioPlayer player = AudioPlayer();


  static void playIncomingCallSound() async {
    player.earpieceOrSpeakersToggle(true);
    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.loop(incomingRingTone);
    }
  }

  static void earpieceOnOff(bool val) async {
    try {
      player.earpieceOrSpeakersToggle(val);
    } catch (e) {print(e);}
  }


  static void playChatSound() async {
    player.earpieceOrSpeakersToggle(true);
    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.play(chatSound);
    }
  }

  static void playOutgoingSound() async {
    player.earpieceOrSpeakersToggle(false);
    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.loop(outgoing);
    }
  }

  static void playNotFoundTone(bool speakerOn) async {

    if(speakerOn){
      player.earpieceOrSpeakersToggle(false);
    }else{
      player.earpieceOrSpeakersToggle(true);
    }
    Show.showToast("User Not Available", false);

    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.play(notFound);
    }


  }


  static void playBusySound() async {

    Show.showToast("User Busy", false);

    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.play(busyRingTone);
    }

  }


  static void playDTMFSound(String value) async {

    await stopSound();
    if(player.state != AudioPlayerState.PLAYING ) {
      player = await cache.play(dtmfSounds+value+".mp3");
    }
  }


  static Future<void> stopSound() async {
    print("HAAAAAAA");
   await player.pause();
   await player.stop();

  }


}

