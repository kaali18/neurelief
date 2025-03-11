import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _videoController = VideoPlayerController.asset('assets/forest_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setVolume(0.0); // Mute the video
        _videoController.play();
        _videoController.setLooping(true);
      }).catchError((error) {
        print("Error initializing video: $error");
      });

    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      print("Attempting to load audio...");
      await _audioPlayer.setAsset('assets/relaxing_music.mp3');
      print("Audio loaded successfully.");
      // Do NOT auto-play; wait for user interaction to comply with browser restrictions
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      print("Audio paused. Position: ${_position.inSeconds} seconds");
    } else {
      try {
        await _audioPlayer.play();
        print("Audio playing. Duration: ${_duration.inSeconds} seconds");
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _stop() async {
    await _audioPlayer.stop();
    print("Audio stopped.");
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to duration changes
    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    // Update playing state
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
      print("Player state updated: Playing = ${_isPlaying}");
    });

    return Scaffold(
      body: _videoController.value.isInitialized
          ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Text(
                                'Calm Forest Sounds',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Nature Sounds',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Slider(
                                value: _position.inSeconds.toDouble(),
                                min: 0.0,
                                max: _duration.inSeconds.toDouble(),
                                activeColor: Color(0xFF1DB954),
                                inactiveColor: Colors.grey[700],
                                onChanged: (value) {
                                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(
                              icon: Icons.skip_previous,
                              onPressed: () {},
                              size: 40,
                            ),
                            SizedBox(width: 20),
                            _buildControlButton(
                              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                              onPressed: _togglePlayPause,
                              size: 60,
                              isPrimary: true,
                            ),
                            SizedBox(width: 20),
                            _buildControlButton(
                              icon: Icons.skip_next,
                              onPressed: () {},
                              size: 40,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildControlButton(
                          icon: Icons.stop,
                          onPressed: _stop,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? Color(0xFF1DB954) : Colors.grey[800],
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}