import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:awaitable_button/awaitable_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:shrink_that_conv/models/params.dart';
import '../models/app.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (context, model, child) => FutureBuilder<Map<Param, dynamic>>(
            future: model.getSettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                  body: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: ListView(children: [
                      Card(
                          child: FutureBuilder<bool>(
                        future: model.service.isActive,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListTile(
                              title: Text(context.loc.service),
                              subtitle: Text(snapshot.data!
                                  ? context.loc.serviceActive
                                  : context.loc.serviceUnactive),
                              trailing: SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: AnimatedToggleSwitch.rolling(
                                        height: 30,
                                        indicatorSize: const Size.fromWidth(25),
                                        innerColor: snapshot.data!
                                            ? Colors.green[900]
                                            : Colors.red[900],
                                        current: snapshot.data!,
                                        values: const [false, true],
                                        onChanged: ((value) async {
                                          if (snapshot.data!) {
                                            await model.stopListening();
                                          } else {
                                            await model.startListening();
                                          }
                                        })),
                                  )),
                            );
                          } else {
                            return ListTile(
                              title: Text(context.loc.service),
                              subtitle: Text(context.loc.waitingIsActive),
                            );
                          }
                        },
                      )),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          children: <Widget>[
                            Text(context.loc.convName),
                            const SizedBox(height: 30),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              initialValue:
                                  snapshot.data![Param.conversationName] != ""
                                      ? snapshot.data![Param.conversationName]
                                      : context.loc.convNameDefault,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  border: OutlineInputBorder(),
                                  isDense: true),
                              onChanged: (String value) async {
                                Param.conversationName.set = value;
                                model.makeUpdateUi();
                              },
                            )
                          ],
                        ),
                      )),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          children: <Widget>[
                            Text(context.loc.outputLength),
                            const SizedBox(height: 30),
                            Slider(
                                value: int.parse(snapshot
                                        .data![Param.outputLength]
                                        .toString())
                                    .toDouble(),
                                divisions: 4,
                                label: 'x${snapshot.data![Param.outputLength]}',
                                min: 0,
                                max: 4,
                                onChanged: (value) async {
                                  Param.outputLength.set =
                                      value.round().toString();
                                  model.makeUpdateUi();
                                })
                          ],
                        ),
                      )),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          children: <Widget>[
                            Text(context.loc.apiKey),
                            const SizedBox(height: 30),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              initialValue:
                                  snapshot.data![Param.openAiKey] != ""
                                      ? snapshot.data![Param.openAiKey]
                                      : "sk-",
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  border: OutlineInputBorder(),
                                  isDense: true),
                              onChanged: (String value) {
                                Param.openAiKey.set = value;
                                model.makeUpdateUi();
                              },
                            )
                          ],
                        ),
                      )),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 40, 16),
                              child: Text(context.loc.deleteAll),
                            ),
                            AwaitableElevatedButton(
                                onPressed: () async {
                                  await model.deleteAllMsgs();
                                },
                                buttonStyle: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red[900]!),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete),
                                      Text(context.loc.deleteBtn)
                                    ]))
                          ],
                        ),
                      )),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 40, 16),
                              child: Text(context.loc.deleteAllSummaries),
                            ),
                            AwaitableElevatedButton(
                                onPressed: () async {
                                  await model.deleteAllSummaries();
                                },
                                buttonStyle: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red[900]!),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete),
                                      Text(context.loc.deleteBtn)
                                    ]))
                          ],
                        ),
                      )),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: Text(context.loc.advancedSettings),
                        children: [
                          Card(
                              child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              children: <Widget>[
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 40, 16),
                                    child: Text(context.loc.loadJson)),
                                AwaitableElevatedButton(
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['json'],
                                      );
                                      if (result != null) {
                                        model
                                            .loadJson(result.files.single.path!)
                                            .then((res) => ScaffoldMessenger.of(
                                                    context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(context.loc
                                                        .importSuccess(res)))));
                                      }
                                    },
                                    buttonStyle: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green[900]!),
                                        foregroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.add),
                                          Text(context.loc.addBtn)
                                        ]))
                              ],
                            ),
                          )),
                          const SizedBox(height: 10),
                          Card(
                              child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              children: <Widget>[
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 40, 16),
                                    child: Text(context.loc.exportJson)),
                                AwaitableElevatedButton(
                                    onPressed: () async {
                                      model.exportJson();
                                    },
                                    buttonStyle: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green[900]!),
                                        foregroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.output),
                                          Text(context.loc.exportBtn)
                                        ]))
                              ],
                            ),
                          )),
                          const SizedBox(height: 10)
                        ],
                      ),
                    ]),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
