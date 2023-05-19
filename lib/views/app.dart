import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:intellitask/providers/task.pod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

const _kOffset = 72.0;

class IntelliTaskApp extends ConsumerWidget {
  const IntelliTaskApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: Consts.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0c111a),
        cardColor: const Color(0xFF121821),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
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
    final autoScrollController = useMemoized(() => AutoScrollController());
    final animController = useAnimationController(
      duration: Consts.defaultAnimationDuration * 4,
    );
    final textController = useTextEditingController();
    final prevTaskListVal = usePrevious(taskListPod);
    final isTextboxVisible = useState(false);
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
                  textController.text,
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
        isTextboxVisible.value = false;
      },
      [textController.text],
    );

    useEffect(() {
      // Timer.periodic(
      //   const Duration(milliseconds: 100),
      //   (Timer timer) {
      //     if (listItems.value.length >= (taskListPod.value?.length ?? 0)) {
      //       timer.cancel();
      //       return;
      //     }
      //     if (taskListPod.value == null) {
      //       return;
      //     }
      //     listItems.value = [
      //       ...listItems.value,
      //       taskListPod.value![listItems.value.length]
      //     ];
      //     listKey.currentState?.insertItem(
      //       listItems.value.length - 1,
      //       duration: Consts.defaultAnimationDuration,
      //     );
      //   },
      // );

      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (taskListPod.value != prevTaskListVal?.value &&
            (taskListPod.value?.length ?? 0) >
                (prevTaskListVal?.value?.length ?? 0)) {
          final newList = taskListPod.value ?? [];
          final item = newList.reduce((e1, e2) =>
              e1.createdAt.difference(e2.createdAt) > Duration.zero ? e1 : e2);
          animController.forward(from: 0.1);

          final index = taskListPod.value!.indexOf(item);

          autoScrollController.scrollToIndex(
            index,
            duration: Consts.defaultAnimationDuration,
            preferPosition: AutoScrollPosition.middle,
          );

          autoScrollController.highlight(index);
        }
      });

      return;
    }, [taskListPod.value]);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Consts.defaultAnimationDuration,
            bottom: isTextboxVisible.value ? _kOffset : 0,
            top: 0,
            left: 0,
            right: 0,
            // would be better to  use a listview builder here for performance
            // but calculating the scroll position for the gradient is a pita
            child: ListView.builder(
              controller: autoScrollController,
              itemCount: taskListPod.value?.length ?? 0,
              padding: const EdgeInsets.symmetric(vertical: _kOffset),
              itemBuilder: (context, index) => ScaleTransition(
                scale: Tween(
                  begin: 0.24,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animController,
                    curve: Interval(
                      0.0,
                      index / (taskListPod.value!.length),
                      curve: Curves.elasticIn,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(2, 0),
                    end: const Offset(0, 0),
                  ).animate(
                    CurvedAnimation(
                      parent: animController,
                      curve: Interval(
                        0.0,
                        index / (taskListPod.value!.length),
                        curve: Curves.elasticIn,
                      ),
                    ),
                  ),
                  child: AutoScrollTag(
                    controller: autoScrollController,
                    key: ValueKey(taskListPod.value![index].id),
                    index: index,
                    highlightColor: Colors.amber.withOpacity(.5),
                    child: _TaskCard(
                      task: taskListPod.value![index],
                      index: index,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            curve: Consts.defaultAnimationCurve,
            duration: Consts.defaultAnimationDuration,
            bottom: isTextboxVisible.value ? 0 : -_kOffset,
            left: 0,
            right: 0,
            child: FocusScope(
              canRequestFocus: isTextboxVisible.value,
              child: ColoredBox(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(.94),
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
                          onPressed: () =>
                              isTextboxVisible.value = !isTextboxVisible.value,
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
          ),
          AnimatedPositioned(
            curve: Consts.defaultAnimationCurve,
            duration: Consts.defaultAnimationDuration,
            bottom: isTextboxVisible.value ? -_kOffset : 20,
            right: 20,
            child: FocusScope(
              canRequestFocus: !isTextboxVisible.value,
              child: FloatingActionButton(
                onPressed: () =>
                    isTextboxVisible.value = !isTextboxVisible.value,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends HookConsumerWidget {
  const _TaskCard({
    required this.task,
    required this.index,
  });

  final TaskDto task;
  final int index;

  @override
  Widget build(BuildContext context, ref) {
    final animController = useAnimationController(
      duration: Consts.defaultAnimationDurationHalf,
      initialValue: 1,
    );

    return SizeTransition(
      sizeFactor: Tween(
        begin: 0.0,
        end: animController.value,
      ).animate(
        CurvedAnimation(
          parent: animController,
          curve: Curves.decelerate,
        ),
      ),
      child: FadeTransition(
        opacity: Tween(
          begin: 0.0,
          end: animController.value,
        ).animate(
          CurvedAnimation(
            parent: animController,
            curve: Curves.decelerate,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: _kOffset),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                child: Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {},
                  movementDuration: Consts.defaultAnimationDuration * 4,
                  resizeDuration: Consts.defaultAnimationDuration * 4,
                  confirmDismiss: (direction) async {
                    animController.reverse(from: 1);
                    if (direction == DismissDirection.startToEnd) {
                      await ref
                          .read(
                            taskListNotifierProvider.notifier,
                          )
                          .deleteTask(task.id);
                    } else if (direction == DismissDirection.endToStart) {
                      await ref
                          .read(
                            taskListNotifierProvider.notifier,
                          )
                          .completeTask(task.id);
                    }
                    return Future.value(false);
                  },
                  background: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const ColoredBox(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                  ),
                  secondaryBackground: const ColoredBox(
                    color: Colors.green,
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
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.flag,
                          color: _getCardColor(task.priority),
                        ),
                        title: Text(
                          task.data,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCardColor(int value) {
    double fraction = value / 32000.0;

    // Calculate the red, green, and blue components of the color.
    double red = 1.0 - fraction;
    double green = fraction;
    double blue = 0.0;

    // Create a new Color object with the calculated components.
    return Color.fromARGB(
        255, (red * 255).toInt(), (green * 255).toInt(), (blue * 255).toInt());
  }
}
