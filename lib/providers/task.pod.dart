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
    Supabase.instance.client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('priority', ascending: false)
        .listen((event) {
          // Logger().wtf(event);
          state =
              AsyncValue.data(event.map((e) => TaskDto.fromJson(e)).toList());
        });
    return [];
    // Supabase.instance.client.realtime.channel('public:tasks').on(
    //   RealtimeListenTypes.postgresChanges,
    //   ChannelFilter(
    //     event: 'INSERT',
    //     schema: 'public',
    //     table: 'tasks',
    //   ),
    //   (payload, [supaRef]) {
    //     Logger().wtf(payload);
    //   },
    // ).subscribe();

    // final currentList = await Supabase.instance.client.rest
    //     .from(Consts.tableTasks)
    //     .select<PostgrestList>()
    //     .eq(
    //       Consts.tableTasksColumnIsComplete,
    //       false,
    //     )
    //     .order(
    //       Consts.tableTasksColumnPriority,
    //       ascending: false,
    //     );

    // final parsedData = currentList.map((e) => TaskDto.fromJson(e)).toList();

    // return parsedData;
  }

  Future<IsOperationSuccess> addTask(TaskDto task) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tableTasks).insert(
        {
          Consts.tableTasksColumnData: task.data,
        },
      );
      // ref.invalidateSelf();
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }

  Future<IsOperationSuccess> deleteTask(String taskId) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tableTasks).delete().eq(
            Consts.tableTasksColumnId,
            taskId,
          );
      ref.invalidateSelf();
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }

  Future<IsOperationSuccess> completeTask(String taskId) async {
    try {
      await Supabase.instance.client.rest.from(Consts.tableTasks).update({
        Consts.tableTasksColumnIsComplete: true,
      }).eq(
        Consts.tableTasksColumnId,
        taskId,
      );
      // ref.invalidateSelf();
      return true;
    } catch (e, s) {
      Consts.logger.e(this, e, s);
      return false;
    }
  }
}
