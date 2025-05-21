import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/project_task_provider.dart';
import '../widgets/add_task_dialog.dart';

class ManageTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        backgroundColor:
            Colors.deepPurple, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final category = provider.tasks[index];
              return ListTile(
                title: Text(category.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteTask(category.id);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AddTaskDialog(
                  onAdd: (newTask) {
                    Provider.of<TimeEntryProvider>(
                      context,
                      listen: false,
                    ).addTask(newTask);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
          );
        },
        tooltip: 'Add a New Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
