import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Exercise {
  final String name;
  final String type;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;

  Exercise({
    required this.name,
    required this.type,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }
}

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({Key? key}) : super(key: key);

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  late Future<List<Exercise>> _exercisesFuture;
  String _searchQuery = '';
  String _selectedMuscle = 'all';
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    _exercisesFuture = fetchExercises();
  }

  Future<List<Exercise>> fetchExercises() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/exercises'),
        headers: {'X-Api-Key': '3j/StfPd15B7doXTuxvgAg==IlrBfg6FTk1XYe9V'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception("Failed to Load exercises: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching exercises : $e");
    }
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      final matchesSearch =
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.muscle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.type.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMuscle =
          _selectedMuscle == 'all' || exercise.muscle == _selectedMuscle;
      final matchesDifficulty =
          _selectedDifficulty == 'all' ||
          exercise.difficulty == _selectedDifficulty;

      return matchesDifficulty && matchesMuscle && matchesSearch;
    }).toList();
  }

  List<String> _getUniqueDifficulties(List<Exercise> exercises) {
    final difficulties = exercises.map((e) => e.difficulty).toSet().toList();
    difficulties.sort();
    return ['all', ...difficulties];
  }

  List<String> _getUniqueMuscles(List<Exercise> exercises) {
    final muscles = exercises.map((e) => e.muscle).toSet().toList();
    muscles.sort();
    return ['all', ...muscles];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288a52)),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Error ${snapshot.error}",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _exercisesFuture = fetchExercises();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF288a52),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No exercises found", style: TextStyle(fontSize: 18)),
            );
          }

          final exercises = snapshot.data!;
          final filteredExercises = _filterExercises(exercises);
          final uniqueMuscles = _getUniqueMuscles(exercises);
          final uniqueDifficulties = _getUniqueDifficulties(exercises);

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF288a52),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search exercises...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Filter Chips
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedMuscle,
                            decoration: const InputDecoration(
                              labelText: "Muscle Group",
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: const Color(0xFF288a52),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            items: uniqueMuscles.map((muscle) {
                              return DropdownMenuItem(
                                value: muscle,
                                child: Text(
                                  muscle == 'all' ? 'All Muscles' : muscle,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMuscle = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: "Difficulty",
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: const Color(0xFF288a52),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            items: uniqueDifficulties.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(
                                  difficulty == 'all'
                                      ? 'All Levels'
                                      : difficulty,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Results Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text(
                      "${filteredExercises.length} exercises found",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Exercises List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,

                              children: [
                                _buildChip(
                                  exercise.muscle,
                                  Colors.blue[100]!,
                                  Colors.blue[800]!,
                                ),
                                const SizedBox(width: 8),
                                _buildChip(
                                  exercise.type,
                                  Colors.green[100]!,
                                  Colors.green[800]!,
                                ),
                                const SizedBox(width: 8),
                                _buildChip(
                                  exercise.difficulty,
                                  _getDifficultyColor(exercise.difficulty)[0],
                                  _getDifficultyColor(exercise.difficulty)[1],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise.instructions,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF288a52),
                        ),
                        onTap: () {
                          _showExerciseDetails(context, exercise);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Color> _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return [Colors.green[100]!, Colors.green[800]!];
      case 'intermediate':
        return [Colors.orange[100]!, Colors.orange[800]!];
      case 'expert':
        return [Colors.red[100]!, Colors.red[800]!];
      default:
        return [Colors.grey[100]!, Colors.grey[800]!];
    }
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildChip(
                          exercise.muscle,
                          Colors.blue[100]!,
                          Colors.blue[800]!,
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          exercise.type,
                          Colors.green[100]!,
                          Colors.green[800]!,
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          exercise.difficulty,
                          _getDifficultyColor(exercise.difficulty)[0],
                          _getDifficultyColor(exercise.difficulty)[1],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Equipment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.equipment,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Instructions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.instructions,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
