import 'db.dart';

class Summary {
  String text;
  late int id;
  Summary(this.text) {
    id = DateTime.now().microsecondsSinceEpoch;
  }

  Summary.fromDb(this.id, this.text);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{resumTimeId: id, resumOutput: text};
  }

  @override
  String toString() {
    return 'Summary{id: $id, text: $text}';
  }
}
