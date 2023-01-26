import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'msg.dart';
import 'people.dart';
import 'summary.dart';

const String tableNames = 'Names';
const String namesId = 'id';
const String namesPseudo = 'Pseudo';
const String namesName = 'Name';

const String tableMsgs = 'Msgs';
const String msgsTimeId = 'timeId';
const String msgsSender = 'Sender';
const String msgsMsg = 'Msg';

const String paramsTable = 'Params';
const String paramsId = 'id';
const String paramsName = 'name';
const String paramsValue = 'value';

const String resumTable = "summaries";
const String resumTimeId = 'timeId';
const String resumOutput = 'output';

class DBHelper {
  DBHelper._privateConstructor();

  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _db;

  Future<Database> get db async => _db ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory docs = await getApplicationDocumentsDirectory();
    String path = join(docs.path, 'msgs2ai.db');
    return openDatabase(path, version: 1, onCreate: _open);
  }

  Future<int?> addParticipant(Participant p) async {
    Database? db = await instance.db;
    int? id = await db.insert(tableNames, p.toMap());
    return id;
  }

  Future<List<Participant>> getParticipants() async {
    Database db = await instance.db;
    List<Map> rep = await db.query(tableNames);
    List<Participant> list = [];
    for (Map map in rep) {
      list.add(
          Participant.onId(map[namesName], map[namesPseudo], map[namesId]));
    }
    return list;
  }

  Future<int> deleteParticipant(int id) async {
    Database db = await instance.db;
    return await db.delete(tableNames, where: '$namesId = ?', whereArgs: [id]);
  }

  Future<int> updateParticipant(Participant p) async {
    Database db = await instance.db;
    return await db.update(tableNames, p.toMap(),
        where: '$namesId = ?', whereArgs: [p.id]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.db;
    return await db.delete(tableNames);
  }

  Future _open(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNames (
        $namesId INTEGER PRIMARY KEY,
        $namesPseudo TEXT,
        $namesName INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableMsgs (
        $msgsTimeId INTEGER PRIMARY KEY,
        $msgsSender TEXT,
        $msgsMsg TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $paramsTable (
        $paramsId INTEGER PRIMARY KEY,
        $paramsName TEXT,
        $paramsValue TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $resumTable (
        $resumTimeId INTEGER PRIMARY KEY,
        $resumOutput TEXT
      )
    ''');

    await db.insert(paramsTable, {
      paramsName: 'openAiKey',
      paramsValue: '',
    });

    await db.insert(paramsTable, {
      paramsName: 'conversationName',
      paramsValue: '',
    });
  }

  // Msgs

  Future addMsg(Msg msg) async {
    Database db = await instance.db;
    await db.insert(tableMsgs, msg.toMap());
  }

  Future<List<Msg>> getMsgs() async {
    Database db = await instance.db;
    List<Map> rep = await db.query(tableMsgs);
    List<Msg> list = [];
    for (Map map in rep) {
      list.add(Msg(map[msgsSender], map[msgsMsg], map[msgsTimeId]));
    }
    return list;
  }

  Future<int> deleteAllMsgs() async {
    Database db = await instance.db;
    return await db.delete(tableMsgs);
  }

  // Params

  //set openAiKey
  Future setOpenAiKey(String key) async {
    Database db = await instance.db;
    return await db.update(paramsTable, {paramsValue: key},
        where: '$paramsName = ?', whereArgs: ['openAiKey']);
  }

  //get openAiKey
  Future<String> getOpenAiKey() async {
    Database db = await instance.db;
    List<Map> rep = await db
        .query(paramsTable, where: '$paramsName = ?', whereArgs: ['openAiKey']);
    return rep[0][paramsValue];
  }

  //set conversationName
  Future setConversationName(String name) async {
    Database db = await instance.db;
    return await db.update(paramsTable, {paramsValue: name},
        where: '$paramsName = ?', whereArgs: ['conversationName']);
  }

  //get conversationName
  Future<String> getConversationName() async {
    Database db = await instance.db;
    List<Map> rep = await db.query(paramsTable,
        where: '$paramsName = ?', whereArgs: ['conversationName']);
    return rep[0][paramsValue];
  }

  // Resume
  Future addSummary(Summary sumar) async {
    Database db = await instance.db;
    await db.insert(resumTable, sumar.toMap());
  }

  Future deleteSummary(int dateId) async {
    Database db = await instance.db;
    await db.delete(resumTable, where: '$resumTimeId = ?', whereArgs: [dateId]);
  }

  Future<List<Summary>> getSummaries() async {
    Database db = await instance.db;
    List<Map> rep = await db.query(resumTable);
    List<Summary> list = [];
    for (Map map in rep) {
      list.add(Summary.fromDb(map[resumTimeId], map[resumOutput]));
    }
    return list;
  }

  Future close() async => _db?.close();
}
