import 'alarm_model.dart';

abstract class AlarmRepository {
  Future<List<AlarmModel>> getAlarms();
  Future<void> addAlarm(AlarmModel alarm);
  Future<void> updateAlarm(AlarmModel alarm);
  Future<void> deleteAlarm(int id);
}
