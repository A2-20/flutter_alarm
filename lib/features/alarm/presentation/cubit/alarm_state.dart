import 'package:equatable/equatable.dart';
import '../../data/alarm_model.dart';

enum AlarmStatus { initial, loading, success, failure }

class AlarmState extends Equatable {
  final AlarmStatus status;
  final List<AlarmModel> alarms;
  final String? errorMessage;

  const AlarmState({
    this.status = AlarmStatus.initial,
    this.alarms = const [],
    this.errorMessage,
  });

  AlarmState copyWith({
    AlarmStatus? status,
    List<AlarmModel>? alarms,
    String? errorMessage,
  }) {
    return AlarmState(
      status: status ?? this.status,
      alarms: alarms ?? this.alarms,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, alarms, errorMessage];
}
