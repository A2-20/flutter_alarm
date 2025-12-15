import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/alarm_model.dart';
import '../../widgets/alarm_tile.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import 'add_alarm_page.dart';

class AlarmPage extends StatefulWidget {
  final AlarmCubit alarmCubit;

  const AlarmPage({super.key, required this.alarmCubit,});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AlarmCubit, AlarmState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(),

              // Content based on state
              _buildContent(context, state),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 180,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alarms',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            BlocBuilder<AlarmCubit, AlarmState>(
              builder: (context, state) {
                final activeAlarms = state.alarms
                    .where((alarm) => alarm.isActive)
                    .length;
                final totalAlarms = state.alarms.length;

                return Text(
                  '$activeAlarms of $totalAlarms active',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: const SizedBox(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort_rounded, size: 24),
          onPressed: () => _showSortOptions(context),
          tooltip: 'Sort alarms',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, size: 24),
          onPressed: () => _showMoreOptions(context),
          tooltip: 'More options',
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AlarmState state) {
    if (state.status == AlarmStatus.loading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.blue,
                  backgroundColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading alarms...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.alarms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.alarm_off_rounded,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No alarms set',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add your first alarm to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddAlarm(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Add Alarm',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group alarms by time (morning, afternoon, evening, night)
    final alarmsByTime = _groupAlarmsByTime(state.alarms);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) {
            return _buildNextAlarmCard(context, state.alarms);
          }

          final timeGroupIndex = index - 1;
          final timeGroups = alarmsByTime.entries.toList();

          if (timeGroupIndex >= timeGroups.length) {
            return null;
          }

          final timeGroup = timeGroups[timeGroupIndex];
          return _buildTimeGroupSection(
            context,
            timeGroup.key,
            timeGroup.value,
          );
        },
        childCount: alarmsByTime.length + 1,
      ),
    );
  }

  Widget _buildNextAlarmCard(BuildContext context, List<AlarmModel> alarms) {
    final now = DateTime.now();
    final nextAlarm = alarms
        .where((alarm) => alarm.isActive)
        .where((alarm) => alarm.time.isAfter(now))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    if (nextAlarm.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.alarm_off_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No upcoming alarms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'All alarms are inactive or in the past',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final next = nextAlarm.first;
    final timeUntil = next.time.difference(now);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm_on_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Alarm',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      next.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(next.time),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'RobotoMono',
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
                      'In ${_formatDuration(timeUntil)}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _calculateProgress(now, next.time),
                      backgroundColor: Colors.grey[800],
                      color: Colors.blue,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => context.read<AlarmCubit>().toggleAlarm(next.id),
                icon: Icon(
                  Icons.pause_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
                tooltip: 'Disable next alarm',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGroupSection(
      BuildContext context,
      String title,
      List<AlarmModel> alarms,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        ...alarms.map((alarm) => AlarmTile(alarm: alarm)).toList(),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddAlarm(context),
      icon: const Icon(Icons.add_rounded, size: 24),
      label: const Text(
        'Add',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Sort Alarms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 24),
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSortOption(
              context,
              'Time (Earliest First)',
              Icons.access_time_rounded,
                  () {
                // Implement sort by time
                Navigator.pop(context);
              },
            ),
            _buildSortOption(
              context,
              'Recently Added',
              Icons.new_releases_rounded,
                  () {
                // Implement sort by date added
                Navigator.pop(context);
              },
            ),
            _buildSortOption(
              context,
              'Label (A to Z)',
              Icons.sort_by_alpha_rounded,
                  () {
                // Implement sort by label
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey[300], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildMoreOption(
              context,
              'Settings',
              Icons.settings_rounded,
                  () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            _buildMoreOption(
              context,
              'Delete All Inactive',
              Icons.delete_sweep_rounded,
                  () {
                Navigator.pop(context);
                _showDeleteInactiveDialog(context);
              },
            ),
            _buildMoreOption(
              context,
              'Export Alarms',
              Icons.upload_rounded,
                  () {
                Navigator.pop(context);
                // Implement export
              },
            ),
            _buildMoreOption(
              context,
              'About',
              Icons.info_rounded,
                  () {
                Navigator.pop(context);
                // Show about dialog
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey[300], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  void _showDeleteInactiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Inactive Alarms',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'This will delete all inactive alarms. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement delete inactive alarms
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlarmPage(
          alarmCubit: context.read<AlarmCubit>(),
        ),
      ),
    );
  }

  // Helper methods
  Map<String, List<AlarmModel>> _groupAlarmsByTime(List<AlarmModel> alarms) {
    final groups = <String, List<AlarmModel>>{
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
    };

    for (final alarm in alarms) {
      final hour = alarm.time.hour;
      if (hour >= 5 && hour < 12) {
        groups['Morning']!.add(alarm);
      } else if (hour >= 12 && hour < 17) {
        groups['Afternoon']!.add(alarm);
      } else if (hour >= 17 && hour < 22) {
        groups['Evening']!.add(alarm);
      } else {
        groups['Night']!.add(alarm);
      }
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);

    // Sort alarms within each group by time
    for (final group in groups.values) {
      group.sort((a, b) => a.time.compareTo(b.time));
    }

    return groups;
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Less than a minute';
    }
  }

  double _calculateProgress(DateTime now, DateTime alarmTime) {
    final totalHours = 24.0;
    final currentHour = now.hour + now.minute / 60.0;
    final alarmHour = alarmTime.hour + alarmTime.minute / 60.0;

    double hoursUntil = alarmHour - currentHour;
    if (hoursUntil < 0) hoursUntil += totalHours;

    return hoursUntil / totalHours;
  }
}