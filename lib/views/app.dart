import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/core/styles.dart';
import 'package:intellitask/providers/theme.pod.dart';
import 'package:intellitask/views/home/home_screen.dart';

class IntelliTaskApp extends ConsumerWidget {
  const IntelliTaskApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: Consts.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: appThemeLight,
      darkTheme: appThemeDark,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      builder: BotToastInit(),
      home: const HomeScreen(),
    );
  }
}
