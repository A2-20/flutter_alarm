import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/alarm_model.dart';
import '../cubit/alarm_cubit.dart';

class AddAlarmPage extends StatefulWidget {
  final AlarmCubit alarmCubit;
  final AlarmModel? existingAlarm; // للمرحلة التعديل إذا لزم

  const AddAlarmPage({
    super.key,
    required this.alarmCubit,
    this.existingAlarm,
  });

  @override
  State<AddAlarmPage> createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late TextEditingController _soundController;
  bool _isActive = true;
  bool _isVibrate = true;
  bool _snoozeEnabled = true;
  int _snoozeDuration = 5;
  final List<String> _repeatDays = [];
  final List<String> _soundOptions = [
    'Default',
    'Chime',
    'Beep',
    'Melody',
    'Nature',
    'Piano'
  ];

  @override
  void initState() {
    super.initState();

    // إذا كان تعديل منبه موجود
    if (widget.existingAlarm != null) {
      final alarm = widget.existingAlarm!;
      _selectedTime = TimeOfDay.fromDateTime(alarm.time);
      _labelController = TextEditingController(text: alarm.label);
      _isActive = alarm.isActive;
      _isVibrate = alarm.isVibrate;
      _snoozeEnabled = alarm.snoozeEnabled;
      _snoozeDuration = alarm.snoozeDuration;
      _repeatDays.addAll(alarm.repeatDays.map((e) => e.toString()));
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController(text: 'Alarm');
    }

    _soundController = TextEditingController(text: 'Default');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _soundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Picker Card
              _buildTimePickerCard(),

              const SizedBox(height: 32),

              // Label Input
              _buildLabelInput(),

              const SizedBox(height: 24),

              // Sound Selection
              _buildSoundSelection(),

              const SizedBox(height: 24),

              // Repeat Days
              _buildRepeatDaysSection(),

              const SizedBox(height: 24),

              // Snooze Settings
              _buildSnoozeSettings(),

              const SizedBox(height: 24),

              // Toggle Switches
              _buildToggleSwitches(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.existingAlarm != null ? 'Edit Alarm' : 'Add Alarm',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
            onPressed: _saveAlarm,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text(
              'Save',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerCard() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.2),
              Colors.purple.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Time
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 56,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'RobotoMono',
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Tap Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to change time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            children: [
              Icon(
                Icons.label_outline_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Label',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: _labelController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter alarm name...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            prefixIcon: Icon(
              Icons.edit_rounded,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Sound',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        DropdownButtonFormField<String>(
          value: _soundController.text,
          onChanged: (value) {
            setState(() {
              _soundController.text = value!;
            });
          },
          items: _soundOptions.map((sound) {
            return DropdownMenuItem(
              value: sound,
              child: Row(
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    color: Colors.grey[300],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sound,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          dropdownColor: Colors.grey[900],
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.grey[500],
            size: 28,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRepeatDaysSection() {
    final days = [
      {'label': 'Mon', 'value': 'monday'},
      {'label': 'Tue', 'value': 'tuesday'},
      {'label': 'Wed', 'value': 'wednesday'},
      {'label': 'Thu', 'value': 'thursday'},
      {'label': 'Fri', 'value': 'friday'},
      {'label': 'Sat', 'value': 'saturday'},
      {'label': 'Sun', 'value': 'sunday'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Repeat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: days.map((day) {
            final isSelected = _repeatDays.contains(day['value']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _repeatDays.remove(day['value']);
                  } else {
                    _repeatDays.add(day['value']!);
                  }
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : Colors.grey[700]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue : Colors.grey[400],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.blue,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Quick select buttons
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _repeatDays.clear();
                    _repeatDays.addAll(['monday', 'tuesday', 'wednesday', 'thursday', 'friday']);
                  });
                },
                icon: const Icon(Icons.work_rounded, size: 16),
                label: const Text('Weekdays'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[300],
                  side: BorderSide(color: Colors.grey[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _repeatDays.clear();
                    _repeatDays.addAll(['saturday', 'sunday']);
                  });
                },
                icon: const Icon(Icons.weekend_rounded, size: 16),
                label: const Text('Weekend'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[300],
                  side: BorderSide(color: Colors.grey[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSnoozeSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.snooze_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Snooze',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Snooze',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Allow snoozing when alarm rings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _snoozeEnabled,
                onChanged: (value) {
                  setState(() {
                    _snoozeEnabled = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),

          if (_snoozeEnabled) ...[
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Snooze Duration',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDurationButton(5),
                    _buildDurationButton(10),
                    _buildDurationButton(15),
                    _buildDurationButton(30),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationButton(int minutes) {
    final isSelected = _snoozeDuration == minutes;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _snoozeDuration = minutes;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.transparent,
            foregroundColor: isSelected ? Colors.blue : Colors.grey[400],
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey[700]!,
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text('$minutes min'),
        ),
      ),
    );
  }

  Widget _buildToggleSwitches() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            title: 'Active',
            subtitle: 'Enable or disable this alarm',
            icon: Icons.alarm_on_rounded,
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),

          const SizedBox(height: 20),

          _buildSettingRow(
            title: 'Vibration',
            subtitle: 'Enable vibration with alarm',
            icon: Icons.vibration_rounded,
            value: _isVibrate,
            onChanged: (value) => setState(() => _isVibrate = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),

        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          activeTrackColor: Colors.blue.withOpacity(0.3),
          inactiveThumbColor: Colors.grey[600],
          inactiveTrackColor: Colors.grey[800],
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.grey[900],
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: Colors.grey[800],
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: Colors.grey[800],
              dialHandColor: Colors.blue,
              dialBackgroundColor: Colors.grey[800],
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.grey[400],
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAlarm() async {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter alarm name'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final scheduledTime = alarmTime.isBefore(now)
        ? alarmTime.add(const Duration(days: 1))
        : alarmTime;

    final newAlarm = AlarmModel(
      id: widget.existingAlarm?.id ?? DateTime.now().millisecondsSinceEpoch,
      time: scheduledTime,
      isActive: _isActive,
      label: _labelController.text.trim(),
      isVibrate: _isVibrate,
      sound: _soundController.text,
      repeatDays: _repeatDays.map((e) => RepeatDays.values.firstWhere(
            (day) => day.toString().contains(e),
      )).toList(),
      snoozeEnabled: _snoozeEnabled,
      snoozeDuration: _snoozeDuration,
    );

    if (widget.existingAlarm != null) {
      widget.alarmCubit.updateAlarm(newAlarm);
    } else {
      widget.alarmCubit.addAlarm(newAlarm);
    }

    Navigator.pop(context);

    // إشعار بالنجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingAlarm != null
              ? 'Alarm updated successfully'
              : 'Alarm added successfully',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}