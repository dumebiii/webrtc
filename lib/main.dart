import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webrtc/app/app.bottomsheets.dart';
import 'package:webrtc/app/app.dialogs.dart';
import 'package:webrtc/app/app.locator.dart';
import 'package:webrtc/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
