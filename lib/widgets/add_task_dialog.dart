import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/project_task_provider.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onAdd;

  AddTaskDialog({required this.onAdd});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a New Task'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: 'Task Name'),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            var newTask = Task(
              id: DateTime.now().toString(),
              name: _controller.text,
            );
            widget.onAdd(newTask);
            Provider.of<TimeEntryProvider>(
              context,
              listen: false,
            ).addTask(newTask);
            _controller.clear(); // Clear the input field
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
