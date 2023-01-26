import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app.dart';
import '../models/people.dart';

AlertDialog makeAlertDialog(
    Participant? ptcp, bool isModif, BuildContext ctx, AppModel model) {
  String nouvname = isModif ? ptcp!.name : "";
  String nouvpseudo = isModif ? ptcp!.pseudo : "";
  return AlertDialog(
    title: Text(isModif ? ctx.loc.peopleChange : ctx.loc.peopleAdd,
        textAlign: TextAlign.center),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(
        initialValue: nouvname,
        decoration: InputDecoration(
            border: const UnderlineInputBorder(), labelText: ctx.loc.realName),
        onChanged: (String value) {
          nouvname = value;
        },
      ),
      TextFormField(
        initialValue: nouvpseudo,
        decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: ctx.loc.pseudoName),
        onChanged: (String value) {
          nouvpseudo = value;
        },
      ),
    ]),
    actions: [
      TextButton(
        child: Text(ctx.loc.cancel),
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
      ElevatedButton(
          onPressed: () {
            if (isModif) {
              model.updateParticipant(ptcp!.id, nouvname, nouvpseudo);
            } else {
              model.addParticipant(nouvname, nouvpseudo);
            }
            Navigator.pop(ctx);
          },
          child: Text(ctx.loc.add)),
    ],
  );
}

class ListParticipantsPage extends StatelessWidget {
  const ListParticipantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, model, child) => Scaffold(
          body: Center(
            child: FutureBuilder<List<Participant>>(
                future: model.getParticipants(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      padding: const EdgeInsets.only(bottom: 70),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              "${snapshot.data![index].name} ➔ ${snapshot.data![index].pseudo}",
                              overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return makeAlertDialog(
                                              snapshot.data![index],
                                              true,
                                              context,
                                              model);
                                        });
                                  }),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  model.deleteParticipant(
                                      snapshot.data![index].id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return makeAlertDialog(null, false, context, model);
                    });
              },
              label: Text(context.loc.peopleAdd),
              icon: const Icon(Icons.add))),
    );
  }
}
