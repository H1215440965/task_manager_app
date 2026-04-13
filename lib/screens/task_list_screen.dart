import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const TaskListScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ ADD TASK
  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    await _taskService.addTask(title);
    _taskController.clear();
  }

  // ✅ FILTER (SEARCH)
  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchText.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        actions: [
          // 🌙 Dark mode toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),

      body: Column(
        children: [
          // =========================
          // ➕ ADD TASK INPUT
          // =========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // =========================
          // 🔍 SEARCH BAR
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // =========================
          // 📡 TASK LIST (REAL-TIME)
          // =========================
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                // ⏳ LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ❌ ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final tasks = snapshot.data ?? [];
                final filteredTasks = _filterTasks(tasks);

                // 📭 EMPTY STATE
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks yet. Add one above!',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // 🔍 NO SEARCH RESULT
                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching tasks found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // ✅ DATA LIST
                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(
                      task: filteredTasks[index],
                      service: _taskService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}