import 'package:flutter/material.dart';
import 'database.dart';
import 'student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  Future<void> _refreshStudents() async {
    final data = await _databaseHelper.getStudents();
    setState(() {
      students = data;
    });
  }

  Future<void> _addStudent() async {
    final student = Student(
      id: students.length + 1,
      name: nameController.text,
      age: int.parse(ageController.text),
    );
    await _databaseHelper.insertStudent(student);
    nameController.clear();
    ageController.clear();
    _refreshStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await _databaseHelper.deleteStudent(id);
    _refreshStudents();
  }

  Future<void> _updateStudent(Student student) async {
    await _databaseHelper.updateStudent(student);
    _refreshStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Page')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addStudent,
                  child: const Text('Add Student'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text('${student.name} - ${student.age} years old'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          nameController.text = student.name;
                          ageController.text = student.age.toString();
                          _updateStudent(student);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStudent(student.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
