import 'dart:async';

import 'package:intellitask/core/consts.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'task.pod.g.dart';

typedef IsOperationSuccess = bool;

@Riverpod(dependencies: [])
Stream<Iterable<TaskDto>> _taskListStream(_TaskListStreamRef ref) async* {
  final result = Supabase.instance.client
      .from(Consts.tblTasks)
      .stream(primaryKey: [Consts.tblTasksColId])
      .eq(
        Consts.tblTasksColIsComplete,
        false,
      )
      .order(
        Consts.tblTasksColPriority,
        ascending: false,
      );

  await for (final event in result) {
    yield event.map((e) => TaskDto.fromJson(e));
  }
}

@Riverpod(dependencies: [_taskListStream])
class TaskListNotifier extends _$TaskListNotifier {
  @override
  FutureOr<List<TaskDto>> build() async {
    state = const AsyncLoading();

    final data = await ref.watch(_taskListStreamProvider.future);

    return data.toList();
  }

  Future<IsOperationSuccess> addTask(String task) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tblTasks).insert(
        {
          Consts.tblTasksColData: task,
        },
      );
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }

  Future<IsOperationSuccess> deleteTask(String taskId) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tblTasks).delete().eq(
            Consts.tblTasksColId,
            taskId,
          );
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }

  Future<IsOperationSuccess> completeTask(String taskId) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tblTasks).update({
        Consts.tblTasksColIsComplete: true,
      }).eq(
        Consts.tblTasksColId,
        taskId,
      );
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }
}
