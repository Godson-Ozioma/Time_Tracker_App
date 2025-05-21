import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project_model.dart';
import '../models/task_entry_model.dart';
import '../models/task_model.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  //Create a list to store Time Entries
  final List<TimeEntry> _entries = [];

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

  TimeEntryProvider(LocalStorage localStorage);
  
  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
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
  }

  void addTask(Task task) {
    if (!_tasks.any((cat) => cat.name == task.name)) {
      _tasks.add(task);
    }
  }

  //delete a task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }

}
