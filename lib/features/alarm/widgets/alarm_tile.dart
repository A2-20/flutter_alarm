import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/alarm_model.dart';
import '../presentation/cubit/alarm_cubit.dart';

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final bool isFirstOfDay;

  const AlarmTile({
    super.key,
    required this.alarm,
    this.isFirstOfDay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: _getTileColor(alarm.isActive),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _getGradientColors(alarm.isActive),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _navigateToEdit(context),
          onLongPress: () => _showDeleteDialog(context),
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Time Section
                _buildTimeSection(),

                const Spacer(),

                // Alarm Details
                _buildDetailsSection(),

                const SizedBox(width: 16),

                // Toggle Switch
                _buildToggleSwitch(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        Text(
          DateFormat('HH:mm').format(alarm.time),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: alarm.isActive ? Colors.white : Colors.grey[400],
            fontFamily: 'RobotoMono',
            letterSpacing: -0.5,
          ),
        ),

        // AMPM
        Text(
          DateFormat('a').format(alarm.time).toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: alarm.isActive ? Colors.white.withOpacity(0.7) : Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              Icons.alarm,
              size: 14,
              color: alarm.isActive ? Colors.white.withOpacity(0.8) : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              alarm.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: alarm.isActive ? Colors.white : Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Days and sound
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // if (alarm.repeatDays.isNotEmpty)
            //   _buildChip(
            //     _getRepeatDaysText(),
            //     Icons.repeat,
            //     alarm.isActive ? Colors.blue.withOpacity(0.2) : Colors.grey[800],
            //     alarm.isActive ? Colors.blue : Colors.grey[500],
            //   ),
            //
            // _buildChip(
            //   alarm.sound,
            //   Icons.volume_up,
            //   alarm.isActive ? Colors.purple.withOpacity(0.2) : Colors.grey[800],
            //   alarm.isActive ? Colors.purple : Colors.grey[500],
            // ),
            //
            // if (alarm.isVibrate)
            //   _buildChip(
            //     'Vibrate',
            //     Icons.vibration,
            //     alarm.isActive ? Colors.green.withOpacity(0.2) : Colors.grey[800],
            //     alarm.isActive ? Colors.green : Colors.grey[500],
            //   ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(BuildContext context) {
    return Transform.scale(
      scale: 1.2,
      child: Switch.adaptive(
        value: alarm.isActive,
        onChanged: (value) {
          context.read<AlarmCubit>().toggleAlarm(alarm.id);
        },
        activeColor: Colors.blue,
        activeTrackColor: Colors.blue.withOpacity(0.3),
        inactiveThumbColor: Colors.grey[600],
        inactiveTrackColor: Colors.grey[800],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildChip(String text, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: alarm.isActive ? Colors.white.withOpacity(0.9) : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Warning icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                size: 30,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'Delete Alarm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'Are you sure you want to delete "${alarm.label}" alarm?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.read<AlarmCubit>().deleteAlarm(alarm.id);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    // ستنفذ لاحقاً
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${alarm.label}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getRepeatDaysText() {
    if (alarm.repeatDays.isEmpty) return 'Once';

    final daysMap = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };

    final dayNames = alarm.repeatDays
        .map((day) => daysMap[day.toString().split('.').last.toLowerCase()] ?? '')
        .where((day) => day.isNotEmpty)
        .toList();

    if (dayNames.length >= 5) return 'Daily';
    if (dayNames.isNotEmpty) return dayNames.join(', ');

    return 'Once';
  }

  List<Color> _getGradientColors(bool isActive) {
    if (isActive) {
      return [
        Colors.blue.withOpacity(0.15),
        Colors.purple.withOpacity(0.15),
      ];
    } else {
      return [
        Colors.grey[850]!,
        Colors.grey[900]!,
      ];
    }
  }

  Color _getTileColor(bool isActive) {
    return isActive
        ? Colors.blue.withOpacity(0.1)
        : Colors.grey[850]!;
  }
}