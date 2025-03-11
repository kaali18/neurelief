import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neurelief/LandingPage.dart';
import 'package:neurelief/Screens/games_screen.dart';
import 'package:neurelief/Screens/VoicechatScreen.dart'; // Assuming this is for voice chat
import 'package:neurelief/Screens/music_screen.dart';
import 'package:neurelief/Screens/support_screen.dart';
import 'package:neurelief/Screens/progress_screen.dart';
import 'package:neurelief/Screens/todo_list_screen.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(NeuroReliefApp());
}

class NeuroReliefApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuro Relief',
      theme: ThemeData(
        primaryColor: Color(0xFFD4E4D2),
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: Color(0xFFF5F5F5),
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
          bodyMedium: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            color: Color(0xFF2E4A3D),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Color(0xFFF7E4BC).withOpacity(0.5)),
              ),
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            elevation: MaterialStateProperty.all(8),
            overlayColor: MaterialStateProperty.all(
              Color(0xFFF0D8A8).withOpacity(0.3),
            ),
          ),
        ),
      ),
      home: LandingPage(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onButtonPressed(VoidCallback onPressed) {
    _controller.forward();
    onPressed();
  }


  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _onButtonPressed(onPressed),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  color: Color(0xFF2E4A3D),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6F0FA).withOpacity(0.85),
              Color(0xFFF5F0FF).withOpacity(0.85),
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/forest.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Neuro Relief',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Find Calm and Support',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFF5E8C7),
                        ),
                  ),
                  SizedBox(height: 40),
                  _buildGradientButton(
                    text: 'Play Relaxing Games',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GamesScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: 'Listen to Music',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MusicScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: 'Get Support',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SupportScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: 'View My Progress',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: 'To-Do List',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ToDoListScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: 'Chat with Mellowmind',
                    onPressed: () {
                      // No microphone needed for text-based ChatScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 2,
                    color: Color(0xFFF7E4BC).withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}