import 'db.dart';

enum Param { openAiKey, outputLength, conversationName }

extension Truc on Param {
  static final DBHelper _db = DBHelper.instance;

  set set(dynamic value) {
    _db.setParam(this, value);
  }

  String getString() {
    switch (this) {
      case Param.openAiKey:
        return 'openAiKey';
      case Param.outputLength:
        return 'outputLength';
      case Param.conversationName:
        return 'conversationName';
    }
  }

  dynamic get get async {
    return _db.getParam(this);
  }
}
