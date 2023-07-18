import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'employee_list.dart';

class EmployeeAddScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeAddScreen({Key? key, this.employee}) : super(key: key);

  @override
  _EmployeeAddScreenState createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedRole = 'Select Role';

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      selectedRole = widget.employee!.role;
      selectedStartDate = widget.employee!.startDate;
      selectedEndDate = widget.employee!.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee != null ? 'Edit Employee' : 'Add Employee'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Employee Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Wrap(
                            children: [
                              ListTile(
                                title: Text(
                                  'Flutter Developer',
                                  style: TextStyle(
                                    color: selectedRole == 'Flutter Developer'
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedRole = 'Flutter Developer';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'QA Tester',
                                  style: TextStyle(
                                    color: selectedRole == 'QA Tester'
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedRole = 'QA Tester';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'Product Developer',
                                  style: TextStyle(
                                    color: selectedRole == 'Product Developer'
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedRole = 'Product Developer';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'Product Owner',
                                  style: TextStyle(
                                    color: selectedRole == 'Product Owner'
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedRole = 'Product Owner';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Select Role',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.work_outline, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedRole,
                          style: TextStyle(
                            color: selectedRole == 'Select Role'
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectStartDate(context);
                      },
                      child: Card(
                        elevation: 2,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectStartDate(context);
                                },
                                child:
                                Icon(Icons.calendar_today, color: Colors.blue),
                              ),
                              Text(
                                selectedStartDate != null
                                    ? DateFormat('dd MMM yyyy').format(
                                  selectedStartDate!,
                                )
                                    : 'Select Date',
                                style: TextStyle(
                                  color: selectedStartDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectEndDate(context);
                      },
                      child: Card(
                        elevation: 2,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectEndDate(context);
                                },
                                child:
                                Icon(Icons.calendar_today, color: Colors.blue),
                              ),
                              Text(
                                selectedEndDate != null
                                    ? DateFormat('dd MMM yyyy').format(
                                  selectedEndDate!,
                                )
                                    : 'Select Date',
                                style: TextStyle(
                                  color: selectedEndDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue.shade50,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          String employeeName = _nameController.text;
                          if (employeeName.isNotEmpty &&
                              selectedRole != 'Select Role') {
                            _saveEmployee(context, employeeName);
                            Navigator.pop(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Missing Information'),
                                  content: const Text(
                                      'Please provide the employee name and select a role.'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Date',
    );
    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime firstDate = selectedStartDate ?? DateTime.now();
    DateTime initialDate = selectedEndDate ?? firstDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Date',
    );
    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
      });
    }
  }

  Future<void> _saveEmployee(BuildContext context, String employeeName) async {
    final String path = join(await getDatabasesPath(), 'senthilraja.db');
    final Database database = await openDatabase(path);

    // Create the "employees" table if it doesn't exist
    await database.execute('''
    CREATE TABLE IF NOT EXISTS flutter (
      id INTEGER PRIMARY KEY,
      name TEXT,
      role TEXT,
      startDate TEXT,
      endDate TEXT
    )
  ''');

    final DateFormat dateFormat = DateFormat('dd MMM yyyy');

    final Map<String, dynamic> employeeData = {
      'name': employeeName,
      'role': selectedRole,
      'startDate': selectedStartDate != null
          ? dateFormat.format(selectedStartDate!)
          : '',
      'endDate': selectedEndDate != null
          ? dateFormat.format(selectedEndDate!)
          : '',
    };

    await database.insert(
      'flutter',
      employeeData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await database.close();

    // Navigate back to the EmployeeListScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmployeeListScreen()),
    );
  }
}
