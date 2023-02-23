import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'db.dart';
import 'msg.dart';
import 'params.dart';

class ServiceNotifListener {
  Future<bool> get isActive async => (await NotificationsListener.isRunning)!;

  Future startListening() async {
    print("start listening");
    PermissionStatus rep =
        await NotificationPermissions.getNotificationPermissionStatus();
    if (rep != PermissionStatus.granted) {
      await NotificationPermissions.requestNotificationPermissions();
      return;
    }
    bool hasPermission = (await NotificationsListener.hasPermission)!;
    if (!hasPermission) {
      print("no notification read access permission, so open settings");
      await NotificationsListener.openPermissionSettings();
      return;
    }

    if (!await isActive) {
      await NotificationsListener.startService();
    }

    await NotificationsListener.promoteToForeground(
      "Shrink That Conversation",
    );

    await Future.delayed(const Duration(seconds: 3));
  }

  Future stopListening() async {
    print("stop listening");

    await NotificationsListener.stopService();
    await Future.delayed(const Duration(seconds: 3));
  }

  @pragma('vm:entry-point')
  static void callback(NotificationEvent evt) async {
    // persist data immediately
    DBHelper db = DBHelper.instance;

    String convName = await db.getParam(Param.conversationName);

    if (evt.packageName == "com.facebook.orca") {
      if (evt.title!.contains(convName)) {
        Msg msg = Msg.fromRawNotif(evt.title, evt.text, evt.timestamp! * 1000);
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
