import 'dart:math';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:intellitask/providers/task.pod.dart';

class IntelliTaskApp extends ConsumerWidget {
  const IntelliTaskApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: Consts.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      builder: BotToastInit(),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends HookConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, ref) {
    final taskListPod = ref.watch(taskListNotifierProvider);
    final showTextBox = useState(false);
    final textController = useTextEditingController();
    final onSubmit = useCallback(
      () async {
        if (textController.text.isEmpty) {
          BotToast.showSimpleNotification(
            title: 'Empty task...',
            align: Alignment.center,
            hideCloseButton: true,
          );
          return;
        }

        final result =
            await ref.read(taskListNotifierProvider.notifier).addTask(
                  TaskDto(
                    id: Random().nextInt(9999).toString(),
                    data: textController.text,
                    priority: Random().nextInt(9999),
                    isComplete: Random().nextBool(),
                    createdAt: DateTime.now(),
                  ),
                );
        if (result) {
          textController.clear();
        } else {
          BotToast.showSimpleNotification(
            title: 'Error adding task',
            align: Alignment.center,
            hideCloseButton: true,
          );
        }
      },
      [textController.text],
    );

    return Scaffold(
      body: Stack(
        children: [
          ImplicitlyAnimatedList<TaskDto>(
            items: taskListPod.valueOrNull ?? [],
            areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
            itemBuilder: (context, anim, item, index) => SizeTransition(
              sizeFactor: anim,
              child: _TaskCard(task: item),
            ),
            removeItemBuilder: (context, anim, oldItem) => SizeTransition(
              sizeFactor: anim,
              child: _TaskCard(task: oldItem),
            ),
          ),
          AnimatedPositioned(
            curve: Consts.defaultAnimationCurve,
            duration: Consts.defaultAnimationDuration,
            bottom: showTextBox.value ? 0 : -200,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.94),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  onSubmitted: (value) => onSubmit(),
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    filled: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        onPressed: () => showTextBox.value = !showTextBox.value,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        onPressed: () => onSubmit(),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            curve: Consts.defaultAnimationCurve,
            duration: Consts.defaultAnimationDuration,
            bottom: showTextBox.value ? -200 : 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => showTextBox.value = !showTextBox.value,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({
    required this.task,
  });

  final TaskDto task;

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {},
          confirmDismiss: (direction) {
            if (direction == DismissDirection.startToEnd) {
              return ref
                  .read(
                    taskListNotifierProvider.notifier,
                  )
                  .deleteTask(task.id);
            } else if (direction == DismissDirection.endToStart) {
              return ref
                  .read(
                    taskListNotifierProvider.notifier,
                  )
                  .completeTask(task.id);
            }
            return Future.value(false);
          },
          background: const ColoredBox(
            color: Color.fromARGB(210, 134, 0, 0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.delete),
                SizedBox(width: 10),
                Text(
                  'delete',
                  textScaleFactor: 1.4,
                ),
              ],
            ),
          ),
          secondaryBackground: const ColoredBox(
            color: Color.fromARGB(255, 0, 148, 62),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'complete',
                  textScaleFactor: 1.4,
                ),
                SizedBox(width: 10),
                Icon(Icons.check),
                SizedBox(width: 10),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(task.data),
            ),
          ),
        ),
      ),
    );
  }
}
