
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ... rest of the file remains as previously provided ...

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isCompleted: json['isCompleted'],
      );
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      setState(() {
        tasks = tasksJson.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksString);
  }

  void _addTask(String title) {
    if (title.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: title));
      });
      _taskController.clear();
      _saveTasks();
    }
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _editTask(int index, String newTitle) {
    if (newTitle.isNotEmpty) {
      setState(() {
        tasks[index].title = newTitle;
      });
      _saveTasks();
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Add Task',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: _taskController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter task title',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _addTask(_taskController.text);
              Navigator.pop(context);
            },
            child: Text(
              'Add',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(int index) {
    _taskController.text = tasks[index].title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Edit Task',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: _taskController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new task title',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.grey[400],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _editTask(index, _taskController.text);
              _taskController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954).withOpacity(0.2),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To-Do List',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks yet. Add a task to get started!',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              color: Colors.grey[400]!,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(tasks[index].title + index.toString()),
                              onDismissed: (direction) {
                                _deleteTask(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task deleted'),
                                    backgroundColor: Colors.grey[800],
                                  ),
                                );
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: tasks[index].isCompleted,
                                  onChanged: (value) => _toggleTask(index),
                                  activeColor: Color(0xFF1DB954),
                                ),
                                title: Text(
                                  tasks[index].title,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    color: Colors.white,
                                    decoration: tasks[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.grey[400]),
                                  onPressed: () => _showEditTaskDialog(index),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1DB954),
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}