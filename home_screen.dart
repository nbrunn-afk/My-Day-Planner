import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../widgets/weather_card.dart';
import '../widgets/tip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box _todoBox;
  final List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _openBoxAndLoad();
  }

  Future<void> _openBoxAndLoad() async {
    _todoBox = await Hive.openBox('todos');
    _loadTodosFromBox();
  }

  void _loadTodosFromBox() {
    final stored = _todoBox.get('items', defaultValue: <dynamic>[]);
    _todos
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(
        (stored as List).map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      ));
    setState(() {});
  }

  Future<void> _saveTodosToBox() async {
    await _todoBox.put('items', _todos);
  }

  Future<void> _addTodoDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _todos.add({'title': text, 'done': false});
                  });
                  _saveTodosToBox();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodo(int index, bool? value) {
    setState(() {
      _todos[index]['done'] = value ?? false;
    });
    _saveTodosToBox();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodosToBox();
  }

  void _clearCompleted() {
    setState(() {
      _todos.removeWhere((t) => t['done'] == true);
    });
    _saveTodosToBox();
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MyDay Planner',
      applicationVersion: '1.0.0',
      children: const [
        Text(
          'This app was created as a CIS final project.\n'
          'It demonstrates: a clean UI, Hive data storage, a weather web API, '
          'and parsing a local JSON file for motivational tips.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyDay Planner'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearCompleted();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear completed tasks'),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const WeatherCard(),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: _todos.isEmpty
                            ? const Center(
                                child: Text('No tasks yet. Tap + to add one.'),
                              )
                            : ListView.separated(
                                itemCount: _todos.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final todo = _todos[index];
                                  return Dismissible(
                                    key: ValueKey(todo['title'].toString() + index.toString()),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      color: Colors.red.withOpacity(0.8),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (_) => _deleteTodo(index),
                                    child: CheckboxListTile(
                                      title: Text(
                                        todo['title'] as String,
                                        style: TextStyle(
                                          decoration: (todo['done'] == true)
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      value: todo['done'] as bool,
                                      onChanged: (value) => _toggleTodo(index, value),
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
            const SizedBox(height: 16),
            const TipCard(),
          ],
        ),
      ),
    );
  }
}
