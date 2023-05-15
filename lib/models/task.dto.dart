import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.dto.freezed.dart';
part 'task.dto.g.dart';

@freezed
class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String data,
    @JsonKey(name: 'is_complete') required bool isComplete,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required int priority,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
}
