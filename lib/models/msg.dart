import 'db.dart';
import 'people.dart';

class Msg {
  late int postTime;
  late String sender;
  late String text;
  Msg(this.sender, this.text, this.postTime);

  static String findSender(List<Participant> participants, String pseudo) {
    for (var item in participants) {
      if (pseudo.toLowerCase().contains(item.pseudo)) {
        return item.name;
      }
    }
    return pseudo;
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

  Msg.fromRawNotif(
      List<Participant> people, dynamic sender, dynamic text, dynamic time) {
    this.sender = findSender(people, sender.toString().split(': ').last);
    this.text = formatMsg(text.toString());
    postTime = time;
  }

  @override
  String toString() {
    return "[$postTime] $sender: $text\n";
  }

  String toPrettyString() {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(postTime);
    String time = "${date.hour}:${date.minute}";
    return "[$time] $sender: $text";
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

  @override
  int get hashCode => postTime.hashCode;
}

class MsgList {
  List<Msg> list;
  MsgList(this.list);

  @override
  String toString() {
    String s = "";
    for (Msg m in list) {
      s += m.toString();
    }
    return s;
  }

  String toPrettyString() {
    String s = "";
    for (Msg m in list) {
      s += m.toPrettyString();
    }
    return s.trim();
  }
}
