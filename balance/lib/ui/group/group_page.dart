import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/group/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final _groupsDao = getIt.get<GroupsDao>();
  final _txsDao = getIt.get<TransactionsDao>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Group details"),
        ),
        body: StreamBuilder(
          stream: _groupsDao.watchGroup(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text("Loading...");

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(snapshot.data?.name ?? ""),
                Text(snapshot.data?.balance.toString() ?? ""),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _incomeController,
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
                        final amount = int.parse(_incomeController.text);
                        final balance = snapshot.data?.balance ?? 0;
                        _groupsDao.adjustBalance(
                            balance + amount, widget.groupId);
                        _txsDao.insert(widget.groupId, amount, TxMode.income);

                        _incomeController.clear();
                      },
                      child: const Text("Add income")),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expenseController,
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
                        final amount = int.parse(_expenseController.text);
                        final balance = snapshot.data?.balance ?? 0;
                        _groupsDao.adjustBalance(
                            balance - amount, widget.groupId);
                        _txsDao.insert(widget.groupId, amount, TxMode.expense);
                        _expenseController.clear();
                      },
                      child: const Text("Add expense")),
                ]),
                const SizedBox(height: 50),
                TransactionsView(
                  snapshot.data!,
                  snapshot.data?.balance ?? 0,
                ),
              ],
            );
          },
        ),
      );
}
