import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GamesScreen extends StatefulWidget {
  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String selectedGame = 'Memory Game'; // Default game

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
                  'Relaxing Games',
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
                _buildGameSelectionMenu(),
                SizedBox(height: 20),
                Expanded(
                  child: _buildSelectedGame(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelectionMenu() {
    List<String> games = [
      'Memory Game',
      'Pattern Matching', // For Alzheimer's
      'Breathing Bubble', // For Anxiety
      'Quick Tap',       // For ADHD
      'Sensory Pattern', // For Autism
      'Follow the Dot',  // For Lazy Eye Training
    ];

    return Wrap(
      spacing: 10,
      children: games.map((game) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGame = game;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              gradient: selectedGame == game
                  ? LinearGradient(
                      colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selectedGame != game ? Colors.grey[800]! : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              game,
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedGame() {
    switch (selectedGame) {
      case 'Memory Game':
        return MemoryGameWidget();
      case 'Pattern Matching':
        return PatternMatchingGame();
      case 'Breathing Bubble':
        return BreathingBubbleGame();
      case 'Quick Tap':
        return QuickTapGame();
      case 'Sensory Pattern':
        return SensoryPatternGame();
      case 'Follow the Dot':
        return FollowTheDotGame();
      default:
        return SizedBox();
    }
  }
}

class MemoryGameWidget extends StatefulWidget {
  @override
  _MemoryGameWidgetState createState() => _MemoryGameWidgetState();
}

class _MemoryGameWidgetState extends State<MemoryGameWidget> {
  int gridSize = 4;
  List<String> icons = [];
  List<bool> isFlipped = [];
  List<bool> isMatched = [];
  int? firstFlippedIndex;
  bool isChecking = false;
  int matchesFound = 0;

  final List<int> gridSizeOptions = [4, 6, 8, 10];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    int totalCards = gridSize * gridSize;
    if (totalCards % 2 != 0) totalCards--;

    List<String> tempIcons = [];
    List<String> emojiList = ['🌟', '🍀', '🌼', '🐾', '🍎', '🌙', '🦋', '🎈', '🍓', '🌈', '🐱', '🌳', '🍋', '⚽', '🎁', '🔔', '🍒', '🌍', '🎶', '🚀', '🐶', '🌺', '🍉', '🎉', '🦁'];
    int pairsNeeded = totalCards ~/ 2;
    for (int i = 0; i < pairsNeeded; i++) {
      String icon = emojiList[i % emojiList.length];
      tempIcons.add(icon);
      tempIcons.add(icon);
    }

    setState(() {
      icons = tempIcons;
      icons.shuffle();
      isFlipped = List.generate(totalCards, (_) => false);
      isMatched = List.generate(totalCards, (_) => false);
      firstFlippedIndex = null;
      isChecking = false;
      matchesFound = 0;
    });
  }

  void _changeGridSize(int? newSize) {
    if (newSize != null) {
      setState(() {
        gridSize = newSize;
        _initializeGame();
      });
    }
  }

  void _flipCard(int index) async {
    if (isChecking || isFlipped[index] || isMatched[index]) return;

    setState(() {
      isFlipped[index] = true;
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
    } else {
      isChecking = true;
      if (icons[firstFlippedIndex!] == icons[index]) {
        setState(() {
          isMatched[firstFlippedIndex!] = true;
          isMatched[index] = true;
          matchesFound++;
        });
      } else {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          isFlipped[firstFlippedIndex!] = false;
          isFlipped[index] = false;
        });
      }
      firstFlippedIndex = null;
      isChecking = false;
    }

    if (matchesFound == icons.length ~/ 2) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Congratulations!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'You found all the matches!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: Text(
              'Play Again',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Grid Size: ',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            DropdownButton<int>(
              value: gridSize,
              dropdownColor: Color(0xFF1DB954).withOpacity(0.9),
              onChanged: _changeGridSize,
              items: gridSizeOptions.map((size) {
                return DropdownMenuItem<int>(
                  value: size,
                  child: Text(
                    '$size x $size',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _flipCard(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isFlipped[index] || isMatched[index]
                        ? Colors.grey[800]!
                        : Color(0xFFF7E4BC),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isFlipped[index] || isMatched[index] ? icons[index] : '❓',
                      style: TextStyle(fontSize: gridSize > 6 ? 16 : 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _initializeGame,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Restart Game',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF2E4A3D),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BreathingBubbleGame extends StatefulWidget {
  @override
  _BreathingBubbleGameState createState() => _BreathingBubbleGameState();
}

class _BreathingBubbleGameState extends State<BreathingBubbleGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isBreathing = false;
  int _cyclesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
    });
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isBreathing)
          GestureDetector(
            onTap: _startBreathing,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Begin Breathing',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF2E4A3D),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        if (_isBreathing) ...[
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              if (_controller.status == AnimationStatus.forward && _animation.value >= 1.99) {
                _cyclesCompleted++;
              }
              return Column(
                children: [
                  Transform.scale(
                    scale: _animation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _controller.status == AnimationStatus.forward ? 'Inhale' : 'Exhale',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Cycles Completed: $_cyclesCompleted',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Colors.grey[400]!,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _isBreathing = false;
                _cyclesCompleted = 0;
              });
              _controller.stop();
              _controller.reset();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: Text(
                'Stop',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class QuickTapGame extends StatefulWidget {
  @override
  _QuickTapGameState createState() => _QuickTapGameState();
}

class _QuickTapGameState extends State<QuickTapGame> {
  double _targetX = 0.0;
  double _targetY = 0.0;
  bool _isTargetVisible = false;
  int _score = 0;
  bool _gameStarted = false;
  int _timeLeft = 30; // Game lasts 30 seconds
  Timer? _gameTimer;
  Timer? _targetTimer;
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _timeLeft = 30;
    });

    // Start the game timer
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _targetTimer?.cancel();
          _isTargetVisible = false;
          _gameStarted = false;
          _showGameOverDialog();
        }
      });
    });

    // Show the first target
    _showNewTarget();
  }

  void _showNewTarget() {
    setState(() {
      _isTargetVisible = false;
    });

    // Generate new random position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _targetX = _random.nextDouble() * (size.width - 60); // Subtract target size
        _targetY = _random.nextDouble() * (size.height - 150); // Subtract target size and padding
        _isTargetVisible = true;
      });

      // Set a timer to hide the target after 2 seconds
      _targetTimer?.cancel();
      _targetTimer = Timer(Duration(seconds: 2), () {
        if (_gameStarted) {
          setState(() {
            _isTargetVisible = false;
          });
          _showNewTarget();
        }
      });
    });
  }

  void _tapTarget() {
    setState(() {
      _score++;
      _isTargetVisible = false;
    });
    _showNewTarget();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Game Over!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'Your Score: $_score',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: Text(
              'Play Again',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_gameStarted)
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Start Game',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF2E4A3D),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        if (_gameStarted) ...[
          Text(
            'Score: $_score',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Time Left: $_timeLeft s',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: Colors.grey[400]!,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                if (_isTargetVisible)
                  Positioned(
                    left: _targetX,
                    top: _targetY,
                    child: GestureDetector(
                      onTap: _tapTarget,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1DB954),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class FollowTheDotGame extends StatefulWidget {
  @override
  _FollowTheDotGameState createState() => _FollowTheDotGameState();
}

class _FollowTheDotGameState extends State<FollowTheDotGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  double _dotSize = 30.0;
  Color _dotColor = Colors.white;
  int _score = 0;
  bool _gameStarted = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    // Initialize with a stopped animation at position 0
    _xAnimation = AlwaysStoppedAnimation(0.0);
    _yAnimation = AlwaysStoppedAnimation(0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _dotSize = 30.0;
      _dotColor = Colors.white;
    });
    _moveDot();
  }

  void _moveDot() {
    final size = MediaQuery.of(context).size;
    final newX = _random.nextDouble() * (size.width - _dotSize);
    final newY = _random.nextDouble() * (size.height - _dotSize - 100); // Adjust for padding

    setState(() {
      _xAnimation = Tween<double>(begin: _xAnimation.value, end: newX).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _yAnimation = Tween<double>(begin: _yAnimation.value, end: newY).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    });

    _controller.forward(from: 0).then((_) {
      if (_gameStarted) {
        setState(() {
          _dotSize = _random.nextDouble() * 20 + 20; // Between 20 and 40
          _dotColor = Color.fromRGBO(
            _random.nextInt(256),
            _random.nextInt(256),
            _random.nextInt(256),
            1,
          );
        });
        _moveDot();
      }
    });
  }

  void _tapDot() {
    setState(() {
      _score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_gameStarted)
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF7E4BC), Color(0xFFF0D8A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Start Game',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF2E4A3D),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        if (_gameStarted) ...[
          Text(
            'Score: $_score',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      left: _xAnimation.value,
                      top: _yAnimation.value,
                      child: GestureDetector(
                        onTap: _tapDot,
                        child: Container(
                          width: _dotSize,
                          height: _dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _dotColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _gameStarted = false;
                _score = 0;
              });
              _controller.stop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: Text(
                'Stop',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PatternMatchingGame extends StatefulWidget {
  @override
  _PatternMatchingGameState createState() => _PatternMatchingGameState();
}

class _PatternMatchingGameState extends State<PatternMatchingGame> {
  List<String> targetSequence = [];
  List<String> userSequence = [];
  bool isShowingSequence = true;
  int sequenceLength = 2;
  final List<String> shapes = ['🔴', '🔵', '🟢', '🟡', '⚪']; // Red, blue, green, yellow, white circles
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewSequence();
  }

  void _generateNewSequence() {
    targetSequence = List.generate(sequenceLength, (_) => shapes[_random.nextInt(shapes.length)]);
    userSequence.clear();
    isShowingSequence = true;
    setState(() {});
    Future.delayed(Duration(seconds: sequenceLength), () {
      if (mounted) {
        setState(() {
          isShowingSequence = false;
        });
      }
    });
  }

  void _tapShape(String shape) {
    if (isShowingSequence) return;

    setState(() {
      userSequence.add(shape);
    });

    if (userSequence.length == targetSequence.length) {
      if (_checkSequence()) {
        _showSuccessDialog();
      } else {
        _showFailureDialog();
      }
    }
  }

  bool _checkSequence() {
    for (int i = 0; i < targetSequence.length; i++) {
      if (targetSequence[i] != userSequence[i]) return false;
    }
    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Success!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'You matched the sequence! Next level.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              sequenceLength++;
              _generateNewSequence();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Try Again!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'The sequence didn\'t match. Try again.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewSequence();
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pattern Matching',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Target Sequence: ${isShowingSequence ? targetSequence.join(' ') : 'Memorize and Repeat'}',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: shapes.map((shape) {
            return GestureDetector(
              onTap: () => _tapShape(shape),
              child: Container(
                decoration: BoxDecoration(
                  color: isShowingSequence ? Colors.grey[800]! : Color(0xFFF7E4BC),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    shape,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SensoryPatternGame extends StatefulWidget {
  @override
  _SensoryPatternGameState createState() => _SensoryPatternGameState();
}

class _SensoryPatternGameState extends State<SensoryPatternGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Color> tileColors;
  List<int> targetPattern = [];
  List<int> userPattern = [];
  bool isShowingPattern = true;
  int gridSize = 3;
  Color tileColor = Colors.grey[800]!;
  Duration animationDuration = Duration(milliseconds: 500);
  final Random _random = Random();

   @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    // Initialize tileColors
    tileColors = List.generate(gridSize * gridSize, (_) => Colors.grey[800]!);
    _generateNewPattern();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateNewPattern() {
    targetPattern = List.generate(3, (_) => _random.nextInt(gridSize * gridSize));
    userPattern.clear();
    isShowingPattern = true;
    _showPattern();
  }

    void _showPattern() {
    _controller.reset();
    _controller.duration = animationDuration;

    void updateTileColors(int index, bool highlight) {
      setState(() {
        tileColors = List.generate(gridSize * gridSize, (i) => 
          i == index ? (highlight ? Colors.green : Colors.grey[800]!) : Colors.grey[800]!
        );
      });
    }


  for (int i = 0; i < targetPattern.length; i++) {
    Future.delayed(Duration(milliseconds: i * 700), () {
      if (mounted) {
        updateTileColors(targetPattern[i], true);
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted) {
            updateTileColors(targetPattern[i], false);
          }
        });
      }
    });
  }

  Future.delayed(Duration(milliseconds: targetPattern.length * 700), () {
    if (mounted) {
      setState(() {
        isShowingPattern = false;
      });
    }
  });
}

  void _tapTile(int index) {
    if (isShowingPattern) return;

    setState(() {
      userPattern.add(index);
    });

    if (userPattern.length == targetPattern.length) {
      if (_checkPattern()) {
        _showSuccessDialog();
      } else {
        _showFailureDialog();
      }
    }
  }

  bool _checkPattern() {
    for (int i = 0; i < targetPattern.length; i++) {
      if (targetPattern[i] != userPattern[i]) return false;
    }
    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Success!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'You matched the pattern! Next round.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewPattern();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Try Again!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        content: Text(
          'The pattern didn\'t match. Try again.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewPattern();
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF1DB954),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sensory Pattern',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        SizedBox(height: 20),
        Text(
          isShowingPattern ? 'Watch the Pattern' : 'Repeat the Pattern',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.grey[400]!,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 20),
        GridView.count(
          crossAxisCount: gridSize,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: List.generate(gridSize * gridSize, (index) {
            return GestureDetector(
              onTap: () => _tapTile(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}