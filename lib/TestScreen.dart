import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neurelief/main.dart';
//import 'dart:math' as math;

class TestPageScreen extends StatefulWidget {
  final Map<String, bool> conditions;
  TestPageScreen({required this.conditions});

  @override
  _TestPageScreenState createState() => _TestPageScreenState();
}

class _TestPageScreenState extends State<TestPageScreen> {
  Map<String, int> responses = {
    "stress_q1": 1, "stress_q2": 0, "stress_q3": 1, "stress_q4": 0, "stress_q5": 0,
    "adhd_q1": 1, "adhd_q2": 0, "adhd_q3": 1, "adhd_q4": 0, "adhd_q5": 0,
    "anxiety_q1": 1, "anxiety_q2": 0, "anxiety_q3": 0, "anxiety_q4": 1, "anxiety_q5": 0,
    "autism_q1": 1, "autism_q2": 0, "autism_q3": 0, "autism_q4": 0, "autism_q5": 1,
    "alz_q1": 0, "alz_q2": 1, "alz_q3": 0, "alz_q4": 1, "alz_q5": 0,
    "stroke_q1": 1, "stroke_q2": 0, "stroke_q3": 1, "stroke_q4": 0, "stroke_q5": 1,
    "lazy_q1": 0, "lazy_q2": 1, "lazy_q3": 0, "lazy_q4": 0, "lazy_q5": 0,
  };

  @override
  void initState() {
    super.initState();
    print("Test Page: conditions = ${widget.conditions}");
    print("Test Page: responses = $responses");
  }

