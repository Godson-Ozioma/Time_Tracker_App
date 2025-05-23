import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_task_provider.dart';
import 'add_time_entry_screen.dart';
import '../screens/manage_projects_screen.dart';
import '../screens/manage_tasks_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/project_model.dart';
import '../models/task_entry_model.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project Time Tracker"),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [Tab(text: "All Entries"), Tab(text: "Grouped By Projects")],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 73, 27, 152),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.deepPurple),
              title: Text('Projects'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_projects');
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: Colors.deepPurple),
              title: Text('Tasks'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_tasks');
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildEntriesByAll(context), buildEntriesByProject(context)],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
            ),
        tooltip: 'Add Time Entry',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildEntriesByAll(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Text(
              "Click the + button to record time entries.",
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.entries[index];
            final formattedDate = DateFormat('MMM dd, yyyy').format(entry.date);
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.deleteTimeEntry(entry.id);
              },
              background: Container(
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: Colors.purple[50],
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: ListTile(
                  title: Text(
                    "${getProjectNameById(context, entry.projectId)}: ${entry.totalTime.toStringAsFixed(2)} hrs",
                  ),
                  subtitle: Text(
                    "$formattedDate — Task: ${getTaskNameById(context, entry.taskId)}",
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildEntriesByProject(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Text(
              "Click the + button to record time entries.",
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          );
        }

        // Group entries by projectId
        final grouped = groupBy<TimeEntry, String>(
          provider.entries,
          (e) => e.projectId,
        );
        return ListView(
          children:
              grouped.entries.map((group) {
                final projectName = getProjectNameById(context, group.key);
                final totalHours = group.value.fold<double>(
                  0,
                  (sum, e) => sum + e.totalTime,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "$projectName — Total: ${totalHours.toStringAsFixed(2)} hrs",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: group.value.length,
                      itemBuilder: (context, idx) {
                        final entry = group.value[idx];
                        final dateLabel = DateFormat(
                          'MMM dd, yyyy',
                        ).format(entry.date);
                        return ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: Colors.deepPurple,
                          ),
                          title: Text(
                            "${entry.totalTime.toStringAsFixed(2)} hrs — ${getTaskNameById(context, entry.taskId)}",
                          ),
                          subtitle: Text(dateLabel),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
        );
      },
    );
  }

  String getProjectNameById(BuildContext context, String projectId) {
    final project = Provider.of<TimeEntryProvider>(
      context,
      listen: false,
    ).projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => Project(id: '', name: 'Unknown'),
    );
    return project.name;
  }

  String getTaskNameById(BuildContext context, String taskId) {
    final task = Provider.of<TimeEntryProvider>(
      context,
      listen: false,
    ).tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => Task(id: '', name: '—'),
    );
    return task.name;
  }
}
