import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<Database>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future insert(
    String groupId,
    int amount,
    TxMode mode,
  ) {
    return into(transactions).insert(
      TransactionsCompanion.insert(
        id: const Uuid().v1(),
        createdAt: DateTime.now().toUtc(),
        mode: mode,
        groupId: groupId,
        amount: Value(amount),
      ),
    );
  }

  Future updateAmount(String txId, int amount) =>
      (update(transactions)..where((tbl) => tbl.id.equals(txId)))
          .write(TransactionsCompanion(amount: Value(amount)));

  Stream<List<Transaction>> watchTxs(String groupId) =>
      (select(transactions)..where((tbl) => tbl.groupId.equals(groupId)))
          .watch();

  Stream<Transaction?> watchTx(String transactionId) {
    return (select(transactions)..where((tbl) => tbl.id.equals(transactionId)))
        .watchSingleOrNull();
  }
}
