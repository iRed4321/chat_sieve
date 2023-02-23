import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:notification_permissions/notification_permissions.dart'
//     as NotifsPerm;
import 'package:permission_handler/permission_handler.dart';
import 'package:pick_or_save/pick_or_save.dart';
import 'package:shrink_that_conv/models/params.dart';
import 'package:shrink_that_conv/models/people.dart';
import 'package:shrink_that_conv/models/service.dart';
import 'package:shrink_that_conv/models/view.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'db.dart';
import 'msg.dart';
import 'summary.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

class AppModel with ChangeNotifier {
  int counter = 0;
  ServiceNotifListener service = ServiceNotifListener();
  ReceivePort port = ReceivePort();
  View _view = View.home;

  late DBHelper _db;
  AppModel() {
    _db = DBHelper.instance;
  }

  Future startListening() async {
    await service.startListening();
    notifyListeners();
  }

  Future stopListening() async {
    await service.stopListening();
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    // register the static to handle the events
    NotificationsListener.initialize(
        callbackHandle: ServiceNotifListener.callback);

    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");

    port.listen((evt) => makeUpdateUi(evt));
  }

  View get view => _view;

  makeUpdateUi([NotificationEvent? event]) {
    notifyListeners();
  }

  set view(View v) {
    _view = v;
    notifyListeners();
  }

  set viewNum(int v) {
    _view = View.values[v];
    notifyListeners();
  }

  Future<List<Participant>> getParticipants() async {
    return await _db.getParticipants();
  }

  void deleteParticipant(int id) async {
    await _db.deleteParticipant(id);
    notifyListeners();
  }

  void addParticipant(String name, String pseudo) async {
    await _db.addParticipant(Participant.onNew(name, pseudo));
    notifyListeners();
  }

  void updateParticipant(int id, String name, String pseudo) async {
    await _db.updateParticipant(Participant.onId(name, pseudo, id));
    notifyListeners();
  }

  Future deleteAllMsgs() async {
    await _db.deleteAllMsgs();
    notifyListeners();
  }

  Future<int> loadJson(String path) async {
    final File file = File(path);
    String text = await file.readAsString();

    Iterable l = jsonDecode(text);
    List<Msg> msgs = l.map((model) => Msg.fromJson(model)).toList();

    deleteAllMsgs();
    for (var msg in msgs) {
      await _db.addMsg(msg);
    }

    return msgs.length;
  }

  Future<MsgList> getMsgs(bool onlyLasts) async {
    List<Msg> msgs = await _db.getMsgs();
    if (onlyLasts && msgs.length > 15) {
      msgs.removeRange(0, msgs.length - 15);
    }
    List<Participant> participants = await _db.getParticipants();
    for (var msg in msgs) {
      msg.sender = msg.getSenderName(participants);
    }
    return MsgList(msgs);
  }

  Future<List<Summary>> getSummaries() async {
    // await Future.delayed(const Duration(seconds: 1));
    return await _db.getSummaries().then((value) => value.reversed.toList());
  }

  Future<void> addSummary(Summary summary) async {
    await _db.addSummary(summary);
    notifyListeners();
  }

  Future<void> deleteSummary(int id) async {
    await _db.deleteSummary(id);
    notifyListeners();
  }

  Future<void> deleteAllSummaries() async {
    await _db.deleteAllSummaries();
    notifyListeners();
  }

  Future<Map<Param, dynamic>> getSettings() async {
    Map<Param, dynamic> settings = {};
    settings[Param.openAiKey] = await Param.openAiKey.get;
    settings[Param.conversationName] = await Param.conversationName.get;
    settings[Param.outputLength] = await Param.outputLength.get;
    return settings;
  }

  Future<void> callAi(AppLocalizations locale) async {
    notifyListeners();
    String result = (await getMsgs(false)).toString();
    int outputLength = int.parse(await Param.outputLength.get);
    int nbPoints = 1 + (result.characters.length / 400).floor() + outputLength;
    String prompt = result.replaceAll("'", " ").replaceAll("\"", " ");
    String key = await Param.openAiKey.get;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
    };

    String json = jsonEncode({
      "model": "text-davinci-003",
      "prompt": locale.aiIntro(prompt, nbPoints),
      "temperature": 0.78,
      "max_tokens":
          (result.toString().characters.length / (9 - outputLength)).floor()
    });

    var url = Uri.parse('https://api.openai.com/v1/completions');
    var res = await http.post(url, headers: headers, body: json);

    if (res.statusCode != 200) {
      addSummary(Summary(locale.errorHttp));
    } else {
      addSummary(Summary(jsonDecode(utf8.decode(res.bodyBytes))['choices'][0]
              ['text']
          .toString()));
    }

    notifyListeners();
  }

  Future<void> exportJson() async {
    var allMsgs = await _db.getMsgs();

    var json = jsonEncode(allMsgs);

    //save to external storage
    PermissionStatus permissionResult = await Permission.storage.request();
    if (permissionResult == PermissionStatus.granted) {
      await PickOrSave().fileSaver(
        params: FileSaverParams(
          saveFiles: [
            SaveFileInfo(
              fileName: "messages.json",
              fileData: Uint8List.fromList(utf8.encode(json)),
            )
          ],
        ),
      );
    }
  }
}