  Future<void> _saveToFirestore(Map<String, int> responses, Map<String, Map<String, dynamic>> predictions) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user signed in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('test_results')
          .add({
        'responses': responses,
        'predictions': predictions,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Test results and predictions saved to Firestore.");
    } catch (e) {
      print("Error saving to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save results: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/calm2.jpg'), // Ensure calm2.jpg is in assets folder
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8), // Makes the image lighter
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Neurological Assessment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900], // Darker color for contrast
                      fontSize: 24,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard("General Stress Questions", [
                        _buildCircularRating("How stressed do you feel right now?", "stress_q1", 1, 5),
                        _buildYesNoQuestion("Did anything stressful happen today?", "stress_q2"),
                        _buildCircularRating("How well did you sleep last night?", "stress_q3", 1, 5),
                        _buildChoiceQuestion("Do you feel overwhelmed or calm today?", "stress_q4", ["Calm", "Neutral", "Overwhelmed"]),
                        _buildChoiceQuestion("How’s your energy level today?", "stress_q5", ["High", "Medium", "Low"]),
                      ]),
                      _buildSectionCard("ADHD Questions", [
                        _buildCircularRating("How hard is it to focus on one thing right now?", "adhd_q1", 1, 5),
                        _buildYesNoQuestion("Do you feel restless or fidgety today?", "adhd_q2"),
                        _buildCircularRating("Have you felt annoyed or frustrated in the last hour?", "adhd_q3", 1, 5),
                        _buildYesNoQuestion("Did you forget anything important today?", "adhd_q4"),
                        _buildChoiceQuestion("How often did your mind wander today?", "adhd_q5", ["Rarely", "Sometimes", "Often"]),
                      ]),
                      _buildSectionCard("Anxiety Questions", [
                        _buildCircularRating("How much are you worrying right now?", "anxiety_q1", 1, 5),
                        _buildYesNoQuestion("Do you feel tense or shaky today?", "anxiety_q2"),
                        _buildYesNoQuestion("Have you avoided anything because it made you nervous?", "anxiety_q3"),
                        _buildCircularRating("How fast is your heart beating right now?", "anxiety_q4", 1, 5),
                        _buildYesNoQuestion("Do you feel like something bad might happen soon?", "anxiety_q5"),
                      ]),
                      _buildSectionCard("Autism Questions", [
                        _buildCircularRating("How comfortable do you feel around people today?", "autism_q1", 1, 5),
                        _buildYesNoQuestion("Are sounds, lights, or textures bothering you?", "autism_q2"),
                        _buildYesNoQuestion("Did anything change in your routine that upset you?", "autism_q3"),
                        _buildYesNoQuestion("Do you feel like you need time alone?", "autism_q4"),
                        _buildCircularRating("How easy is it to understand what others want from you?", "autism_q5", 1, 5),
                      ]),
                      _buildSectionCard("Alzheimer’s Questions", [
                        _buildYesNoQuestion("Did you have trouble remembering something today?", "alz_q1"),
                        _buildCircularRating("How clear does your mind feel right now?", "alz_q2", 1, 5),
                        _buildYesNoQuestion("Did you feel lost or confused in the last hour?", "alz_q3"),
                        _buildCircularRating("How hard was it to do a simple task today?", "alz_q4", 1, 5),
                        _buildYesNoQuestion("Are you feeling worried about forgetting things?", "alz_q5"),
                      ]),
                      _buildSectionCard("Stroke Recovery Questions", [
                        _buildCircularRating("How tired do you feel after moving around today?", "stroke_q1", 1, 5),
                        _buildYesNoQuestion("Did you struggle with any physical tasks today?", "stroke_q2"),
                        _buildCircularRating("How frustrated do you feel about your recovery?", "stroke_q3", 1, 5),
                        _buildYesNoQuestion("Do you feel steady on your feet right now?", "stroke_q4"),
                        _buildCircularRating("How much effort did it take to speak clearly today?", "stroke_q5", 1, 5),
                      ]),
                      _buildSectionCard("Lazy Eyes Questions", [
                        _buildYesNoQuestion("Are your eyes feeling tired or sore right now?", "lazy_q1"),
                        _buildCircularRating("How blurry does your vision seem today?", "lazy_q2", 1, 5),
                        _buildYesNoQuestion("Did you have trouble judging distances today?", "lazy_q3"),
                        _buildYesNoQuestion("Do bright screens or lights bother your eyes?", "lazy_q4"),
                        _buildChoiceQuestion("How often did you close one eye to see better?", "lazy_q5", ["Rarely", "Sometimes", "Often"]),
                      ]),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          onPressed: () async {
                            var predictions = predictConditions(responses);
                            await _saveToFirestore(responses, predictions);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ResultScreen(predictions: predictions)),
                            );
                          },
                          child: Text(
                            "Submit Assessment",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> questions) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 15),
            ...questions,
          ],
        ),
      ),
    );
  }

  Widget _buildCircularRating(String text, String key, int min, int max) {
    assert(responses.containsKey(key), "Key $key not found in responses map");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue[900], // Track color when active
                inactiveTrackColor: Colors.grey[300], // Inactive track color
                trackHeight: 8.0,
                thumbColor: Colors.transparent, // Hide default thumb
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
                overlayColor: Colors.transparent,
                valueIndicatorColor: Colors.blue[900],
                valueIndicatorTextStyle: TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: responses[key]!.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: responses[key].toString(),
                onChanged: (value) {
                  setState(() {
                    responses[key] = value.round().clamp(min, max);
                  });
                },
              ),
            ),
          ),
          Center(
            child: CustomPaint(
              painter: GradientThumbPainter(value: responses[key]!.toDouble(), min: min.toDouble(), max: max.toDouble()),
              child: SizedBox(
                height: 20, // Adjust height to fit the thumb
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion(String text, String key) {
    assert(responses.containsKey(key), "Key $key not found in responses map");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: responses[key] == 1,
            activeColor: Colors.blue[900],
            onChanged: (value) {
              setState(() => responses[key] = value ? 1 : 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceQuestion(String text, String key, List<String> options) {
    assert(responses.containsKey(key), "Key $key not found in responses map");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<int>(
              value: responses[key],
              items: options
                  .asMap()
                  .entries
                  .map((e) => DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => responses[key] = value!);
              },
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
              dropdownColor: Colors.white,
              isExpanded: true,
              underline: SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientThumbPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;

  GradientThumbPainter({required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final double normalizedValue = (value - min) / (max - min);
    final double thumbX = size.width * normalizedValue;
    final Paint thumbPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue[900]!, Colors.purple[400]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(thumbX, size.height / 2), radius: 10))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(thumbX, size.height / 2), 10, thumbPaint);
    canvas.drawCircle(Offset(thumbX, size.height / 2), 10, Paint()..color = Colors.white.withOpacity(0.3)); // Glow effect
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Prediction Logic (unchanged)
Map<String, Map<String, dynamic>> predictConditions(Map<String, int> responses) {
  var scores = {
    "Stress": responses["stress_q1"]! + responses["stress_q2"]! + (6 - responses["stress_q3"]!) + responses["stress_q4"]! + responses["stress_q5"]!,
    "ADHD": responses["adhd_q1"]! + responses["adhd_q2"]! + responses["adhd_q3"]! + responses["adhd_q4"]! + responses["adhd_q5"]!,
    "Anxiety": responses["anxiety_q1"]! + responses["anxiety_q2"]! + responses["anxiety_q3"]! + responses["anxiety_q4"]! + responses["anxiety_q5"]!,
    "Autism": (6 - responses["autism_q1"]!) + responses["autism_q2"]! + responses["autism_q3"]! + responses["autism_q4"]! + (6 - responses["autism_q5"]!),
    "Alzheimer’s": responses["alz_q1"]! + (6 - responses["alz_q2"]!) + responses["alz_q3"]! + responses["alz_q4"]! + responses["alz_q5"]!,
    "Stroke": responses["stroke_q1"]! + responses["stroke_q2"]! + responses["stroke_q3"]! + (responses["stroke_q4"]! == 0 ? 0 : 1) + responses["stroke_q5"]!,
    "Lazy Eyes": responses["lazy_q1"]! + responses["lazy_q2"]! + responses["lazy_q3"]! + responses["lazy_q4"]! + responses["lazy_q5"]!,
  };

  var maxScores = {"Stress": 15, "ADHD": 14, "Anxiety": 13, "Autism": 13, "Alzheimer’s": 13, "Stroke": 14, "Lazy Eyes": 11};
  var thresholds = {"Stress": 9, "ADHD": 8, "Anxiety": 8, "Autism": 8, "Alzheimer’s": 8, "Stroke": 8, "Lazy Eyes": 7};

  Map<String, Map<String, dynamic>> predictions = {};
  scores.forEach((condition, score) {
    double confidence = (score / maxScores[condition]!) * 100;
    predictions[condition] = {"Detected": score >= thresholds[condition]!, "Confidence": confidence};
  });
  return predictions;
}

class ResultScreen extends StatelessWidget {
  final Map<String, Map<String, dynamic>> predictions;
  ResultScreen({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/calm2.jpg'), // Ensure calm2.jpg is in assets folder
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8), // Makes the image lighter
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Your Assessment Results",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900], // Darker color for contrast
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Here's what we found based on your responses",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: predictions.entries.map((e) => Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.95),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: e.value["Detected"] ? Colors.red : Colors.green,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 1),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${e.value["Detected"] ? "Detected" : "Not Detected"} "
                                    "(${e.value["Confidence"].toStringAsFixed(1)}%)",
                                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                      print("Navigating to Home Page...");
                    },
                    child: Text(
                      "Return to Home",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}