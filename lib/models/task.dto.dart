import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intellitask/core/consts.dart';

part 'task.dto.freezed.dart';
part 'task.dto.g.dart';

@freezed
class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String data,
    required int priority,
    @JsonKey(name: Consts.tableTasksColumnIsComplete)
        required bool isComplete,
    @JsonKey(name: Consts.tableTasksColumnIsCreatedAt)
        required DateTime createdAt,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
}
