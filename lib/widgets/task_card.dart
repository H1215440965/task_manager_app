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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: t.isCompleted,
                onChanged: (_) => widget.service.toggleTask(t),
              ),
              title: Text(
                t.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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

            // 🔽 SUBTASK SECTION
            if (expanded) ...[
              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: subController,
                      decoration: InputDecoration(
                        hintText: "Add subtask...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      if (subController.text.trim().isEmpty) return;
                      await widget.service
                          .addSubtask(t, subController.text);
                      subController.clear();
                    },
                  )
                ],
              ),

              const SizedBox(height: 8),

              ...t.subtasks.asMap().entries.map((entry) {
                int i = entry.key;
                var sub = entry.value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
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