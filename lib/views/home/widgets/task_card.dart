import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/core/styles.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:intellitask/providers/task.pod.dart';
import 'package:timeago/timeago.dart' as timeago;

class TaskCard extends HookConsumerWidget {
  const TaskCard({
    super.key,
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
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: AppPaddings.defaultOffset,
          ),
          child: Center(
            child: Card(
              child: ClipRRect(
                borderRadius: defaultBorderRadius,
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
                    color: AppColors.error,
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
                  secondaryBackground: const ColoredBox(
                    color: AppColors.success,
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 320),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: (task.priority != 0 && task.isValid)
                              ? Icon(
                                  Icons.flag,
                                  color: _getPriorityColor(task.priority),
                                )
                              : const CircularProgressIndicator.adaptive(),
                          title: Text(
                            task.data,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: HookBuilder(builder: (context) {
                            final timeRemaining = _useStateOnTimer(
                              callback: () {
                                return task.createdAt
                                    .add(
                                      Duration(
                                        minutes: task.dueIn,
                                      ),
                                    )
                                    .difference(DateTime.now());
                              },
                              interval: const Duration(seconds: 1),
                            );

                            return Text(
                              timeago.format(
                                DateTime.now().add(
                                  timeRemaining,
                                ),
                                allowFromNow: true,
                              ),
                              style: TextStyle(
                                color: timeRemaining.inMinutes > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );
                          }),
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

  Color _getPriorityColor(int value) {
    if (value == 0) {
      return Colors.grey;
    }

    return Color.lerp(Colors.green, Colors.red, value / 32765.0) ?? Colors.grey;
  }

  void _useInterval(VoidCallback callback, Duration delay) {
    final savedCallback = useRef(callback);
    // ignore: cascade_invocations
    savedCallback.value = callback;

    useEffect(
      () {
        final timer = Timer.periodic(delay, (_) => savedCallback.value());
        return timer.cancel;
      },
      [delay],
    );
  }

  R _useStateOnTimer<R>({
    required R Function() callback,
    required Duration interval,
  }) {
    final counter = useState<R>(callback());

    _useInterval(
      () => counter.value = callback(),
      interval,
    );

    return counter.value;
  }
}
