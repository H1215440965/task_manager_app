import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../models/task.dart';

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
  final TaskService service = TaskService();
  final TextEditingController controller = TextEditingController();
  String search = '';

  void addTask() async {
    if (controller.text.trim().isEmpty) return;
    await service.addTask(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Column(
        children: [
          // ADD TASK
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Enter task",
                  ),
                ),
              ),
              ElevatedButton(onPressed: addTask, child: const Text("Add"))
            ],
          ),

          // SEARCH
          TextField(
            onChanged: (value) {
              setState(() {
                search = value;
              });
            },
            decoration: const InputDecoration(
              hintText: "Search...",
            ),
          ),

          // TASK LIST
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: service.streamTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;
                final filtered = tasks
                    .where((t) =>
                        t.title.toLowerCase().contains(search.toLowerCase()))
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks yet"));
                }

                return ListView(
                  children: filtered
                      .map((task) =>
                          TaskTile(task: task, service: service))
                      .toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}