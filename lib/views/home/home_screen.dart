import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/core/styles.dart';
import 'package:intellitask/providers/task.pod.dart';
import 'package:intellitask/providers/theme.pod.dart';
import 'package:intellitask/views/home/widgets/task_card.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final taskListPod = ref.watch(taskListNotifierProvider);
    final taskList = taskListPod.valueOrNull ?? [];
    final prevTaskListVal = usePrevious(taskList) ?? [];
    final autoScrollController = useMemoized(() => AutoScrollController(), []);
    final textController = useTextEditingController();
    final isTextboxVisible = useState(false);
    final textFocusNode = useFocusNode();
    final fabFocusNode = useFocusNode();
    final animController = useAnimationController(
      duration: Consts.defaultAnimationDuration,
    );
    final onSubmit = useCallback(
      () async {
        if (textController.text.isEmpty) {
          BotToast.showSimpleNotification(
            title: 'Empty task?',
            align: Alignment.center,
            hideCloseButton: true,
            backgroundColor: AppColors.info,
          );
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            textFocusNode.requestFocus();
          });
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
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (isTextboxVisible.value) {
          textFocusNode.requestFocus();
        } else {
          fabFocusNode.nextFocus();
        }
      });
      return null;
    }, [isTextboxVisible.value]);

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (taskList != prevTaskListVal &&
            (taskList.length > (prevTaskListVal.length) ||
                (taskList.any((element) => element.priority == 0)) !=
                    (prevTaskListVal
                        .any((element) => element.priority == 0)))) {
          final newList = taskList;
          final item = newList.reduce((e1, e2) =>
              e1.createdAt.difference(e2.createdAt) > Duration.zero ? e1 : e2);
          animController.forward(from: 0.1);

          final index = taskList.indexOf(item);

          autoScrollController.scrollToIndex(
            index,
            duration: Consts.defaultAnimationDuration,
            preferPosition: AutoScrollPosition.middle,
          );

          autoScrollController.highlight(index);
        }
      });

      return;
    }, [
      taskList,
      taskList.where((element) => element.priority == 0).isNotEmpty,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          if (taskListPod.isLoading)
            const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          else if (taskList.isEmpty)
            const Center(
              child: Text(
                'No tasks yet',
              ),
            )
          else
            ListView.builder(
              controller: autoScrollController,
              itemCount: taskList.length,
              padding: const EdgeInsets.symmetric(
                  vertical: AppPaddings.defaultOffset),
              itemBuilder: (context, index) => ScaleTransition(
                scale: Tween(
                  begin: 0.24,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animController,
                    curve: Interval(
                      0.0,
                      index / (taskList.length),
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
                        index / (taskList.length),
                        curve: Curves.elasticIn,
                      ),
                    ),
                  ),
                  child: AutoScrollTag(
                    controller: autoScrollController,
                    key: ValueKey(taskList[index].id),
                    index: index,
                    highlightColor: AppColors.highlightColor,
                    child: TaskCard(
                      task: taskList[index],
                      index: index,
                    ),
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            curve: Consts.defaultAnimationCurve,
            duration: Consts.defaultAnimationDuration,
            bottom: isTextboxVisible.value ? 0 : -AppPaddings.defaultOffset,
            left: 0,
            right: 0,
            child: FocusTraversalGroup(
              descendantsAreFocusable: isTextboxVisible.value,
              descendantsAreTraversable: isTextboxVisible.value,
              child: ColoredBox(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(.9),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textController,
                    focusNode: textFocusNode,
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
            bottom: isTextboxVisible.value ? -AppPaddings.defaultOffset : 20,
            right: 20,
            child: FocusTraversalGroup(
              descendantsAreFocusable: !isTextboxVisible.value,
              descendantsAreTraversable: !isTextboxVisible.value,
              child: FloatingActionButton(
                focusNode: fabFocusNode,
                onPressed: () =>
                    isTextboxVisible.value = !isTextboxVisible.value,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox.square(
              dimension: 40,
              child: InkResponse(
                canRequestFocus: false,
                onTap: () =>
                    ref.read(themeNotifierProvider.notifier).toggleTheme(),
                child: AnimatedSwitcher(
                  duration: Consts.defaultAnimationDuration,
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween(
                      begin: const Offset(-5, -5),
                      end: const Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
                  child: ref.watch(themeNotifierProvider) == ThemeMode.light
                      ? const Icon(
                          key: ValueKey('light'),
                          Icons.brightness_3_sharp,
                        )
                      : const Icon(
                          key: ValueKey('dark'),
                          Icons.brightness_5_sharp,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
