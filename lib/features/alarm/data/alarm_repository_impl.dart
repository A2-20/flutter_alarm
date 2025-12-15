import 'alarm_repository.dart';
import 'alarm_model.dart';
import 'alarm_local_datasource.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDataSource _localDataSource;

  AlarmRepositoryImpl(this._localDataSource);

  @override
  Future<List<AlarmModel>> getAlarms() async {
    return await _localDataSource.getAlarms();
  }

  @override
  Future<void> addAlarm(AlarmModel alarm) async {
    final alarms = await _localDataSource.getAlarms();
    alarms.add(alarm);
    await _localDataSource.saveAlarms(alarms);
  }

  @override
  Future<void> updateAlarm(AlarmModel updatedAlarm) async {
    final alarms = await _localDataSource.getAlarms();
    final index = alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);

    if (index != -1) {
      alarms[index] = updatedAlarm;
      await _localDataSource.saveAlarms(alarms);
    }
  }

  @override
  Future<void> deleteAlarm(int id) async {
    final alarms = await _localDataSource.getAlarms();
    alarms.removeWhere((alarm) => alarm.id == id);
    await _localDataSource.saveAlarms(alarms);
  }
}
