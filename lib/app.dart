// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/alarm/data/alarm_local_datasource.dart';
import 'features/alarm/data/alarm_repository.dart';
import 'features/alarm/data/alarm_repository_impl.dart';
import 'features/alarm/presentation/cubit/alarm_cubit.dart';
import 'features/alarm/presentation/pages/add_alarm_page.dart';
import 'features/alarm/presentation/pages/alarm_page.dart';

// lib/app.dart
class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localDataSource = AlarmLocalDataSource();
    final AlarmRepository repository = AlarmRepositoryImpl(localDataSource);
    final alarmCubit = AlarmCubit(repository)..loadAlarms();

    return BlocProvider(
      create: (context) => alarmCubit,
      child: MaterialApp(
        title: 'Alarm App',
        initialRoute: '/',
        routes: {
          '/': (context) =>  AlarmPage(alarmCubit:alarmCubit ,),
          '/add': (context) =>  AddAlarmPage(alarmCubit: alarmCubit,),
        },
      ),
    );
  }
}