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
    @JsonKey(name: Consts.tblTasksColIsComplete) required bool isComplete,
    @JsonKey(name: Consts.tblTasksColCreatedAt) required DateTime createdAt,
  }) = _TaskDto;

  factory TaskDto.empty() => TaskDto(
        id: '',
        data: '',
        priority: 0,
        isComplete: false,
        createdAt: DateTime.now(),
      );

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
}
