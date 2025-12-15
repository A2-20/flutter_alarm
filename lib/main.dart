import 'package:flutter/material.dart';
import 'app.dart';
import 'features/alarm/alarm_injection_container.dart'; // Import your DI file

void main() {
  setupAlarmDependencies();
  // Initialize notification service if needed


  runApp(const AlarmApp());
}