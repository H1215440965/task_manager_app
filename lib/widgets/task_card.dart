import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final TaskService service;

  const TaskCard({super.key, required this.task, required this.service});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool expanded = false;
  final TextEditingController subController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = widget.task;

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.service.deleteTask(t.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.orange.withOpacity(0.1),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: t.isCompleted,
                onChanged: (_) => widget.service.toggleTask(t),
              ),
              title: Text(
                t.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration:
                      t.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() => expanded = !expanded);
                },
              ),
            ),

            // 🔽 SUBTASKS
            if (expanded) ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: subController)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await widget.service
                          .addSubtask(t, subController.text);
                      subController.clear();
                    },
                  )
                ],
              ),
              ...t.subtasks.asMap().entries.map((entry) {
                int i = entry.key;
                var sub = entry.value;

                return ListTile(
                  leading: Checkbox(
                    value: sub['isDone'] ?? false,
                    onChanged: (_) =>
                        widget.service.toggleSubtask(t, i),
                  ),
                  title: Text(
                    sub['title'],
                    style: TextStyle(
                      decoration: (sub['isDone'] ?? false)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        widget.service.deleteSubtask(t, i),
                  ),
                );
              })
            ]
          ],
        ),
      ),
    );
  }
}