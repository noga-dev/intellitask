import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intellitask/core/consts.dart';

part 'task.dto.freezed.dart';
part 'task.dto.g.dart';

@freezed
class TaskDto with _$TaskDto {
  const factory TaskDto({
    @JsonKey(name: Consts.tblTasksColId) required String id,
    @JsonKey(name: Consts.tblTasksColData) required String data,
    @JsonKey(name: Consts.tblTasksColPriority) required int priority,
    @JsonKey(name: Consts.tblTasksColIsComplete) required bool isComplete,
    @JsonKey(name: Consts.tblTasksColIsValid) required bool isValid,
    @JsonKey(name: Consts.tblTasksColDueIn) required int dueIn,
    @JsonKey(name: Consts.tblTasksColCreatedAt) required DateTime createdAt,
  }) = _TaskDto;

  factory TaskDto.empty() => TaskDto(
        id: '',
        data: '',
        priority: 0,
        isComplete: false,
        createdAt: DateTime.now(),
        isValid: true,
        dueIn: 0,
      );

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
}
