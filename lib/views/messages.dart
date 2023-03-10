import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app.dart';

class LastMsgsPage extends StatelessWidget {
  const LastMsgsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      return FutureBuilder(
        future: model.getMsgs(true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(snapshot.data!.join("").trim())));
          }
          return const CircularProgressIndicator();
        },
      );
    });
  }
}
