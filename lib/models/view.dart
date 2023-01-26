import 'package:flutter/material.dart';
import '../views/home.dart';
import '../views/messages.dart';
import '../views/pseudos.dart';
import '../views/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum View { participants, home, messages, settings }

extension ViewHelper on View {
  String getName(AppLocalizations loc) {
    switch (this) {
      case View.home:
        return loc.home;
      case View.participants:
        return loc.pseudo;
      case View.settings:
        return loc.settings;
      case View.messages:
        return loc.lastMsgs;
    }
  }

  Widget get icon {
    switch (this) {
      case View.home:
        return const Icon(Icons.home);
      case View.participants:
        return const Icon(Icons.people);
      case View.settings:
        return const Icon(Icons.settings);
      case View.messages:
        return const Icon(Icons.message);
    }
  }

  StatelessWidget getPage() {
    switch (this) {
      case View.home:
        return const HomePage();
      case View.participants:
        return const ListParticipantsPage();
      case View.settings:
        return const SettingsPage();
      case View.messages:
        return const LastMsgsPage();
    }
  }

  static List<NavigationDestination> getDestinations(AppLocalizations loc) {
    return List<NavigationDestination>.generate(View.values.length, (index) {
      return NavigationDestination(
          icon: View.values[index].icon,
          label: View.values[index].getName(loc));
    });
  }
}
