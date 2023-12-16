import 'package:drift/drift.dart';

enum TxMode { expense, income }

class Transactions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get amount => integer().withDefault(const Constant(0))();
  TextColumn get mode => textEnum<TxMode>()();
  TextColumn get groupId => text()
      .customConstraint('NOT NULL REFERENCES groups(id) ON DELETE CASCADE')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
