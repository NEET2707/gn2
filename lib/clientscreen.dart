import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gn_account_manager/setpinscreen.dart';
import 'package:gn_account_manager/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'clientlistpage.dart';
import 'home.dart';
import 'database_helper.dart'; // Import the DatabaseHelper class
import 'creditpage.dart';
import 'namesearchdelegate.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isToggled = false;
  // late Future<List<Map<String, dynamic>>> _clientData;

  // var currentPage = DrawerSection.dashboard; // Define currentPage here
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> namesList = []; // List to store both name and id
  List<Map<String, dynamic>> filteredNamesList = []; // List for filtered names
  final dbHelper = AppDatabaseHelper();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _particularController = TextEditingController();
  String? _transactionType; // For radio button selection

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            pickedDate.toLocal().toString().split(' ')[0]; // Format date
      });
    }
  }

  void onToggleSwitch(bool value) {
    setState(() {
      isToggled = value;
    });

    if (value) {
      // Navigate to another page when the switch is turned on
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetPinScreen()),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _particularController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _fetchDashboardData();
    _loadNames();
    // _clientData = AppDatabaseHelper().displayDataClient();
  }

  double totalCredit = 0.0;
  double totalDebit = 0.0;
  double totalBalance = 0.0;

  Future<void> _fetchDashboardData() async {
    final data =
        await AppDatabaseHelper.instance.getTotalCreditDebitBalanceId(1);
    if (data.isNotEmpty) {
      setState(() {
        totalCredit = data['totalCredit'] ?? 0.0;
        totalDebit = data['totalDebit'] ?? 0.0;
        totalBalance = data['totalBalance'] ?? 0.0;
      });
    }
  }

  _loadNames() async {
    namesList = await dbHelper.loadClientsWithBalances();
    print("Names List: $namesList"); // Debug print
    filteredNamesList = namesList; // Set initial filtered list as all names
    setState(() {});
  }

  void _saveAsPdf() {
    print("Saving as PDF...");
    // Add logic to generate and save the PDF
  }

  Future<String?> getDownloadDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      // Handle the case where the directory is null
      print("External storage directory not found.");
      return null;
    }
    return directory.path; // Safely access the path
  }

  Future<void> requestStoragePermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else {
      // Handle the case where permission is denied
      print('Storage permission is denied');
    }
  }

  Future<void> generatePDF() async {
    try {
      // Request permissions
      await requestStoragePermissions();

      final pdf = pw.Document();

      // Add a title to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dashboard Data',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Name column
                    1: pw.FlexColumnWidth(1), // Credit column
                    2: pw.FlexColumnWidth(1), // Debit column
                    3: pw.FlexColumnWidth(1), // Balance column
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Name',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Credit',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Debit',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Balance',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...namesList.map((nameData) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(nameData['name']),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child:
                                pw.Text(nameData['credit']?.toString() ?? '0'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child:
                                pw.Text(nameData['debit']?.toString() ?? '0'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child:
                                pw.Text(nameData['balance']?.toString() ?? '0'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Get download directory path
      final outputDir = await getDownloadDirectory();
      if (outputDir == null) {
        // Handle the case where directory is null
        print("Unable to get download directory.");
        return;
      }

      // Save the PDF file to the Downloads directory
      final outputFile = File("${outputDir}/Dashboard_Data.pdf");

      await outputFile.writeAsBytes(await pdf.save());

      print("PDF saved to: ${outputFile.path}");

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to Downloads folder'),
          backgroundColor: Colors.green,
        ),
      );

      // Open the PDF file
      await OpenFile.open(outputFile.path);
    } catch (e) {
      print("Error generating PDF: $e");

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveTransaction2(String accountName, int accountId) async {
    if (_dateController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _particularController.text.isNotEmpty) {
      final transaction = {
        'TransactionDate': _dateController.text,
        'IsCredit': _transactionType == 'credit' ? 1 : 0,
        'TotalAmount': double.tryParse(_amountController.text) ?? 0.0,
        'Note': accountName,
        'AccountId': accountId,
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

  mytel(Map<String, dynamic> transactionData, int transactionType) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Ensure transaction type is set correctly
            _transactionType = transactionType == 0 ? "credit" : "debit";

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Transaction Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '${transactionType == 0 ? "Credit" : "Debit"} Transaction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              transactionType == 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),

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

                    ElevatedButton(
                      onPressed: () async {
                        if (_dateController.text.isEmpty ||
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
                          await _saveTransaction2(
                            transactionData["AccountId"],
                            transactionType == 0 ? 1 : 0, // Credit or Debit
                            // _dateController.text,
                            // double.tryParse(_amountController.text) ?? 0.0,
                            // _particularController.text,
                          );

                          setState(() {
                            if (transactionType == 0) {
                              double newCredit =
                                  double.tryParse(_amountController.text) ??
                                      0.0;
                              transactionData["TotalAmount"] =
                                  (transactionData["TotalAmount"] ?? 0.0) +
                                      newCredit;
                            }
                          });

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Dashboard(),
                            ),
                          );
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
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF0F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Color(0xFFECECEC)),
        title: Text(
          'Client Details ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade600,
        actions: [
          IconButton(
            icon: Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () async {
             File? pixkfile = await AppDatabaseHelper().pickCsvFile();
             if(pixkfile != null)
             AppDatabaseHelper().importClientsFromCsv(pixkfile);
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(),
                  ));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'save_as_pdf') {
                generatePDF();
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
      body: RefreshIndicator(
        onRefresh: () {
          return _loadNames();
        },
        child: ListView.builder(
          itemCount: namesList.length,
          itemBuilder: (context, index) {

            final data = namesList[index];
           return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreditPage(
                        name: data['clientName'], id: data['accountId']),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${data['accountId']}. ${data['clientName']}',style: TextStyle(color: Colors.blueGrey,fontSize: 18,fontWeight: FontWeight.w600),),
                          Row(
                            children: [
                              IconButton(
                                icon:
                                Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon:
                                Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete this client?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            int result =
                                            await AppDatabaseHelper
                                                .instance
                                                .deleteClient(data[
                                            'AccountId']);

                                            if (result > 0) {
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Client Deleted Successfully!')),
                                              );
                                              setState(() {
                                           _loadNames();
                                              });
                                              Navigator.pop(context);
                                            } else {
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to Delete Client')),
                                              );
                                            }
                                          },
                                          child: Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Text('Code: ${data['ClientCode']}'),
                      // Text('Email: ${data['EmailId']}'),
                      // Text('Contact No: ${data['ContactNo']}'),
                      // Text('Address: ${data['Address']}'),
                      // Text('Due Balance: ${data['DueBalance']}'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryCard(
                                'Credit(+)',  data['credit'], Colors.green),
                            _buildSummaryCard(
                                'Debit(-)', data['debit'], Colors.red),
                            _buildSummaryCard(
                              'Balance',
                              data['balance'],
                              Colors.blue,
                            ),
                          ],
                          // children: [
                          //   TextButton(
                          //     onPressed: () {
                          //       mytel(data, 0);
                          //     },
                          //     style: TextButton.styleFrom(
                          //       padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          //       backgroundColor: Colors.green.withOpacity(0.1),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //     ),
                          //     child: Column(
                          //       children: [
                          //         Text(
                          //           'Credit (+)',
                          //           style: TextStyle(
                          //             color: Colors.green,
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //         Text(
                          //           data['credit']?.toString() ?? '0',
                          //           style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 14,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   TextButton(
                          //     onPressed: () {
                          //       mytel(data, 1);
                          //     },
                          //     style: TextButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          //       backgroundColor: Colors.red.withOpacity(0.1),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //     ),
                          //     child: Column(
                          //       children: [
                          //         Text(
                          //           'Debit (-)',
                          //           style: TextStyle(
                          //             color: Colors.red,
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //         Text(
                          //           data['debit']?.toString() ?? '0',
                          //           style: const TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 14,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   TextButton(
                          //     onPressed: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => CreditPage(name: data["ClientName"], id: data["AccountId"]),
                          //         ),
                          //       );
                          //     },
                          //     style: TextButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          //       backgroundColor: Colors.blue.withOpacity(0.1),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //     ),
                          //     child: Column(
                          //       children: [
                          //         Text(
                          //           'Balance',
                          //           style: TextStyle(
                          //             color: Colors.blue,
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //         Text(
                          //           data['balance']?.toString() ?? '0',
                          //           style: const TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 14,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Material(
        color: Colors.blueGrey.shade600,
        shape: CircleBorder(),
        elevation: 6.0,
        child: InkWell(
          onTap: () {
            // Navigate to the new page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClientListPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.library_add, color: Colors.white),
          ),
        ),
      ),
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

// Drawer List
//   Widget MyDrawerList() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: 15,
//       ),
//       child: Column(
//         children: [
//           menuItem(1, "Home", Icons.home,
//               currentPage == DrawerSection.home ? true : false),
//           menuItem(2, "Backup", Icons.backup,
//               currentPage == DrawerSection.backup ? true : false),
//           menuItem(3, "Restore", Icons.restore,
//               currentPage == DrawerSection.restore ? true : false),
//           menuItem(4, "Change currency", Icons.settings,
//               currentPage == DrawerSection.changeCurrency ? true : false),
//           menuItem(5, "Change password", Icons.settings,
//               currentPage == DrawerSection.changePassword ? true : false),
//           menuItem(6, "Change security question", Icons.security,
//               currentPage == DrawerSection.securityQuestion ? true : false),
//           menuItem(7, "Setting ", Icons.settings,
//               currentPage == DrawerSection.settings ? true : false),
//           menuItem(8, "FAQs", Icons.question_answer,
//               currentPage == DrawerSection.faqs ? true : false),
//           menuItem(9, "Share the app", Icons.share,
//               currentPage == DrawerSection.shareApp ? true : false),
//           menuItem(10, "Rate the app", Icons.rate_review,
//               currentPage == DrawerSection.rateApp ? true : false),
//           menuItem(11, "Privacy policy", Icons.privacy_tip,
//               currentPage == DrawerSection.privacyPolicy ? true : false),
//           menuItem(12, "More apps", Icons.more,
//               currentPage == DrawerSection.moreApps ? true : false),
//           ListTile(
//             leading: Icon(Icons.pin),
//               title: Text("Enter pin"),
//             trailing: Switch(
//             value: isToggled,
//             onChanged: onToggleSwitch,
//           ),
//           )
//         ],
//       ),
//     );
//   }
//
//   // Drawer menu item
//   Widget menuItem(int id, String title, IconData icon, bool selected) {
//     return Material(
//       color: selected ? Colors.grey[200] : Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.pop(context);
//           setState(() {
//             switch (id) {
//               case 1:
//                 currentPage = DrawerSection.home;
//                 break;
//               case 2:
//                 currentPage = DrawerSection.backup;
//                 break;
//               case 3:
//                 currentPage = DrawerSection.restore;
//                 break;
//               case 4:
//                 currentPage = DrawerSection.changeCurrency;
//                 break;
//               case 5:
//                 currentPage = DrawerSection.changePassword;
//                 break;
//               case 6:
//                 currentPage = DrawerSection.securityQuestion;
//                 break;
//               case 7:
//                 currentPage = DrawerSection.settings;
//                 break;
//               case 8:
//                 currentPage = DrawerSection.faqs;
//                 break;
//               case 9:
//                 currentPage = DrawerSection.shareApp;
//                 break;
//               case 10:
//                 currentPage = DrawerSection.rateApp;
//                 break;
//               case 11:
//                 currentPage = DrawerSection.privacyPolicy;
//                 break;
//               case 12:
//                 currentPage = DrawerSection.moreApps;
//                 break;
//               // case 13:
//               //   currentPage = DrawerSection.enablepin;
//               //   Navigator.push(
//               //     context,
//               //     MaterialPageRoute(builder: (context) => SetPinScreen()), // Navigate to Set PIN screen
//               //   );
//               //   break;
//
//             }
//           });
//         },
//         child: Padding(
//           padding: EdgeInsets.all(15),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: Colors.black,
//               ),
//               SizedBox(width: 15),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Enum for Drawer Section
// enum DrawerSection {
//   dashboard, // Add this line
//   home,
//   backup,
//   restore,
//   changeCurrency,
//   changePassword,
//   securityQuestion,
//   settings,
//   faqs,
//   shareApp,
//   rateApp,
//   privacyPolicy,
//   moreApps,
//   logOut,
//   enablepin
