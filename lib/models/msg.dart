import 'db.dart';
import 'people.dart';

class Msg {
  late int postTime;
  late String sender;
  late String text;
  Msg(this.sender, this.text, this.postTime);

  String getSenderName(List<Participant> participants) {
    for (var item in participants) {
      if (sender.toLowerCase().contains(item.name.toLowerCase())) {
        return item.pseudo;
      }
    }
    return sender;
  }

  static String formatMsg(String msg) {
    if (msg.toLowerCase().contains("a envoyé")) {
      if (msg.toLowerCase().contains("gif")) {
        return "[gif]";
      } else if (msg.toLowerCase().contains("photo")) {
        return "[photo]";
      } else if (msg.toLowerCase().contains("vidéo")) {
        return "[vidéo]";
      }
    }
    if (msg.contains("http")) {
      return "[link]";
    }
    msg.replaceAll("\n\n", "\n");
    return msg;
  }

  Msg.fromRawNotif(dynamic sender, dynamic text, dynamic time) {
    this.sender = sender.toString().split(': ').last;
    this.text = formatMsg(text.toString());
    postTime = time;
  }

  @override
  String toString() {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(postTime);
    String time = "${date.hour}:${date.minute}";
    return "[$time] $sender: $text\n";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Msg && other.postTime == postTime;
  }

  Map<String, dynamic> toMap() {
    var y = <String, dynamic>{
      msgsTimeId: postTime,
      msgsSender: sender,
      msgsMsg: text
    };
    return y;
  }

  Map<String, dynamic> toJson() {
    var y = <String, dynamic>{
      msgsTimeId: postTime,
      msgsSender: sender,
      msgsMsg: text
    };
    return y;
  }

  Msg.fromJson(Map<String, dynamic> json) {
    postTime = json[msgsTimeId];
    sender = json[msgsSender];
    text = json[msgsMsg];
  }

  @override
  int get hashCode => postTime.hashCode;
}
