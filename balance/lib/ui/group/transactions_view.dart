import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/transaction_overview/transaction_overview_page.dart';
import 'package:flutter/material.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView(this.group, this.balance, {super.key});

  final Group group;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final txsDao = getIt.get<TransactionsDao>();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transactions History'),
          Expanded(
            child: StreamBuilder(
                stream: txsDao.watchTxs(group.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("Loading...");

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Text("Empty transactions ...");
                  }

                  final txs = snapshot.data!
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: txs.length,
                    itemBuilder: (context, index) {
                      final tx = txs[index];
                      final amount = tx.amount;
                      final rb = calculateRb(index: index, tx: tx, txs: txs);

                      final style = TextStyle(
                        color:
                            tx.mode == TxMode.income ? Colors.blue : Colors.red,
                      );

                      return ListTile(
                        title: Text('$amount', style: style),
                        onTap: () {
                          Navigator.push(
                            context,
                            TransactionOverviewPage.route(tx, group),
                          );
                        },
                        subtitle: Text('Running balance: $rb'),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  int calculateRb({
    required int index,
    required Transaction tx,
    required List<Transaction> txs,
  }) {
    var rb = 0;

    for (var x = txs.length - 1; x >= index; x--) {
      if (txs[x].mode == TxMode.income) {
        rb += txs[x].amount;
      } else {
        rb -= txs[x].amount;
      }
    }
    return rb;
  }
}
