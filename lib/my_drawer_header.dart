import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  final dbHelper = AppDatabaseHelper();

  double totalCredit = 0.0;
  double totalDebit = 0.0;
  double totalBalance = 0.0;
  String username = "Guest"; // Default username

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
    _loadUsername(); // Load username from SharedPreferences
  }

  Future<void> _fetchSummaryData() async {
    final totals = await dbHelper.getTotalCreditDebitBalance();
    setState(() {
      totalCredit = totals['totalCredit'] ?? 0.0;
      totalDebit = totals['totalDebit'] ?? 0.0;
      totalBalance = totals['totalBalance'] ?? 0.0;
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Guest"; // Load username or fallback to "Guest"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade600,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Profile Image
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/image/GN.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dynamic Username
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1.0, indent: 30, endIndent: 30),
          const SizedBox(height: 10),
          // Credit, Debit, and Balance Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryRow('Credit(+)', totalCredit, Colors.white),
                _buildSummaryRow('Debit(-)', totalDebit, Colors.white),
                const Divider(color: Colors.white70),
                _buildSummaryRow('Balance', totalBalance, Colors.white, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build rows for Credit, Debit, Balance
  Widget _buildSummaryRow(String label, double value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹ ${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: bold ? Colors.white : color,
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
