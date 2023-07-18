import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'employee_add.dart';


class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> _employees = [];
  List<Employee> _currentEmployees = [];
  List<Employee> _previousEmployees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _deleteEmployee(BuildContext context, Employee employee) async {
    final String path = join(await getDatabasesPath(), 'senthilraja.db');
    final Database database = await openDatabase(path);

    await database.delete(
      'flutter',
      where: 'id = ?',
      whereArgs: [employee.id],
    );

    setState(() {
      if (employee.endDate == null) {
        _currentEmployees.remove(employee);
      } else {
        _previousEmployees.remove(employee);
      }
      _employees.remove(employee);
    });

    _showDeleteSnackBar(context, employee);
  }

  void _showDeleteSnackBar(BuildContext context, Employee employee) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee data has been deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _insertEmployee(employee);
          },
        ),
      ),
    );
  }

  void _fetchEmployees() async {
    final String path = join(await getDatabasesPath(), 'senthilraja.db');
    final Database database = await openDatabase(path);

    // Create the "flutter" table if it doesn't exist
    await database.execute('''
    CREATE TABLE IF NOT EXISTS flutter (
      id INTEGER PRIMARY KEY,
      name TEXT,
      role TEXT,
      startDate TEXT,
      endDate TEXT
    )
  ''');

    final List<Map<String, dynamic>> employees = await database.query('flutter');

    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    _employees = employees.map((employee) {
      final DateTime startDate =
      employee['startDate'].isNotEmpty ? dateFormat.parse(employee['startDate']) : DateTime.now();
      final DateTime? endDate =
      employee['endDate'].isNotEmpty ? dateFormat.parse(employee['endDate']) : null;

      return Employee(
        id: employee['id'],
        name: employee['name'],
        role: employee['role'],
        startDate: startDate,
        endDate: endDate,
      );
    }).toList();

    // Filter employees into current and previous based on the presence of an end date
    _currentEmployees = _employees.where((employee) => employee.endDate == null).toList();
    _previousEmployees = _employees.where((employee) => employee.endDate != null).toList();

    setState(() {
      _employees = _employees;
      _currentEmployees = _currentEmployees;
      _previousEmployees = _previousEmployees;
    });

    await database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Employee List'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (_currentEmployees.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Current Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: _currentEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = _currentEmployees[index];
                    return Dismissible(
                      key: ValueKey(employee.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteEmployee(context, employee); // Pass the context and employee
                      },
                      child: Container(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                employee.name,
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                              Text(
                                employee.role,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'From',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    DateFormat(' dd MMM yyyy').format(employee.startDate),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          if (_previousEmployees.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Previous Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: _previousEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = _previousEmployees[index];
                    return Dismissible(
                      key: ValueKey(employee.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteEmployee(context, employee);
                      },
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            Text(
                              employee.role,
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            Row(
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(employee.startDate),
                                  style: TextStyle(color: Colors.grey, fontSize: 15),
                                ),
                                Text(
                                  DateFormat(' - dd MMM yyyy').format(employee.endDate!),
                                  style: TextStyle(color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          if (_currentEmployees.isNotEmpty || _previousEmployees.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Swipe left to delete',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
          if (_currentEmployees.isEmpty && _previousEmployees.isEmpty) ...[
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.asset(
                          'assets/no_records.png',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Text(
                            'No Employee Records Found!',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeAddScreen(),
            ),
          );

          if (result != null && result is Employee) {
            await _insertEmployee(result);
          }
        },
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _insertEmployee(Employee employee) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'senthilraja.db'),
    );

    await database.insert(
      'flutter',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await database.close();

    setState(() {
      _employees.add(employee);
      if (employee.endDate == null) {
        _currentEmployees.add(employee);
      } else {
        _previousEmployees.add(employee);
      }
    });
  }
}

class Employee {
  final int? id;
  final String name;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'startDate': DateFormat('dd MMM yyyy').format(startDate),
      'endDate': endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : '',
    };
  }
}