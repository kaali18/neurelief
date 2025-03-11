import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  // Sample progress data (this could be fetched from a database or local storage in the future)
  final Map<String, int> gameProgress = {
    'Memory Game': 5, // Number of completions
    'Pattern Matching': 3,
    'Breathing Bubble': 10, // Number of cycles completed
    'Quick Tap': 7, // High score
    'Sensory Pattern': 4,
    'Follow the Dot': 6,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954).withOpacity(0.2),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildProgressSummary(),
                      SizedBox(height: 20),
                      ...gameProgress.entries.map((entry) {
                        return _buildProgressCard(
                          title: entry.key,
                          value: entry.value,
                          context: context,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    int totalActivities = gameProgress.values.reduce((a, b) => a + b);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800]!,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Activity',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: totalActivities / 50, // Normalize to a max of 50 for the bar
            backgroundColor: Colors.grey[600],
            color: Color(0xFF1DB954),
            minHeight: 10,
          ),
          SizedBox(height: 10),
          Text(
            'Total Activities: $totalActivities',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: Colors.grey[400]!,
            ),
          ),
          SizedBox(height: 10),
          Text(
            totalActivities > 20
                ? 'Great job! You\'re making amazing progress!'
                : 'Keep going! You\'re doing well!',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: Color(0xFF1DB954),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      {required String title, required int value, required BuildContext context}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800]!,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            title == 'Quick Tap' ? 'High Score: $value' : 'Completed: $value',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: Colors.grey[400]!,
            ),
          ),
        ],
      ),
    );
  }
}