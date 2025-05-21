import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_entry_model.dart';
import '../providers/project_task_provider.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/add_task_dialog.dart';

class AddTimeEntryScreen extends StatefulWidget {
  final TimeEntry? initialEntry;

  const AddTimeEntryScreen({Key? key, this.initialEntry}) : super(key: key);

  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  late TextEditingController _totalTimeController;
  late TextEditingController _notesController;
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _totalTimeController = TextEditingController(
      text: widget.initialEntry?.totalTime.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialEntry?.notes ?? '',
    );
    _selectedDate = widget.initialEntry?.date ?? DateTime.now();
    _selectedProjectId = widget.initialEntry?.projectId;
    _selectedTaskId = widget.initialEntry?.taskId;
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<TimeEntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null ? 'Add Time Entry' : 'Edit Time Entry',
        ),
        backgroundColor: const Color.fromARGB(255, 60, 18, 132),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8.0,
              ), // Adjust the padding as needed
              child: buildProjectDropdown(entryProvider),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8.0,
              ), // Adjust the padding as needed
              child: buildTaskDropdown(entryProvider),
            ),

            buildTextField(
              _totalTimeController,
              'Total Time (in Hours)',
              TextInputType.numberWithOptions(decimal: true),
            ),
            buildTextField(_notesController, 'Note', TextInputType.text),
            buildDateField(_selectedDate),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: _saveEntry,
          child: Text('Save Time Entry'),
        ),
      ),
    );
  }

  void _saveEntry() {
    //check if time field is empty [error handling]
    if (_totalTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields!')),
      );
      return;
    }

    final entry = TimeEntry(
      id:
          widget.initialEntry?.id ??
          DateTime.now().toString(), // Assuming you generate IDs like this
      projectId: _selectedProjectId!,
      taskId: _selectedTaskId!,
      totalTime: double.parse(_totalTimeController.text),
      date: _selectedDate,
      notes: _notesController.text,
    );

    // Calling the provider to add or update the expense
    Provider.of<TimeEntryProvider>(
      context,
      listen: false,
    ).addOrUpdateTimeEntry(entry);
    Navigator.pop(context);
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: type,
      ),
    );
  }

  // Helper method to build the date picker field
  Widget buildDateField(DateTime selectedDate) {
    return ListTile(
      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget buildProjectDropdown(TimeEntryProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedProjectId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder:
                (context) => AddProjectDialog(
                  onAdd: (newProject) {
                    setState(() {
                      _selectedProjectId =
                          newProject
                              .id; // Automatically select the new category
                      provider.addProject(
                        newProject,
                      ); // Add to provider, assuming this method exists
                    });
                  },
                ),
          );
        } else {
          setState(() => _selectedProjectId = newValue);
        }
      },
      items:
          provider.projects.map<DropdownMenuItem<String>>((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList()
            ..add(
              DropdownMenuItem(value: "New", child: Text("Add New Project")),
            ),
      decoration: InputDecoration(
        labelText: 'Project',
        border: OutlineInputBorder(),
      ),
    );
  }

  // Helper method to build the tag dropdown
  Widget buildTaskDropdown(TimeEntryProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedTaskId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder:
                (context) => AddTaskDialog(
                  onAdd: (newTask) {
                    provider.addTask(
                      newTask,
                    ); // Assuming you have an `addTag` method.
                    setState(
                      () => _selectedTaskId = newTask.id,
                    ); // Update selected tag ID
                  },
                ),
          );
        } else {
          setState(() => _selectedTaskId = newValue);
        }
      },
      items:
          provider.tasks.map<DropdownMenuItem<String>>((task) {
              return DropdownMenuItem<String>(
                value: task.id,
                child: Text(task.name),
              );
            }).toList()
            ..add(DropdownMenuItem(value: "New", child: Text("Add New Task"))),
      decoration: InputDecoration(
        labelText: 'Task',
        border: OutlineInputBorder(),
      ),
    );
  }
}
