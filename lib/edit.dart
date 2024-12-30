import 'package:flutter/material.dart';
import 'package:gn_account_manager/dashboard.dart';

import 'database_helper.dart';

class editpage extends StatefulWidget {
  // final String name;
  // final String code;
  // final String email;
  // final String number;
  // final String add;
  // final String bal;
  //
  // const editpage({super.key, required this.name, required this.code, required this.email, required this.number, required this.add, required this.bal});
  @override
  State<editpage> createState() => _editpageState();
}

class _editpageState extends State<editpage> {
  late Future<List<Map<String, dynamic>>> _clientData;

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientCodeController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _clientAddressController = TextEditingController();
  final TextEditingController _dueBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientData = AppDatabaseHelper().displayDataClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Edit Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C9EAD),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form Section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Fill The All Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C9EAD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField('First Name', _clientNameController),
                    _buildInputField('Client code', _clientCodeController),
                    _buildInputField('Email Address', _clientEmailController),
                    _buildInputField('Contact Number', _contactNoController),
                    _buildInputField('Address', _clientAddressController),
                    _buildInputField('Due Balance', _dueBalanceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Get values from text controllers
                          String clientName = _clientNameController.text;
                          String clientCode = _clientCodeController.text;
                          String clientEmail = _clientEmailController.text;
                          String contactNo = _contactNoController.text;
                          String clientAddress = _clientAddressController.text;
                          double dueBalance = double.tryParse(_dueBalanceController.text) ?? 0.0;

                          // Insert data into the database
                          int result = await AppDatabaseHelper.instance.insertClient(
                            clientName: clientName,
                            clientCode: clientCode,
                            clientEmail: clientEmail,
                            contactNo: contactNo,
                            clientAddress: clientAddress,
                            dueBalance: dueBalance,
                          );

                          // Check if the insert was successful
                          if (result > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Client Added Successfully!')),
                            );
                            _clientNameController.text= "";
                            _clientCodeController.text= "";
                            _clientEmailController.text= "";
                            _contactNoController.text= "";
                            _clientAddressController.text= "";
                            _dueBalanceController.text = "";
                            Navigator.pop(context);
                            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard(),), (Route<dynamic> route) => false,);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to Add Client')),
                            );
                          }

                          setState(() {
                            _clientData = AppDatabaseHelper().displayDataClient();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF4C430),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
