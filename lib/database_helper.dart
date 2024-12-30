import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabaseHelper {
  static final AppDatabaseHelper _instance = AppDatabaseHelper._();
  static Database? _database;

  AppDatabaseHelper._();




  static AppDatabaseHelper get instance => _instance;
  factory AppDatabaseHelper() {
    return _instance;
  }

  static const String TABLE_CLIENT = 'tblClient';
  static const String KEY_ACCOUNT_ID = 'AccountId';
  static const String KEY_CLIENT_NAME = 'ClientName';
  static const String KEY_CLIENT_CODE = 'ClientCode';
  static const String KEY_CLIENT_EMAIL_ID = 'EmailId';
  static const String KEY_CONTACT_NO = 'ContactNo';
  static const String KEY_CLIENT_ADDRESS = 'Address';
  static const String KEY_DUE_BALANCE = 'DueBalance';

  static const String TABLE_TRANSACTION = 'tblTransaction';
  static const String KEY_TRANSACTION_ID = 'TransactionId';
  static const String KEY_TRANSACTION_DATE = 'TransactionDate';
  static const String KEY_TRANSACTION_INVOICE_NO = 'InvoiceNo';
  static const String KEY_TRANSACTION_ACCOUNT_ID = 'AccountId';
  static const String KEY_TRANSACTION_ACCOUNT_NAME = 'AccountName';
  static const String KEY_DISCOUNT = 'Discount';
  static const String KEY_TOTAL_AMOUNT = 'TotalAmount';
  static const String KEY_IS_CREDIT = 'IsCredit';
  static const String KEY_IS_REMINDER = 'IsReminder';
  static const String KEY_REMINDER_DATE = 'ReminderDate';
  static const String KEY_NOTE = 'Note';
  static const String KEY_CURRENT_DUE = 'CurrentDue';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static const String DATABASE_NAME = 'dbInvoiceGenerator';
  static const int DATABASE_VERSION = 2;

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DATABASE_NAME);
    return openDatabase(
      path,
      version: DATABASE_VERSION,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $TABLE_CLIENT (
            $KEY_ACCOUNT_ID INTEGER PRIMARY KEY,
            $KEY_CLIENT_NAME TEXT,
            $KEY_CLIENT_CODE TEXT,
            $KEY_CLIENT_EMAIL_ID TEXT,
            $KEY_CONTACT_NO TEXT,
            $KEY_CLIENT_ADDRESS TEXT,
            $KEY_DUE_BALANCE DOUBLE
          )
        ''');

        await db.execute('''
          CREATE TABLE $TABLE_TRANSACTION (
            $KEY_TRANSACTION_ID INTEGER PRIMARY KEY,
            $KEY_TRANSACTION_DATE DATETIME,
            $KEY_TRANSACTION_INVOICE_NO INTEGER,
            $KEY_TRANSACTION_ACCOUNT_ID INTEGER,
            $KEY_TRANSACTION_ACCOUNT_NAME TEXT,
            $KEY_DISCOUNT FLOAT,
            $KEY_TOTAL_AMOUNT DOUBLE,
            $KEY_IS_CREDIT INTEGER,
            $KEY_IS_REMINDER INTEGER,
            $KEY_REMINDER_DATE DATETIME,
            $KEY_NOTE TEXT,
            $KEY_CURRENT_DUE DOUBLE,
            FOREIGN KEY ($KEY_TRANSACTION_ACCOUNT_ID) REFERENCES $TABLE_CLIENT ($KEY_ACCOUNT_ID)
          )
        ''');
      },
    );
  }



  Future<List<Map<String, dynamic>>> getTransactionSummary() async {
    final db = await database;
    List<Map<String, dynamic>> transactions = await db.rawQuery('''
  SELECT 
    $KEY_TRANSACTION_ID AS NO,
    $KEY_TRANSACTION_DATE AS date,
    $KEY_NOTE AS Particular,
    CASE 
      WHEN $KEY_IS_CREDIT = 1 THEN $KEY_TOTAL_AMOUNT 
      ELSE NULL 
    END AS credit,
    CASE 
      WHEN $KEY_IS_CREDIT = 0 THEN $KEY_TOTAL_AMOUNT 
      ELSE NULL 
    END AS debit
  FROM $TABLE_TRANSACTION
''');

    print("Fetched Transactions: $transactions");  // Check the fetched data here
    return transactions;
  }


  void displayTransactionSummaryOnCreditPage() async {
    final dbHelper = AppDatabaseHelper.instance;
    List<Map<String, dynamic>> transactions = await dbHelper.getTransactionSummary();

    print("Transactions count: ${transactions.length}");  // Log number of transactions

    if (transactions.isEmpty) {
      print('No transactions to display.');
    } else {
      for (var transaction in transactions) {
        print("Transaction NO: ${transaction['NO']}");
        print("Date: ${transaction['date']}");
        print("Particular: ${transaction['Particular']}");

        if (transaction['credit'] != null) {
          print("Credit: ${transaction['credit']}");
        } else if (transaction['debit'] != null) {
          print("Debit: ${transaction['debit']}");
        }
      }
    }
  }




  // Client Table Methods

  Future<int> insertClient({
    required String clientName,
    required String clientCode,
    required String clientEmail,
    required String contactNo,
    required String clientAddress,
    required double dueBalance,
  }) async {
    final db = await database;
    Map<String, dynamic> clientData = {
      KEY_CLIENT_NAME: clientName,
      KEY_CLIENT_CODE: clientCode,
      KEY_CLIENT_EMAIL_ID: clientEmail,
      KEY_CONTACT_NO: contactNo,
      KEY_CLIENT_ADDRESS: clientAddress,
      KEY_DUE_BALANCE: dueBalance,
    };
    return await db.insert(
      TABLE_CLIENT,
      clientData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> displayDataClient() async {
    final db = await database;
    return await db.query(TABLE_CLIENT);
  }

  Future<int> updateClient({
    required int accountId,
    required String clientName,
    required String clientCode,
    required String clientEmail,
    required String contactNo,
    required String clientAddress,
    required double dueBalance,
  }) async {
    final db = await database;
    return await db.update(
      TABLE_CLIENT,
      {
        KEY_CLIENT_NAME: clientName,
        KEY_CLIENT_CODE: clientCode,
        KEY_CLIENT_EMAIL_ID: clientEmail,
        KEY_CONTACT_NO: contactNo,
        KEY_CLIENT_ADDRESS: clientAddress,
        KEY_DUE_BALANCE: dueBalance,
      },
      where: '$KEY_ACCOUNT_ID = ?',
      whereArgs: [accountId],
    );
  }

  Future<int> deleteClient(int accountId) async {
    final db = await database;
    return await db.delete(
      TABLE_CLIENT,
      where: '$KEY_ACCOUNT_ID = ?',
      whereArgs: [accountId],
    );
  }

  // Transaction Table Methods

  Future<int> insertTransaction(Map<String, dynamic> transactionData) async {
    final db = await database;
    return await db.insert(
      TABLE_TRANSACTION,
      transactionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query(TABLE_TRANSACTION);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDate(String accountName, String date) async {
    final db = await database;
    return await db.query(
      TABLE_TRANSACTION,
      where: '$KEY_TRANSACTION_ACCOUNT_NAME = ? AND $KEY_TRANSACTION_DATE = ?',
      whereArgs: [accountName, date],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsBetweenDates(
      String accountName, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM $TABLE_TRANSACTION
      WHERE $KEY_TRANSACTION_ACCOUNT_NAME = ?
      AND $KEY_TRANSACTION_DATE BETWEEN ? AND ?
    ''', [accountName, startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByAccountId(int accountId) async {
    final db = await database;
    return await db.query(
      TABLE_TRANSACTION,
      where: '$KEY_TRANSACTION_ACCOUNT_ID = ?',
      whereArgs: [accountId],
    );
  }

  Future<Map<String, double>> getTotalCreditDebitBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN $KEY_IS_CREDIT = 1 THEN $KEY_TOTAL_AMOUNT ELSE 0 END) AS totalCredit,
        SUM(CASE WHEN $KEY_IS_CREDIT = 0 THEN $KEY_TOTAL_AMOUNT ELSE 0 END) AS totalDebit
      FROM $TABLE_TRANSACTION
    ''');

    if (result.isNotEmpty) {
      double totalCredit = (result[0]['totalCredit'] as num?)?.toDouble() ?? 0.0;
      double totalDebit = (result[0]['totalDebit'] as num?)?.toDouble() ?? 0.0;
      double totalBalance = totalCredit - totalDebit;

      return {
        'totalCredit': totalCredit,
        'totalDebit': totalDebit,
        'totalBalance': totalBalance
      };
    }

    return {'totalCredit': 0.0, 'totalDebit': 0.0, 'totalBalance': 0.0};
  }

  // Combined Data Logic

  Future<List<Map<String, dynamic>>> loadClientsWithBalances() async {
    final db = await database;
    final clients = await db.query(TABLE_CLIENT);
    List<Map<String, dynamic>> updatedList = [];

    for (var clientData in clients) {
      final transactions = await getTransactionsByAccountId(int.parse(clientData[KEY_ACCOUNT_ID].toString()));

      double credit = 0.0;
      double debit = 0.0;

      for (var transaction in transactions) {
        if (transaction[KEY_IS_CREDIT] == 1) {
          credit += (transaction[KEY_TOTAL_AMOUNT] as num).toDouble();
        } else {
          debit += (transaction[KEY_TOTAL_AMOUNT] as num).toDouble();
        }
      }

      updatedList.add({
        'accountId': clientData[KEY_ACCOUNT_ID],
        'clientName': clientData[KEY_CLIENT_NAME],
        'credit': credit,
        'debit': debit,
        'balance': credit - debit,
      });
    }

    return updatedList;
  }

  // User Authentication Methods

  Future<bool> doesUserExist(String username) async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ?", [username]);
    return result.isNotEmpty;
  }

  Future<bool> login(String username, String password) async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [username, password]);
    return result.isNotEmpty;
  }

  Future<int> registerUser(String username, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        'usrName': username,
        'usrPassword': password,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
