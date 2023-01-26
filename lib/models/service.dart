import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'db.dart';
import 'msg.dart';
import 'people.dart';

class ServiceNotifListener {
  Future<bool> get isActive async => (await NotificationsListener.isRunning)!;

  Future startListening() async {
    print("start listening");
    bool hasPermission = (await NotificationsListener.hasPermission)!;
    if (!hasPermission) {
      print("no permission, so open settings");
      NotificationsListener.openPermissionSettings();
      return;
    }

    if (!await isActive) {
      await NotificationsListener.startService(
          foreground: true,
          title: "Réception des notifications active",
          description: "Les notifications recues seront enregistrées");
    }

    await Future.delayed(const Duration(seconds: 4));
  }

  Future stopListening() async {
    print("stop listening");

    await NotificationsListener.stopService();
    await Future.delayed(const Duration(seconds: 4));
    // isActive = false;
  }

  @pragma('vm:entry-point')
  static void callback(NotificationEvent evt) async {
    // persist data immediately
    DBHelper db = DBHelper.instance;

    List<Participant> participants = await db.getParticipants();
    String convName = await db.getConversationName();

    // print("onData: $event");
    if (evt.packageName == "com.facebook.orca") {
      if (evt.title!.contains(convName)) {
        Msg msg = Msg.fromRawNotif(
            participants, evt.title, evt.text, evt.timestamp! * 1000);
        db.addMsg(msg);
      }
    }
    // send data to ui thread if necessary.
    // try to send the event to ui
    print("send evt to ui: $evt");
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }
}
