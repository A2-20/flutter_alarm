import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_model.dart';

class AlarmLocalDataSource {
  static const String _alarmsKey = 'ALARMS';

  Future<List<AlarmModel>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

    return alarmsJson
        .map((json) => AlarmModel.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms
        .map((alarm) => jsonEncode(alarm.toMap()))
        .toList();

    await prefs.setStringList(_alarmsKey, alarmsJson);
  }

  Future<int> getNextId() async {
    final alarms = await getAlarms();
    if (alarms.isEmpty) return 1;

    final maxId = alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
