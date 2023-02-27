import 'package:flutter/material.dart';

import 'db.dart';

class Participant {
  late int id;
  String name;
  String pseudo;

  Participant.onNew(this.name, this.pseudo) {
    id = UniqueKey().hashCode;
  }

  Participant.onId(this.name, this.pseudo, this.id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{namesPseudo: pseudo, namesName: name, namesId: id};
  }

  @override
  String toString() {
    return "$id: $name ($pseudo)";
  }
}
