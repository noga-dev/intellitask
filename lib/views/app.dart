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
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final autoScrollController = useMemoized(() => AutoScrollController());
    final animController = useAnimationController(
      duration: Consts.defaultAnimationDuration * 2,
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
            child: ListView.builder(
              key: listKey,
              controller: autoScrollController,
              itemCount: taskListPod.value?.length ?? 0,
              itemBuilder: (context, index) {
                return ScaleTransition(
                  scale: Tween(
                    begin: 0.0,
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
                );
              },
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
          padding: const EdgeInsets.all(8.0),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.purple.shade900,
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
        ),
      ),
    );
  }

  SizeTransition _builder(Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: IgnorePointer(
        child: _TaskCard(
          index: -1,
          task: TaskDto.empty(),
        ),
      ),
    );
  }
}
