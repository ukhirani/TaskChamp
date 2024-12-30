import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_widgets.dart';

class PriorityToolsWidget extends StatefulWidget {
  const PriorityToolsWidget({Key? key}) : super(key: key);

  @override
  _PriorityToolsWidgetState createState() => _PriorityToolsWidgetState();
}

class _PriorityToolsWidgetState extends State<PriorityToolsWidget> {
  // Stopwatch variables
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _stopwatchDisplay = '00:00:00';

  // Pomodoro Timer variables
  int _pomodoroMinutes = 25;
  int _pomodoroSeconds = 0;
  bool _isPomodoroRunning = false;
  Timer? _pomodoroTimer;

  // Focus Timer variables
  int _focusMinutes = 0;
  int _focusSeconds = 0;
  bool _isFocusTimerRunning = false;
  Timer? _focusTimer;

  @override
  void dispose() {
    _timer?.cancel();
    _pomodoroTimer?.cancel();
    _focusTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _stopwatchDisplay = _formatStopwatch(_stopwatch.elapsed);
        });
      }
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _timer?.cancel();
    setState(() {
      _stopwatchDisplay = '00:00:00';
    });
  }

  String _formatStopwatch(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _startPomodoroTimer() {
    setState(() {
      _isPomodoroRunning = true;
    });
    _pomodoroTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_pomodoroSeconds > 0) {
            _pomodoroSeconds--;
          } else if (_pomodoroMinutes > 0) {
            _pomodoroMinutes--;
            _pomodoroSeconds = 59;
          } else {
            _pomodoroTimer?.cancel();
            _isPomodoroRunning = false;
            _showPomodoroCompletionDialog();
          }
        });
      }
    });
  }

  void _pausePomodoroTimer() {
    _pomodoroTimer?.cancel();
    setState(() {
      _isPomodoroRunning = false;
    });
  }

  void _resetPomodoroTimer() {
    _pomodoroTimer?.cancel();
    setState(() {
      _pomodoroMinutes = 25;
      _pomodoroSeconds = 0;
      _isPomodoroRunning = false;
    });
  }

  void _showPomodoroCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pomodoro Complete!'),
          content: Text('Your Pomodoro session has ended. Take a short break.'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetPomodoroTimer();
              },
            ),
          ],
        );
      },
    );
  }

  void _startFocusTimer() {
    setState(() {
      _isFocusTimerRunning = true;
    });
    _focusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_focusSeconds < 59) {
            _focusSeconds++;
          } else {
            _focusMinutes++;
            _focusSeconds = 0;
          }
        });
      }
    });
  }

  Widget _buildTimerCard(
    BuildContext context, {
    required String title,
    required String display,
    required List<Widget> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            Text(
              display,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPomodoroTimerSection() {
    return _buildTimerCard(
      context,
      title: 'Pomodoro Timer',
      display:
          '$_pomodoroMinutes:${_pomodoroSeconds.toString().padLeft(2, '0')}',
      actions: [
        IconButton(
          icon: Icon(_isPomodoroRunning ? Icons.pause : Icons.play_arrow,
              color: _isPomodoroRunning ? Colors.orange : Colors.green),
          onPressed: () {
            _isPomodoroRunning ? _pausePomodoroTimer() : _startPomodoroTimer();
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.blue),
          onPressed: _resetPomodoroTimer,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stopwatch Section
            _buildTimerCard(
              context,
              title: 'Stopwatch',
              display: _stopwatchDisplay,
              actions: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: _stopwatch.isRunning ? null : _startStopwatch,
                ),
                IconButton(
                  icon: Icon(Icons.stop, color: Colors.red),
                  onPressed: _stopwatch.isRunning ? _stopStopwatch : null,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: _resetStopwatch,
                ),
              ],
            ),

            SizedBox(height: 16),

            // Pomodoro Timer Section
            _buildPomodoroTimerSection(),

            SizedBox(height: 16),

            // Focus Timer Section
            _buildTimerCard(
              context,
              title: 'Focus Timer',
              display:
                  '$_focusMinutes:${_focusSeconds.toString().padLeft(2, '0')}',
              actions: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: _isFocusTimerRunning ? null : _startFocusTimer,
                ),
                IconButton(
                  icon: Icon(Icons.stop, color: Colors.red),
                  onPressed: _isFocusTimerRunning
                      ? () {
                          _focusTimer?.cancel();
                          setState(() {
                            _isFocusTimerRunning = false;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
