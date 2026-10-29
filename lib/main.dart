import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/boards/presentation/controllers/board_controller.dart';
import 'features/boards/presentation/screens/boards_dashboard_screen.dart';
import 'features/tasks/presentation/controllers/task_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Global Controllers via GetX Dependency Injection
  Get.put(ThemeController(), permanent: true);
  Get.put(BoardController(), permanent: true);
  Get.put(TaskController(), permanent: true);

  runApp(const TaskFlowProApp());
}

class TaskFlowProApp extends StatelessWidget {
  const TaskFlowProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
          () => GetMaterialApp(
        title: 'TaskFlow Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        home: const BoardsDashboardScreen(),
      ),
    );
  }
}