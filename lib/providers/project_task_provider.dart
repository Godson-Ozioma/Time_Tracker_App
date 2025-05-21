import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project_model.dart';
import '../models/task_entry_model.dart';
import '../models/task_model.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  //Create a list to store Time Entries
  List<TimeEntry> _entries = [];

  //Create a list to store Projects, and add some projects to list of Projects
  final List<Project> _projects = [
    Project(id: '1', name: 'Project 1'),
    Project(id: '2', name: 'Project 2'),
    Project(id: '3', name: 'Project 3'),
  ];

  //Create a list to store Tasks, and add some tasks to list of Tasks
  final List<Task> _tasks = [
    Task(id: '1', name: 'Task 1'),
    Task(id: '2', name: 'Task 2'),
  ];

  //Getters
  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  TimeEntryProvider(this.storage) {
    _loadTimeEntryFromStorage();
  }

  void _loadTimeEntryFromStorage() async {
    // await storage.ready;
    var storedEntries = storage.getItem('entries');
    //check if local storage is empty
    if (storedEntries != null) {
      _entries = List<TimeEntry>.from(
        (storedEntries as List).map((item) => TimeEntry.fromJson(item)),
      );
      notifyListeners();
    }
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveTimeEntryToStorage();
    notifyListeners();
  }

  void _saveTimeEntryToStorage() {
    storage.setItem(
      'entries',
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }

  //add or update an entry
  void addOrUpdateTimeEntry(TimeEntry entry) {
    int index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      // Update existing entry
      _entries[index] = entry;
    } else {
      // Add new entry
      _entries.add(entry);
    }
    _saveTimeEntryToStorage(); // Save the updated list to local storage
    notifyListeners(); //notify listeners of a new change
  }

  //delete a time entry
  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveTimeEntryToStorage();//update the local storage of new changes
    notifyListeners();
  }

  //add a project
  void addProject(Project project) {
    if (!_projects.any((cat) => cat.name == project.name)) {
      _projects.add(project);
      notifyListeners();
    }
  }

  //delete a project
  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }

  //add a task to the list of tasks
  void addTask(Task task) {
    if (!_tasks.any((cat) => cat.name == task.name)) {
      _tasks.add(task);
    }
    notifyListeners();
  }

  //delete a task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
