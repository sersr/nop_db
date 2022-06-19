import 'dart:async';

import 'package:meta/meta.dart';
import 'package:nop/nop.dart';
import 'nop_db.dart';
import 'table.dart';
import 'watcher.dart';

abstract class $Database {
  List<DatabaseTable> get tables;

  List<String> getTables() {
    return tables.map((e) => e.createTable()).toList();
  }

  @mustCallSuper
  Future<void> onCreate(NopDatabase db, int version) async {
    final tables = getTables();
    for (var table in tables) {
      await db.execute(table);
    }
  }

  void onUpgrade(NopDatabase db, int oldVersion, int newVersion) {}
  void onDowngrade(NopDatabase db, int oldVersion, int newVersion) {}

  NopDatabase? _db;
  Watcher? _watcher;

  void setDb(NopDatabase db) {
    assert(_db == null);
    _db = db;
  }

  NopDatabase get db => _db!;
  Watcher get watcher => _watcher ??= Watcher();
  FutureOr<void> transaction(FutureOr<void> Function() run) {
    execute('BEGIN')
        .whenComplete(() => run().whenComplete(() => execute('COMMIT')));
  }

  FutureOr<void> execute(String sql, [List<Object?> parameters = const []]) =>
      db.execute(sql, parameters);

  FutureOr<List<Map<String, Object?>>> query(String sql,
          [List<Object?> parameters = const []]) =>
      db.rawQuery(sql, parameters);

  FutureOr<int> update(String sql, [List<Object?> parameters = const []]) =>
      db.rawUpdate(sql, parameters);

  FutureOr<int> delete(String sql, [List<Object?> parameters = const []]) =>
      db.rawDelete(sql, parameters);

  FutureOr<int> insert(String sql, [List<Object?> parameters = const []]) =>
      db.rawInsert(sql, parameters);
  NopPrepare prepare(String sql,
      {bool persistent = false, bool vtab = true, bool checkNoTail = false}) {
    return db.prepare(sql,
        persistent: persistent, vtab: vtab, checkNoTail: checkNoTail);
  }

  FutureOr<void> dispose() => _db?.disposeNop();
}
