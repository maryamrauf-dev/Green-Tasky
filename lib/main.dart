import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Tasky',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: ToDoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  Set<int> _completedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
      final completedList = prefs.getStringList('completed') ?? [];
      _completedIndices = completedList.map(int.parse).toSet();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', _tasks);
    prefs.setStringList('completed', _completedIndices.map((i) => i.toString()).toList());
  }

  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _tasks.add(_controller.text.trim());
      _controller.clear();
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _completedIndices.remove(index);
      _completedIndices = _completedIndices.map((i) => i > index ? i - 1 : i).toSet();
    });
    _saveTasks();
  }

  void _toggleCompletion(int index) {
    setState(() {
      if (_completedIndices.contains(index)) {
        _completedIndices.remove(index);
      } else {
        _completedIndices.add(index);
      }
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1B5E20),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter new task',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks yet!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[900],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.white.withOpacity(0.95),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: _completedIndices.contains(index),
                            activeColor: Color(0xFF2E7D32),
                            onChanged: (_) => _toggleCompletion(index),
                          ),
                          title: Text(
                            _tasks[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[900],
                              decoration: _completedIndices.contains(index)
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                            onPressed: () => _deleteTask(index),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
