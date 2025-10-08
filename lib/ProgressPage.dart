import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'user.dart';

class Progresspage extends StatefulWidget {
  final User currentUser;

  const Progresspage({super.key, required this.currentUser});

  @override
  State<Progresspage> createState() => _ProgresspageState();
}

class _ProgresspageState extends State<Progresspage> {
  StreamSubscription<PedestrianStatus>? _pedestrianSubscription;
  Timer? _stepTimer;
  Timer? _sessionTimer;

  String _status = "stopped";
  int _steps = 0;
  int _todaySteps = 0;

  bool _isWalking = false;
  bool _isInitialized = false;
  bool _isPermissionGranted = false;
  bool _isLoading = false;

  Random _random = Random();
  DateTime? _walkingStartTime;
  int _currentWalkingSession = 0;
  double _walkingPace = 1.0;
  int _consecutiveSteps = 0;

  double _calories = 0;
  double _distance = 0;
  int _dailyGoal = 1000;

  List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _pedestrianSubscription?.cancel();
    _stepTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final status = await Permission.activityRecognition.request();
    setState(() {
      _isPermissionGranted = status == PermissionStatus.granted;
    });

    if (_isPermissionGranted) {
      await _initializeApp();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeApp() async {
    await _loadDailyData();
    await _loadTodaySteps();
    await _setupMovementDetection();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _setupMovementDetection() async {
    try {
      _pedestrianSubscription = Pedometer.pedestrianStatusStream.listen((
        PedestrianStatus event,
      ) {
        _handleMovementChange(event.status);
      });
    } catch (e) {
      print("Error in pedestrian Status stream :$e");
    }
  }

  void _handleMovementChange(String status) {
    setState(() {
      _status = status;
    });
    if (status == "walking" && !_isWalking) {
      _startWalkingSession();
    } else if (status == "stopped" && _isWalking) {
      _stopWalkingSession();
    }
  }

  void _startWalkingSession() {
    _isWalking = true;
    _walkingStartTime = DateTime.now();
    _currentWalkingSession++;
    _walkingPace = 0.85 + (_random.nextDouble() * 0.3);
    _consecutiveSteps = 0;
    _startStepCounting();
  }

  void _stopWalkingSession() {
    _isWalking = false;
    _walkingStartTime = null;
    _stepTimer?.cancel();
    _sessionTimer?.cancel();
    _stepTimer = null;
    _sessionTimer = null;
  }

  void _startStepCounting() {
    _stepTimer?.cancel();
    int baseInterval = (600 / _walkingPace).round();
    _stepTimer = Timer.periodic(Duration(milliseconds: baseInterval), (timer) {
      if (!_isWalking) {
        timer.cancel();
        return;
      }

      double stepChance = _calculateStepProbability();
      if (_random.nextDouble() < stepChance) {
        setState(() {
          _steps++;
          _consecutiveSteps++;
          _calculateMetrics();
        });
        _saveSteps();
      }

      if (_consecutiveSteps > 0 && _consecutiveSteps % 20 == 0) {
        double adjustment = 0.95 + (_random.nextDouble() * 0.1);
        _walkingPace = (_walkingPace * adjustment).clamp(0.7, 1.3);
      }
    });

    _startSessionPatterns();
  }

  double _calculateStepProbability() {
    double baseProbability = 0.92;
    if (_consecutiveSteps < 5) baseProbability *= 0.8;
    double randomVariation = 0.95 + (_random.nextDouble() * 0.1);
    return (baseProbability * randomVariation).clamp(0.0, 1.0);
  }

  void _startSessionPatterns() {
    _sessionTimer = Timer.periodic(
      Duration(seconds: 15 + _random.nextInt(30)),
      (timer) {
        if (!_isWalking) {
          timer.cancel();
          return;
        }
        if (_random.nextDouble() < 0.2) {
          _stepTimer?.cancel();
          Timer(Duration(seconds: 1 + _random.nextInt(3)), () {
            if (_isWalking) {
              _startStepCounting();
            }
          });
        }
      },
    );
  }

  void _calculateMetrics() {
    _calories = _steps * 0.04;
    _distance = (_steps * 0.762) / 1000;
  }

  String _getDateKey() {
    return "${widget.currentUser.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
  }

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    final lastDate = prefs.getString('lastDate_${widget.currentUser.id}') ?? '';

    if (lastDate == today) {
      setState(() {
        _todaySteps = prefs.getInt('steps_$today') ?? 0;
        _steps = _todaySteps;
      });
    } else {
      setState(() {
        _todaySteps = 0;
        _steps = 0;
      });
      await prefs.setString('lastDate_${widget.currentUser.id}', today);
      await prefs.setInt('steps_$today', 0);
    }
    _calculateMetrics();
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    await prefs.setInt('steps_$today', _steps);
    await prefs.setString('lastDate_${widget.currentUser.id}', today);
  }

  Future<void> _loadDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('dailyGoal_${widget.currentUser.id}') ?? 1000;
    });
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> weekData = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr =
          "${widget.currentUser.id}_${DateFormat('yyyy-MM-dd').format(date)}";
      final steps = prefs.getInt('steps_$dateStr') ?? 0;

      weekData.add({
        'date': date,
        'steps': steps,
        'day': DateFormat('E').format(date),
      });
    }

    setState(() {
      _weeklyData = weekData;
    });
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _dailyGoal.toString());
        return AlertDialog(
          title: Text("Set Daily Goal"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Daily Steps Goal"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newGoal = int.tryParse(controller.text) ?? 1000;
                setState(() {
                  _dailyGoal = newGoal;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(
                  'dailyGoal_${widget.currentUser.id}',
                  newGoal,
                );
                Navigator.pop(context);
              },
              child: Text("Set Goal"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _dailyGoal > 0 ? _steps / _dailyGoal : 0.0;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288a52)),
              ),
            )
          : !_isPermissionGranted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 100,
                    color: Color(0xFF288a52),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Permission Required",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF288a52),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Please grant activity recognition permission to use the step counter.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _checkPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF288a52),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      "Grant Permission",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    child: Text(
                      "Open Settings",
                      style: TextStyle(fontSize: 16, color: Color(0xFF288a52)),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF288a52), Colors.green[300]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 0.5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Icon(
                                  size: 50,
                                  color: Colors.white,
                                  _status == 'walking'
                                      ? Icons.directions_walk
                                      : Icons.accessibility_new,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "$_steps",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "of $_dailyGoal steps",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _status == 'walking'
                                ? Colors.black
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _status == 'walking' ? 'Walking' : 'Stopped',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStateCard(
                        icon: Icons.local_fire_department,
                        value: _calories.toStringAsFixed(1),
                        unit: 'cal',
                        color: Colors.orange,
                      ),
                      _buildStateCard(
                        icon: Icons.straighten,
                        value: _distance.toStringAsFixed(2),
                        unit: 'km',
                        color: Colors.purple,
                      ),
                      _buildStateCard(
                        icon: Icons.timer,
                        value: (_steps * 0.008).toStringAsFixed(0),
                        unit: 'min',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Weekly Activity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _weeklyData.map((data) {
                            final height = (data['steps'] / _dailyGoal * 100)
                                .clamp(10.0, 100.0);

                            final isToday =
                                DateFormat('yyyy-MM-dd').format(data['date']) ==
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            return Column(
                              children: [
                                Container(
                                  width: 35,
                                  height: height.toDouble(),
                                  decoration: BoxDecoration(
                                    gradient: isToday
                                        ? LinearGradient(
                                            colors: [
                                              Colors.green[400]!,
                                              Colors.green[600]!,
                                            ],
                                          )
                                        : null,
                                    color: !isToday ? Colors.grey[300] : null,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  data['day'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
