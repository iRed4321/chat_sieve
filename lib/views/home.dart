import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app.dart';
import '../models/summary.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      return Scaffold(
          body: Center(
              child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FutureBuilder<List<Summary>>(
              future: model.getSummaries(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount:
                          snapshot.data!.length + (model.loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0 && model.loading) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        int currIndex = model.loading ? index - 1 : index;
                        return Dismissible(
                          key: UniqueKey(),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child:
                                  Text(snapshot.data![currIndex].text.trim()),
                            ),
                          ),
                          onDismissed: (direction) async {
                            await model
                                .deleteSummary(snapshot.data![currIndex].id);
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
                onPressed: () async {
                  await model.callAi(context.loc);
                },
                label: Text(context.loc.runSummerization)),
          ],
        ),
      )));
    });
  }
}
