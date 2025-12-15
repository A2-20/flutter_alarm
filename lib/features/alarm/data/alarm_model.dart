import 'package:equatable/equatable.dart';

enum RepeatDays {
  none,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  daily,
  weekdays,
  weekends,
}

class AlarmModel extends Equatable {
  final int id;
  final DateTime time;
  final bool isActive;
  final String label;
  final bool isVibrate;
  final String sound;
  final List<RepeatDays> repeatDays;
  final bool snoozeEnabled;
  final int snoozeDuration;

  const AlarmModel({
    required this.id,
    required this.time,
    this.isActive = true,
    this.label = 'Alarm',
    this.isVibrate = true,
    this.sound = 'Default',
    this.repeatDays = const [],
    this.snoozeEnabled = true,
    this.snoozeDuration = 5,
  });

  AlarmModel copyWith({
    int? id,
    DateTime? time,
    bool? isActive,
    String? label,
    bool? isVibrate,
    String? sound,
    List<RepeatDays>? repeatDays,
    bool? snoozeEnabled,
    int? snoozeDuration,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      isVibrate: isVibrate ?? this.isVibrate,
      sound: sound ?? this.sound,
      repeatDays: repeatDays ?? this.repeatDays,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'label': label,
      'isVibrate': isVibrate,
      'sound': sound,
      'repeatDays': repeatDays.map((e) => e.index).toList(),
      'snoozeEnabled': snoozeEnabled,
      'snoozeDuration': snoozeDuration,
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as int,
      time: DateTime.parse(map['time'] as String),
      isActive: map['isActive'] as bool,
      label: map['label'] as String,
      isVibrate: map['isVibrate'] as bool,
      sound: map['sound'] as String,
      repeatDays: (map['repeatDays'] as List)
          .map((e) => RepeatDays.values[e as int])
          .toList(),
      snoozeEnabled: map['snoozeEnabled'] as bool,
      snoozeDuration: map['snoozeDuration'] as int,
    );
  }

  @override
  List<Object?> get props => [
    id,
    time,
    isActive,
    label,
    isVibrate,
    sound,
    repeatDays,
    snoozeEnabled,
    snoozeDuration,
  ];
}
