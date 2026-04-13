import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final collection = FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> streamTasks() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
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
}