import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'providers/project_task_provider.dart';
import 'screens/add_time_entry_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manage_projects_screen.dart';
import 'screens/manage_tasks_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();

  runApp(MyApp(localStorage: localStorage));
}

class MyApp extends StatelessWidget {
  final LocalStorage localStorage;

  const MyApp({Key? key, required this.localStorage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeEntryProvider(localStorage)),
      ],
      child: MaterialApp(
        title: 'Project Time Tracker',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/manage_projects': (context) => ManageProjectsScreen(),
          '/manage_tasks': (context) => ManageTasksScreen(),
          // Main entry point, HomeScreen
          // '/manage_categories': (context) =>
          //     CategoryManagementScreen(), // Route for managing categories
          // '/manage_tags': (context) =>
          //     TagManagementScreen(), // Route for managing tags
        },
        // Removed 'home:' since 'initialRoute' is used to define the home route
      ),
    );
  }
}
