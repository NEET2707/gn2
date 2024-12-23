// searchresultpage.dart
import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final double totalCredit;
  final double totalDebit;
  final double balance;
  final List<Map<String, dynamic>> transactions;

  const SearchResultPage({
    super.key,
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Credit: \$${totalCredit.toStringAsFixed(2)}'),
            Text('Total Debit: \$${totalDebit.toStringAsFixed(2)}'),
            Text('Balance: \$${balance.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  var tx = transactions[index];
                  return ListTile(
                    title: Text(tx['particular']),
                    subtitle: Text(tx['date']),
                    trailing: Text(
                      '${tx['type'] == 'credit' ? '+' : '-'} \$${tx['amount']}',
                      style: TextStyle(
                        color: tx['type'] == 'credit' ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
