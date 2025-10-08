import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class ProgressIndicatorWidgets extends StatelessWidget {
  const ProgressIndicatorWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleCircularProgressBar(progressColors: const [Colors.cyan]);
  }
}
