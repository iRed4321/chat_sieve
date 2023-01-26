import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
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
  // List<Participant>? participants;
  bool loading = false;
  // String? _openAiKey;
  // String? _convName;
  bool isReady = false;
  late DBHelper _db;

  AppModel() {
    _db = DBHelper.instance;
  }

  void onData(NotificationEvent event) {
    notifyListeners();
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

    port.listen((evt) => onData(evt));
  }

  View get view => _view;

  setOpenAiKey(String key) {
    _db.setOpenAiKey(key);
    notifyListeners();
  }

  setConvName(String name) {
    _db.setConversationName(name);
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

  Future<String> get openAiKey async => await _db.getOpenAiKey();
  Future<String> get convName async => await _db.getConversationName();

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

    var reqdata = await jsonDecode(text);
    var data = reqdata["posted"];

    List filteredList = [];

    for (var item in data) {
      if (item['packageName'] == "com.facebook.orca" &&
          item['title'].contains(convName)) {
        filteredList.add(item);
      }
    }

    List<Participant> participants = await getParticipants();
    deleteAllMsgs();
    for (var item in filteredList) {
      Msg msg = Msg.fromRawNotif(
          participants, item['title'], item['text'], item['postTime'] * 1000);
      await _db.addMsg(msg);
    }

    return filteredList.length;
  }

  Future<MsgList> getLastMsgs() async {
    List<Msg> msgs = await _db.getMsgs();
    if (msgs.length > 15) {
      msgs.removeRange(0, msgs.length - 15);
    }
    return MsgList(msgs);
  }

  Future<List<Summary>> getSummaries() async {
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

  Future<Map<String, String>> getSettings() async {
    Map<String, String> settings = {};
    settings['openAiKey'] = await openAiKey;
    settings['convName'] = await convName;
    return settings;
  }

  Future<void> callAi(AppLocalizations locale) async {
    loading = true;
    notifyListeners();
    MsgList result = MsgList(await _db.getMsgs());
    int nbPoints = (result.toString().characters.length / 400).floor() + 2;

    String prompt =
        result.toString().replaceAll("'", " ").replaceAll("\"", " ");

    String key = await openAiKey;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
    };

    String json = jsonEncode({
      "model": "text-davinci-003",
      "prompt": locale.aiIntro(prompt, nbPoints),
      "temperature": 0.78,
      "max_tokens": (result.toString().characters.length / 7).floor()
    });

    var url = Uri.parse('https://api.openai.com/v1/completions');
    var res = await http.post(url, headers: headers, body: json);

    loading = false;
    if (res.statusCode != 200) {
      addSummary(Summary(locale.errorHttp));
    } else {
      addSummary(Summary(jsonDecode(utf8.decode(res.bodyBytes))['choices'][0]
              ['text']
          .toString()));
    }

    notifyListeners();
  }
}
