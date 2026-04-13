import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

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
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              ElevatedButton(onPressed: addTask, child: const Text("Add"))
            ],
          ),
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(hintText: "Search"),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: service.streamTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!
                    .where((t) =>
                        t.title.toLowerCase().contains(search.toLowerCase()))
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks"));
                }

                return ListView(
                  children: tasks
                      .map((t) => TaskCard(task: t, service: service))
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