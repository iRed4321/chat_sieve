import 'package:shrink_that_conv/models/db.dart';

class Summary {
  String text;
  late int id;
  Summary(this.text) {
    id = DateTime.now().millisecond;
  }

  Summary.fromDb(this.id, this.text);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{resumTimeId: id, resumOutput: text};
  }
}
