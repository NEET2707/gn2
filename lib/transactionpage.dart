import 'package:flutter/material.dart';
import 'package:gn_account_manager/creditpage.dart';
import 'database_helper.dart';

class TransactionPage extends StatefulWidget {
  final String name;
  final int id;

  const TransactionPage({super.key, required this.name, required this.id});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // TextEditingControllers for each input field
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _transactionDateController = TextEditingController();
  final TextEditingController _invoiceNoController = TextEditingController();
  final TextEditingController _accountIdController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _isCreditController = TextEditingController();
  final TextEditingController _isReminderController = TextEditingController();
  final TextEditingController _reminderDateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _currentDueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Form', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // AppBar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_transactionIdController, 'Transaction ID', TextInputType.number),
            _buildTextField(_transactionDateController, 'Transaction Date', TextInputType.text, isDate: true),
            _buildTextField(_totalAmountController, 'Total Amount', TextInputType.numberWithOptions(decimal: true)),
            _buildCheckbox('Is Credit', _isCreditController),
            _buildTextField(_noteController, 'Note', TextInputType.text),

            SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // Custom function to build text fields
  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: isDate ? Icon(Icons.calendar_today) : null, // Add calendar icon for date fields
        ),
        readOnly: isDate,
        onTap: isDate ? () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (selectedDate != null) {
            setState(() {
              controller.text = selectedDate.toString().split(' ')[0];
            });
          }
        } : null,
      ),
    );
  }

  // Custom function for checkbox inputs
  Widget _buildCheckbox(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(label),
          Checkbox(
            value: controller.text == '1' ? true : false,
            onChanged: (bool? value) {
              setState(() {
                controller.text = value! ? '1' : '0';
              });
            },
          ),
        ],
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        // Collect the data
        Map<String, dynamic> transactionData = {
          'TransactionId': _transactionIdController.text,
          'TransactionDate': _transactionDateController.text,
          'InvoiceNo': 0,
          'AccountId': widget.id,
          'AccountName': widget.name,
          'Discount': 0.0,
          'TotalAmount': double.tryParse(_totalAmountController.text) ?? 0.0,
          'IsCredit': _isCreditController.text == '1' ? 1 : 0,
          'IsReminder': null,
          'ReminderDate': null,
          'Note': _noteController.text,
          'CurrentDue': null,
        };

        print(transactionData.toString());

        // Insert the transaction into the database
        int result = await AppDatabaseHelper.instance.insertTransaction(transactionData);

        // Print or show the result
        print('Transaction inserted with ID: $result');

        // Clear the text fields after saving the transaction
        _transactionIdController.clear();
        _transactionDateController.clear();
        _invoiceNoController.clear();
        _accountIdController.clear();
        _accountNameController.clear();
        _discountController.clear();
        _totalAmountController.clear();
        _isCreditController.clear();
        _isReminderController.clear();
        _reminderDateController.clear();
        _noteController.clear();
        _currentDueController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreditPage(name: widget.name, id: widget.id)),
        );
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Button color
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Save Transaction',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
