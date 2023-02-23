import 'package:awaitable_button/awaitable_button.dart';
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
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        int currIndex = index;
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
                            snapshot.data!.removeAt(currIndex);
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
            AwaitableElevatedButton<void>(
              onPressed: () async {
                await model.callAi(context.loc);
              },
              indicatorSize: const Size(20, 20),
              buttonStyle: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer),
              child: Text(context.loc.runSummerization),
            )
          ],
        ),
      )));
    });
  }
}
