import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

// Define the events
abstract class EmployeeEvent {}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Employee employee;

  AddEmployee(this.employee);
}

class UpdateEmployee extends EmployeeEvent {
  final Employee employee;

  UpdateEmployee(this.employee);
}

class DeleteEmployee extends EmployeeEvent {
  final Employee employee;

  DeleteEmployee(this.employee);
}

// Define the state
class EmployeeState {
  final List<Employee> employees;

  EmployeeState(this.employees);
}

// Define the repository
class EmployeeRepository {
  final String dbName = 'employee_database.db';
  final String tableName = 'employees';

  Future<List<Employee>> fetchEmployees() async {
    final String path = join(await getDatabasesPath(), dbName);
    final Database database = await openDatabase(path);

    await database.execute('''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY,
      name TEXT,
      role TEXT,
      startDate TEXT,
      endDate TEXT
    )
  ''');

    final List<Map<String, dynamic>> employeeMaps = await database.query(tableName);

    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final List<Employee> employees = employeeMaps.map((employeeMap) {
      final DateTime startDate =
      employeeMap['startDate'].isNotEmpty ? dateFormat.parse(employeeMap['startDate']) : DateTime.now();
      final DateTime? endDate =
      employeeMap['endDate'].isNotEmpty ? dateFormat.parse(employeeMap['endDate']) : null;

      return Employee(
        id: employeeMap['id'],
        name: employeeMap['name'],
        role: employeeMap['role'],
        startDate: startDate,
        endDate: endDate,
      );
    }).toList();

    await database.close();

    return employees;
  }

  Future<void> insertEmployee(Employee employee) async {
    final String path = join(await getDatabasesPath(), dbName);
    final Database database = await openDatabase(path);

    await database.insert(
      tableName,
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await database.close();
  }

  Future<void> updateEmployee(Employee employee) async {
    final String path = join(await getDatabasesPath(), dbName);
    final Database database = await openDatabase(path);

    await database.update(
      tableName,
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );

    await database.close();
  }

  Future<void> deleteEmployee(Employee employee) async {
    final String path = join(await getDatabasesPath(), dbName);
    final Database database = await openDatabase(path);

    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [employee.id],
    );

    await database.close();
  }
}

// Define the BLoC/Cubit
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repository;

  EmployeeBloc(this.repository) : super(EmployeeState([]));

  @override
  Stream<EmployeeState> mapEventToState(EmployeeEvent event) async* {
    if (event is LoadEmployees) {
      yield* _mapLoadEmployeesToState();
    } else if (event is AddEmployee) {
      yield* _mapAddEmployeeToState(event.employee);
    } else if (event is UpdateEmployee) {
      yield* _mapUpdateEmployeeToState(event.employee);
    } else if (event is DeleteEmployee) {
      yield* _mapDeleteEmployeeToState(event.employee);
    }
  }

  Stream<EmployeeState> _mapLoadEmployeesToState() async* {
    final List<Employee> employees = await repository.fetchEmployees();
    yield EmployeeState(employees);
  }

  Stream<EmployeeState> _mapAddEmployeeToState(Employee employee) async* {
    await repository.insertEmployee(employee);
    final List<Employee> employees = await repository.fetchEmployees();
    yield EmployeeState(employees);
  }

  Stream<EmployeeState> _mapUpdateEmployeeToState(Employee employee) async* {
    await repository.updateEmployee(employee);
    final List<Employee> employees = await repository.fetchEmployees();
    yield EmployeeState(employees);
  }

  Stream<EmployeeState> _mapDeleteEmployeeToState(Employee employee) async* {
    await repository.deleteEmployee(employee);
    final List<Employee> employees = await repository.fetchEmployees();
    yield EmployeeState(employees);
  }
}

// EmployeeListScreen and EmployeeAddScreen classes are defined here...

