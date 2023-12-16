import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionOverviewPage extends StatefulWidget {
  const TransactionOverviewPage(this.tx, this.group, {super.key});

  static Route route(Transaction tx, Group group) {
    return MaterialPageRoute(
      builder: (context) => TransactionOverviewPage(tx, group),
    );
  }

  final Transaction tx;
  final Group group;

  @override
  State<TransactionOverviewPage> createState() =>
      _TransactionOverviewPageState();
}

class _TransactionOverviewPageState extends State<TransactionOverviewPage> {
  late final TextEditingController controller;
  final _txsDao = getIt.get<TransactionsDao>();
  final _groupsDao = getIt.get<GroupsDao>();

  @override
  void initState() {
    controller = TextEditingController()..text = widget.tx.amount.toString();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Transaction Details"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mode: ${widget.tx.mode.name}'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
                    ],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      suffixText: "\$",
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final prevAmount = widget.tx.amount;
                    final amount = int.parse(controller.text);
                    if (prevAmount == amount) return;
                    final diff = widget.tx.mode == TxMode.income
                        ? amount - prevAmount
                        : prevAmount - amount;

                    final balance = widget.group.balance;

                    _groupsDao.adjustBalance(balance + (diff), widget.group.id);
                    _txsDao.updateAmount(widget.tx.id, amount);
                    controller.clear();
                  },
                  child: const Text("Update amount"),
                ),
              ],
            ),
          ],
        ),
      );
}
