import 'package:flutter/material.dart';
import 'package:huna/utils/utils.dart';


import 'chat_model.dart';
import 'global.dart';

class SentMessageWidget extends StatelessWidget {
  final ChatMessages chat;
  const SentMessageWidget({
    Key key,
    this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(chat.createdOn, style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),),
          SizedBox(height: 8),
          getMsgUI(context),
          SizedBox(height: 4),
          getSeenStatusUi(chat.seenStatus)
        ],
      ),
    );
  }

   getMsgUI(context){

     return Container(
       constraints: BoxConstraints(
           maxWidth: MediaQuery.of(context).size.width * .8),
       padding: const EdgeInsets.all(15.0),
       decoration: BoxDecoration(
         color: myGreen,
         borderRadius: BorderRadius.only(
           topRight: Radius.circular(0),
           topLeft:  Radius.circular(20),
           bottomLeft: Radius.circular(20),
           bottomRight: Radius.circular(20),
         ),
       ),
       child: Text("${chat.message}",  style: TextStyle(fontSize: 15, color: Colors.white),
       ),
     );

  }

  getSeenStatusUi(String seenStatus) {
    print("SeenStatus");
    print(seenStatus);

    switch(seenStatus){
        case "0" :
        return Text("Sent",  style: TextStyle(fontSize: 15, color: Colors.black87));
        break;
        case "1" :
        return Text("Seen",  style: TextStyle(fontSize: 15, color: Colors.black87));
        break;
      default :
        return Text("null", style: TextStyle(fontSize: 15, color: Colors.black87));
    }
  }
}

 getIcon(String msgArray) {
  if(msgArray == "png"){
    return Icon(Icons.image);
  }
  else if(msgArray == "pdf"){
    return Icon(Icons.picture_as_pdf);
  }
  else if(msgArray == "jpg"){
    return Icon(Icons.image);

  }
  else if(msgArray == "wav"){
    return Icon(Icons.music_note);

  }
  else if(msgArray == "mp3"){
    return Icon(Icons.music_note);

  }
  else if(msgArray == "mp4"){
    return Icon(Icons.video_library);

  }else{
    return Icon(Icons.attach_file);
  }
}
/*//File msg
    if(chat.message.contains("~")){

      var msgArray = chat.msg.split('~');
      return Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(children: [
              getIcon(msgArray[1]),
              SizedBox(width: 1,),
             Text(
            "${msgArray[0]}",
                 style: Theme.of(context).textTheme.body2.apply(color: Colors.black87,)
             )]),
        ),

      );

    }else{

    }*/