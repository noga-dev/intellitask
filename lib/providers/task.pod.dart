import 'package:intellitask/core/consts.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'task.pod.g.dart';

typedef IsOperationSuccess = bool;

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  @override
  FutureOr<List<TaskDto>> build() async {
    final currentList = await Supabase.instance.client.rest
        .from(Consts.tableTasks)
        .select<PostgrestList>();

    final parsedData = currentList.map((e) => TaskDto.fromJson(e)).toList();

    return parsedData;
  }

  Future<IsOperationSuccess> addTask(TaskDto task) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tableTasks).insert(
        {
          Consts.tableTasksColumnData: task.data,
        },
      );
      ref.invalidateSelf();
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }
}
