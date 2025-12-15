import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/alarm_repository.dart';
import '../../data/alarm_model.dart';

import 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final AlarmRepository _alarmRepository;

  AlarmCubit(this._alarmRepository) : super(const AlarmState());

  Future<void> loadAlarms() async {
    emit(state.copyWith(status: AlarmStatus.loading));
    try {
      final alarms = await _alarmRepository.getAlarms();
      emit(state.copyWith(status: AlarmStatus.success, alarms: alarms));
    } catch (e) {
      emit(
        state.copyWith(status: AlarmStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      await _alarmRepository.addAlarm(alarm);
      await _scheduleAlarm(alarm);
      await loadAlarms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      await _alarmRepository.updateAlarm(alarm);
      await _cancelAlarm(alarm);
      if (alarm.isActive) {
        await _scheduleAlarm(alarm);
      }
      await loadAlarms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      final alarm = state.alarms.firstWhere((a) => a.id == id);
      await _alarmRepository.deleteAlarm(id);
      await _cancelAlarm(alarm);
      await loadAlarms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> toggleAlarm(int id) async {
    try {
      final alarm = state.alarms.firstWhere((a) => a.id == id);
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);

      await _alarmRepository.updateAlarm(updatedAlarm);

      if (updatedAlarm.isActive) {
        await _scheduleAlarm(updatedAlarm);
      } else {
        await _cancelAlarm(updatedAlarm);
      }

      await loadAlarms();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _scheduleAlarm(AlarmModel alarm) async {
    // Implementation depends on your notification service
    // This is a placeholder for the actual scheduling logic
  }

  Future<void> _cancelAlarm(AlarmModel alarm) async {
    // Implementation depends on your notification service
    // This is a placeholder for the actual cancellation logic
  }
}
