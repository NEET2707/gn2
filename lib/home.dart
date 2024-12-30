import 'dart:io';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:gn_account_manager/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'clientlistpage.dart';
import 'clientscreen.dart';
import 'database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = AppDatabaseHelper();
  int _selectedIndex = 0;

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
      username = prefs.getString('username') ??
          "Guest"; // Load username or fallback to "Guest"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Home Screen",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () async {
              File? pixkfile = await AppDatabaseHelper().pickCsvFile();
              if (pixkfile != null)
                AppDatabaseHelper().importTransactionsFromCsv(pixkfile);
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.17,
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.5, left: 10),
                  child: Row(
                    children: [

                      Expanded(
                        child: PieChart(
                          dataMap: {
                            'Paid Amount': totalCredit,
                            'Due Amount': totalDebit,
                          },
                          animationDuration: Duration(milliseconds: 800),
                          chartLegendSpacing: 32,
                          chartRadius: MediaQuery.of(context).size.width / 5,
                          initialAngleInDegree: 90,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 30,
                          centerText: "100%",
                          centerTextStyle: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          legendOptions: LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: false,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(fontSize: 14),
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: true,
                            showChartValues: true,
                            showChartValueBackground: true,
                            decimalPlaces: 0,
                            chartValueStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500),
                          ),
                          colorList: [
                            Colors.green,
                            Colors.red,
                            Colors.blue,
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // Spacer(),
                      Table(
                        border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey),
                            verticalInside: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            top: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey)),
                        columnWidths: {
                          0: FixedColumnWidth(110.0),
                          1: FixedColumnWidth(100.0),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Text(
                                      "Credit",
                                      textScaleFactor: 1.5,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: FittedBox(
                                    child: Text(
                                      "₹" + totalCredit.toStringAsFixed(0),
                                      textScaleFactor: 1.5,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Text(
                                    "Debit",
                                    textScaleFactor: 1.5,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    child: Text(
                                      "₹" + totalDebit.toStringAsFixed(0),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Text(
                                    "Total",
                                    textScaleFactor: 1.5,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: FittedBox(
                                        child: Text(
                                          "₹" + totalBalance.toStringAsFixed(0),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Navigation Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //
      //       if (index == 0) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const HomeScreen()),
      //         );
      //       } else if (index == 1) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const Dashboard()),
      //         );
      //       } else if (index == 2) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) =>  SettingsPage()),
      //         );
      //       }
      //     });
      //   },
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.list),
      //       label: 'Dashboard',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '₹ ${value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
