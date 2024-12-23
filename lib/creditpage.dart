import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'searchresultpage.dart';
import 'package:open_file/open_file.dart';

class CreditPage extends StatefulWidget {
  final String name;

  const CreditPage({super.key, required this.name});

  @override
  _CreditPageState createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {


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

  // Calculate total credit
  double _calculateTotalCredit(List<Map<String, dynamic>> transactions) {
    double totalCredit = 0.0;
    for (var tx in transactions) {
      if (tx['type'] == 'credit') {
        totalCredit += tx['amount'] ?? 0.0;
      }
    }
    return totalCredit;
  }

  // Calculate total debit
  double _calculateTotalDebit(List<Map<String, dynamic>> transactions) {
    double totalDebit = 0.0;
    for (var tx in transactions) {
      if (tx['type'] == 'debit') {
        totalDebit += tx['amount'] ?? 0.0;
      }
    }
    return totalDebit;
  }

  // Calculate balance
  double _calculateBalance(double totalCredit, double totalDebit) {
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
        'particular': widget.name, // Save the name dynamically
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
    return await AppDatabaseHelper().getTransactionsByName(widget.name);
  }




  // Calculate total credit


  Future<List<Map<String, dynamic>>> _searchTransactionsBetweenDates(String startDate, String endDate) async {
    return await AppDatabaseHelper().getTransactionsBetweenDates(widget.name, startDate, endDate);
  }

  // Show search dialog
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
                    InkWell(
                      child: TextField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          // Show date picker to select start date
                          await _selectStartDate(context);
                          setState(() {}); // Refresh state after selecting the start date
                        },
                        keyboardType: TextInputType.datetime, // Allow typing of date
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
                          // Show date picker to select end date
                          await _selectEndDate(context);
                          setState(() {}); // Refresh state after selecting the end date
                        },
                        keyboardType: TextInputType.datetime, // Allow typing of date
                      ),
                    ),
                    SizedBox(height: 16),

                    // Search Button
                    ElevatedButton(
                      onPressed: () async {
                        // Ensure that both start and end dates are selected or entered
                        if (_startDateController.text.isNotEmpty &&
                            _endDateController.text.isNotEmpty) {
                          // Fetch transactions between the selected or entered dates
                          List<Map<String, dynamic>> transactions =
                          await _searchTransactionsBetweenDates(
                              _startDateController.text,
                              _endDateController.text);

                          // Calculate total credit, debit, and balance for the filtered transactions
                          double totalCredit = _calculateTotalCredit(transactions);
                          double totalDebit = _calculateTotalDebit(transactions);
                          double balance = _calculateBalance(totalCredit, totalDebit);

                          // Display the results in a new page or alert
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultPage(
                                totalCredit: totalCredit,
                                totalDebit: totalDebit,
                                balance: balance,
                                transactions: transactions,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please select both start and end dates.'),
                            ),
                          );
                        }
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

      // Fetch the transactions to include in the PDF
      List<Map<String, dynamic>> transactions = await AppDatabaseHelper().getTransactionsByName(widget.name);
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
                      // Debug: print individual transaction data
                      print("-------------------------> $tx");

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['date'] ?? 'N/A'), // Ensure data is available
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['particular'] ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['type'] == 'credit' ? (tx['amount']?.toString() ?? '0') : ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(tx['type'] == 'debit' ? (tx['amount']?.toString() ?? '0') : ''),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Display totals
                pw.Text('Total Credit: ${_calculateTotalCredit(transactions)}', style: pw.TextStyle(fontSize: 18)),
                pw.Text('Total Debit: ${_calculateTotalDebit(transactions)}', style: pw.TextStyle(fontSize: 18)),
                pw.Text(
                  'Balance: ${_calculateBalance(_calculateTotalCredit(transactions), _calculateTotalDebit(transactions))}',
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFECECEC)),
        title: Text(
          widget.name, // Display the name passed to the widget
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5C9EAD),
        actions: [
          // Add Transaction Button
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
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
                              // Date Input
                              InkWell(
                                child: TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Transaction Date',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () => _selectDate(context),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Transaction Type (Radio buttons)
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'credit',
                                    groupValue: _transactionType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _transactionType = value!;
                                      });
                                    },
                                  ),
                                  Text('Credit'),
                                  Radio<String>(
                                    value: 'debit',
                                    groupValue: _transactionType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _transactionType = value!;
                                      });
                                    },
                                  ),
                                  Text('Debit'),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Amount Input
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Particular Input
                              TextField(
                                controller: _particularController,
                                decoration: InputDecoration(
                                  labelText: 'Particular',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Save Button
                              ElevatedButton(
                                onPressed: () async {
                                  // Form Validation
                                  if (_dateController.text.isEmpty ||
                                      _transactionType == null ||
                                      _amountController.text.isEmpty ||
                                      _particularController.text.isEmpty) {
                                    // Show error message if any field is empty
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please fill in all fields.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    // Proceed to save the transaction
                                    await _saveTransaction(); // Call the save method
                                    Navigator.pop(context); // Close the dialog
                                    setState(() {}); // Refresh the UI
                                  }
                                },
                                child: Text('Save Transaction'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );

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
                      child: Text('Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Particular',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Credit',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Debit',
                          style: TextStyle(fontWeight: FontWeight.bold))),
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
                  var transactions = snapshot.data!;
                  double totalCredit = _calculateTotalCredit(transactions);
                  double totalDebit = _calculateTotalDebit(transactions);
                  double balance = _calculateBalance(totalCredit, totalDebit);

                  return Column(
                    children: [

                  Expanded(
                  child: ListView.builder(
                  itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      return Container(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.grey[200], // Alternate row colors
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text('${transaction['date']}')),
                              Expanded(
                                  child: Text(
                                      '${transaction['particular']}')),
                              Expanded(
                                  child: Text(
                                    transaction['type'] == 'credit'
                                        ? '\$${transaction['amount']}'
                                        : '0.00',
                                    style: TextStyle(color: Colors.green),
                                  )),
                              Expanded(
                                  child: Text(
                                    transaction['type'] == 'debit'
                                        ? '\$${transaction['amount']}'
                                        : '0.00',
                                    style: TextStyle(color: Colors.red),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                      Container(
                        // height: 150,
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
                                        backgroundColor: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),Text(
                                    '${totalCredit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.green,
                                        backgroundColor: Colors.white,
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
                                    'Total Debit:',
                                    style: TextStyle(
                                        color: Colors.red,
                                        backgroundColor: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '${totalDebit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.red,
                                        backgroundColor: Colors.white,
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
                                      'Total Balance:',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),Text(
                                      ' ${balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )

                          ],
                        ),
                      )
                      // Totals Display at Bottom

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