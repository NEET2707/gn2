import 'dart:io';
import 'package:gn_account_manager/transactionpage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'package:open_file/open_file.dart';

class CreditPage extends StatefulWidget {
  final String name;
  final int id;

  const CreditPage({super.key, required this.name, required this.id});

  @override
  _CreditPageState createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  late Future<List<Map<String, dynamic>>> _transactionSummary;
  late Future<List<Map<String, dynamic>>> transactions;

  DateTime startDate = DateTime(2023, 1, 1);
  DateTime endDate = DateTime.now();

  double totalbal = 0.0;
  String? _transactionType = 'credit';
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _particularController = TextEditingController();

  // Add controllers for start and end dates
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _particularController.dispose();
    _startDateController.dispose(); // Dispose the start date controller
    _endDateController.dispose();   // Dispose the end date controller
    super.dispose();
  }


  double calculateTotalCredit(List<Map<String, dynamic>> transactions) {
    double totalCredit = 0.0;
    for (var tx in transactions) {
      if (tx["IsCredit"] == 1) { // Assuming 1 indicates credit
        totalCredit += tx["TotalAmount"] ?? 0.0;
      }
    }
    return totalCredit;
  }

  double calculateTotalDebit(List<Map<String, dynamic>> transactions) {
    double totalDebit = 0.0;
    for (var tx in transactions) {
      if (tx["IsCredit"] == 0) { // Assuming 0 indicates debit
        totalDebit += tx["TotalAmount"] ?? 0.0;
      }
    }
    return totalDebit;
  }

  double calculateBalance(double totalCredit, double totalDebit) {
    return totalCredit - totalDebit;
  }


  // Select Date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Select Start Date
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Select End Date
  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Save the transaction into the database
  Future<void> _saveTransaction() async {
    if (_dateController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _particularController.text.isNotEmpty) {
      final transaction = {
        'date': _dateController.text,
        'type': _transactionType,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'particular': _particularController.text,
        "name_id": widget.id
      };
      await AppDatabaseHelper().insertTransaction(transaction);

      // Clear fields after saving
      _dateController.clear();
      _amountController.clear();
      _particularController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction saved successfully!')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    return await AppDatabaseHelper().getTransactionsByAccountId(widget.id);
  }

  List<Map<String, dynamic>> _filteredTransactions = [];

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Start Date Input
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'ADD Date', // Title for the dialog
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      child: TextField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          await _selectStartDate(context);
                          setState(() {});
                        },
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 16),

                    // End Date Input
                    InkWell(
                      child: TextField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          await _selectEndDate(context);
                          setState(() {});
                        },
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Search Button
                    ElevatedButton(
                      onPressed: () async {
                        searchDateVise();
                      },
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void searchDateVise() async
  {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      // Fetch transactions
      List<Map<String, dynamic>> transactions =
          await _fetchTransactions();

      // Filter transactions between selected dates
      DateTime startDate =
      DateTime.parse(_startDateController.text);
      DateTime endDate =
      DateTime.parse(_endDateController.text);

      setState(() {
        _filteredTransactions = transactions.where((tx) {
          DateTime txDate = DateTime.parse(tx['date']);
          return txDate.isAfter(startDate) &&
              txDate.isBefore(endDate.add(Duration(days: 1)));
        }).toList();
      });
      Navigator.pop(context); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end dates.'),
        ),
      );
    }
  }

  void _saveAsPdf() {
    print("Saving as PDF...");
    // Add logic to generate and save the PDF
  }

  Future<void> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      // Request permissions for Android storage
      if (await Permission.storage.request().isGranted) {
        // Permission granted
      } else {
        print('Storage permission is denied');
      }

      // For Android 10+ (API level 29 and above)
      if (await Permission.manageExternalStorage.request().isGranted) {
        print("External Storage Permission granted.");
      } else {
        print("External Storage Permission denied.");
      }
    }
  }

  Future<String?> getDownloadDirectory() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadDir = Directory('${directory.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true); // Ensure the folder exists
        }
        return downloadDir.path; // Return path of the download directory
      } else {
        print("External storage directory not found.");
        return null;
      }
    } catch (e) {
      print("Error getting directory: $e");
      return null;
    }
  }

  Future<void> generatePDF(BuildContext context) async {
    try {
      // Request permissions to access storage
      await requestStoragePermissions();

      final pdf = pw.Document();

      // Use the filtered transactions for the PDF
      List<Map<String, dynamic>> transactions = _filteredTransactions.isNotEmpty
          ? _filteredTransactions
          : await AppDatabaseHelper().getTransactionsByAccountId(widget.id);

      print(transactions); // Check the data in the console

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Transaction Summary',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Date column
                    1: pw.FlexColumnWidth(2), // Particular column
                    2: pw.FlexColumnWidth(1), // Credit column
                    3: pw.FlexColumnWidth(1), // Debit column
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Particular', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Credit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Debit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table rows for each transaction
                    ...transactions.map((tx) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['date'] ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['particular'] ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['type'] == 'credit' ? (tx['amount']?.toString() ?? '0') : '--'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['type'] == 'debit' ? (tx['amount']?.toString() ?? '0') : '--'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Display totals
                pw.Text('Total Credit: ${calculateTotalCredit(transactions)}', style: pw.TextStyle(fontSize: 18)),
                pw.Text('Total Debit: ${calculateTotalDebit(transactions)}', style: pw.TextStyle(fontSize: 18)),
                pw.Text(
                  'Total Balance: ${calculateBalance(calculateTotalCredit(transactions), calculateTotalDebit(transactions))}',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ],
            );
          },
        ),
      );

      // Get the download directory path
      final outputDir = await getDownloadDirectory();
      if (outputDir == null) {
        // Handle the case where directory is null
        print("Unable to get download directory.");
        return;
      }

      final outputFile = File("${outputDir}/Transaction_Summary.pdf");
      print("Saving PDF to: ${outputFile.path}");
      await outputFile.writeAsBytes(await pdf.save());

      print("PDF saved to: ${outputFile.path}");

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to Downloads folder'),
          backgroundColor: Colors.green,
        ),
      );

      // Open the saved PDF
      await OpenFile.open(outputFile.path);
    } catch (e) {
      print("Error generating PDF: $e");

      // Show an error message if PDF generation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  late int transactionId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    // Wait for the count to be fetched asynchronously
    transactionId = await AppDatabaseHelper.instance.countTransactions(widget.id);
    transactions = (await AppDatabaseHelper.instance.getTransactionSummary()) as Future<List<Map<String, dynamic>>>;
    // fetchAndCalculateTransactions();  // If you have additional logic
    setState(() {}); // Call setState to update the UI after data is fetched
  }





  // Future<void> displayTransactionSummaryOnCreditPage() async {
  //   final dbHelper = AppDatabaseHelper.instance;
  //   List<Map<String, dynamic>> transactions = await dbHelper.getAllTransactions(); // Use getAllTransactions for a broader fetch
  //
  //   if (transactions.isEmpty) {
  //     print("No transactions found.");
  //   }
  //
  //   for (var transaction in transactions) {
  //     print("Transaction ID: ${transaction[KEY_TRANSACTION_ID]}");
  //     print("Transaction Date: ${transaction[KEY_TRANSACTION_DATE]}");
  //     print("Credit: ${transaction[KEY_IS_CREDIT]}");
  //     print("Total Amount: ${transaction[KEY_TOTAL_AMOUNT]}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFECECEC)),
        title: Text(
          widget.name, // Display the name passed to the widget
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey.shade600,
        actions: [
          // Add Transaction Button
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TransactionPage(name: widget.name,id: widget.id,tid: transactionId + 1,)),
              );

              // showDialog(
                // context: context,
                // builder: (context) {
                //   return StatefulBuilder(
                //     builder: (context, setState) {
                //       return Dialog(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(16.0), // Rounded corners
                //         ),
                //         child: Padding(
                //           padding: const EdgeInsets.all(20.0),
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               // Add Transaction Title
                //               Padding(
                //                 padding: const EdgeInsets.only(bottom: 20.0),
                //                 child: Center(
                //                   child: Text(
                //                     'Add Transaction',
                //                     style: TextStyle(
                //                       fontSize: 24,
                //                       fontWeight: FontWeight.bold,
                //                       color: Colors.blueAccent, // Color for title
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //
                //               // Date Input
                //               GestureDetector(
                //                 onTap: () => _selectDate(context),
                //                 child: AbsorbPointer( // Prevent keyboard from appearing
                //                   child: TextField(
                //                     controller: _dateController,
                //                     readOnly: true,
                //                     decoration: InputDecoration(
                //                       labelText: 'Transaction Date',
                //                       labelStyle: TextStyle(color: Colors.blueGrey),
                //                       border: OutlineInputBorder(
                //                         borderRadius: BorderRadius.circular(12.0),
                //                       ),
                //                       suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(height: 16),
                //
                //               // Transaction Type (Radio buttons)
                //               Padding(
                //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                //                 child: Row(
                //                   children: [
                //                     Radio<String>(
                //                       value: 'credit',
                //                       groupValue: _transactionType,
                //                       onChanged: (String? value) {
                //                         setState(() {
                //                           _transactionType = value!;
                //                         });
                //                       },
                //                     ),
                //                     Text('Credit', style: TextStyle(fontSize: 16)),
                //                     SizedBox(width: 20),
                //                     Radio<String>(
                //                       value: 'debit',
                //                       groupValue: _transactionType,
                //                       onChanged: (String? value) {
                //                         setState(() {
                //                           _transactionType = value!;
                //                         });
                //                       },
                //                     ),
                //                     Text('Debit', style: TextStyle(fontSize: 16)),
                //                   ],
                //                 ),
                //               ),
                //               SizedBox(height: 16),
                //
                //               // Amount Input
                //               TextField(
                //                 controller: _amountController,
                //                 keyboardType: TextInputType.number,
                //                 decoration: InputDecoration(
                //                   labelText: 'Amount',
                //                   labelStyle: TextStyle(color: Colors.blueGrey),
                //                   border: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(12.0),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(height: 16),
                //
                //               // Particular Input
                //               TextField(
                //                 controller: _particularController,
                //                 decoration: InputDecoration(
                //                   labelText: 'Particular',
                //                   labelStyle: TextStyle(color: Colors.blueGrey),
                //                   border: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(12.0),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(height: 24),
                //
                //               // Save Button
                //               Center(
                //                 child: ElevatedButton(
                //                   onPressed: () async {
                //                     // Form Validation
                //                     if (_dateController.text.isEmpty ||
                //                         _transactionType == null ||
                //                         _amountController.text.isEmpty ||
                //                         _particularController.text.isEmpty) {
                //                       // Show error message if any field is empty
                //                       ScaffoldMessenger.of(context).showSnackBar(
                //                         SnackBar(
                //                           content: Text('Please fill in all fields.'),
                //                           backgroundColor: Colors.red,
                //                         ),
                //                       );
                //                     } else {
                //                       // Proceed to save the transaction
                //                       await _saveTransaction(); // Call the save method
                //                       Navigator.pop(context); // Close the dialog
                //                       setState(() {}); // Refresh the UI
                //                     }
                //                   },
                //                   style: ElevatedButton.styleFrom(
                //                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(8),
                //                     ),
                //                   ),
                //                   child: Text(
                //                     'Save Transaction',
                //                     style: TextStyle(fontSize: 16),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   );
                // },
              // );
            },
          ),

          IconButton(
            onPressed: () {
              _showSearchDialog(); // Open the search dialog
            },
            icon: Icon(Icons.search),
          ),

          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'save_as_pdf') {
                // Pass the context to generatePDF method
                generatePDF(context);
                _saveAsPdf();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'save_as_pdf',
                child: Text('Save as PDF'),
              ),
            ],
          ),

        ],
      ),
      body: Column(
        children: [
          // Transaction Table Header
          Container(
            color: Colors.blueGrey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text('No',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Date',
                          style: TextStyle(fontWeight: FontWeight.bold)),flex: 2,),
                  Expanded(
                      child: Text('Particular',
                          style: TextStyle(fontWeight: FontWeight.bold)),flex: 2),
                  Expanded(
                      child: Text('Credit',
                          style: TextStyle(fontWeight: FontWeight.bold)),flex: 2),
                  Expanded(
                      child: Text('Debit',
                          style: TextStyle(fontWeight: FontWeight.bold)),flex: 1),
                ],
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transactions available.'));
                } else {
                  // Display filtered transactions if available
                  var transactions = _filteredTransactions.isEmpty
                      ? snapshot.data!
                      : _filteredTransactions;

                  double totalCredit = calculateTotalCredit(transactions);
                  double totalDebit = calculateTotalDebit(transactions);
                  double balance = calculateBalance(totalCredit, totalDebit);

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _fetchTransactions();
                          },
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              var transaction = transactions[index];
                              return Container(
                                color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('${index + 1}')),
                                      Expanded(
                                        child: Text('${transaction['TransactionDate']}'),
                                        flex: 2,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text('${transaction['Note']}'),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        child: Text(
                                          transaction['IsCredit'] == 1
                                              ? '₹${transaction['TotalAmount']}'
                                              : '0.00',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          transaction['IsCredit'] == 0
                                              ? '₹${transaction['TotalAmount']}'
                                              : '0.00',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Credit',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '${totalCredit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Debit',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '${totalDebit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Color(0xFF5C9EAD),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total Balance',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      '${balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                }
              },
            ),
          ),
        ],
      ),


    );
  }

}

