import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final collection = FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> streamTasks() {
    return collection.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await collection.add({
      'title': title,
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleTask(Task task) async {
    await collection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> deleteTask(String id) async {
    await collection.doc(id).delete();
  }

  Future<void> addSubtask(Task task, String title) async {
    final list = List<Map<String, dynamic>>.from(task.subtasks);
    list.add({'title': title, 'isDone': false});

    await collection.doc(task.id).update({'subtasks': list});
  }

  Future<void> toggleSubtask(Task task, int index) async {
    final list = List<Map<String, dynamic>>.from(task.subtasks);
    list[index]['isDone'] = !(list[index]['isDone'] ?? false);

    await collection.doc(task.id).update({'subtasks': list});
  }

  Future<void> deleteSubtask(Task task, int index) async {
    final list = List<Map<String, dynamic>>.from(task.subtasks);
    list.removeAt(index);

    await collection.doc(task.id).update({'subtasks': list});
  }
}