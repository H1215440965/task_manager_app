import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasks.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _tasks.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleTask(Task task) async {
    await _tasks.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> updateTaskTitle(Task task, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    await _tasks.doc(task.id).update({
      'title': newTitle.trim(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  Future<void> addSubtask(Task task, String subtaskTitle) async {
    if (subtaskTitle.trim().isEmpty) return;

    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);
    updatedSubtasks.add({
      'title': subtaskTitle.trim(),
      'isDone': false,
    });

    await _tasks.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> toggleSubtask(Task task, int index) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (index >= 0 && index < updatedSubtasks.length) {
      updatedSubtasks[index]['isDone'] =
          !(updatedSubtasks[index]['isDone'] ?? false);
    }

    await _tasks.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> updateSubtaskTitle(Task task, int index, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (index >= 0 && index < updatedSubtasks.length) {
      updatedSubtasks[index]['title'] = newTitle.trim();
    }

    await _tasks.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> deleteSubtask(Task task, int index) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (index >= 0 && index < updatedSubtasks.length) {
      updatedSubtasks.removeAt(index);
    }

    await _tasks.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }
}