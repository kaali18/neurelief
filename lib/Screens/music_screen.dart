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
  int _currentTrackIndex = 0;

  // Playlist of music tracks with associated videos
  final List<Map<String, String>> _playlist = [
    {
      'title': 'Calm Forest Sounds', 
      'file': 'assets/relaxing_music.mp3',
      'video': 'assets/forest_video.mp4'
    },
    {
      'title': 'Slow Sunset music', 
      'file': 'assets/a-slow-sunset-music-and-piano-by-elen-lackner-95454.mp3',
      'video': 'assets/birds_video.mp4'
    },
    {
      'title': 'Dwindling Hope', 
      'file': 'assets/dwindling-hope-287000.mp3',
      'video': 'assets/ocean_waves_video.mp4'
    },
    {
      'title': 'Meditative rain', 
      'file': 'assets/meditative-rain-114484.mp3',
      'video': 'assets/rain_video.mp4'
    },
    {
      'title': 'Soothing Rain', 
      'file': 'assets/rain-219935.mp3',
      'video': 'assets/rainy_forest_video.mp4'
    },
    {
      'title': 'Soft Birds Sound', 
      'file': 'assets/soft-birds-sound-304132.mp3',
      'video': 'assets/birds_video.mp4'
    },
    {
      'title': 'Tiny flowers Piano', 
      'file': 'assets/tiny-flowers-slow-gentle-piano-159953.mp3',
      'video': 'assets/flowers_video.mp4'
    },
    {
      'title': 'Water Fountain Music', 
      'file': 'assets/water-fountain-healing-music-239455.mp3',
      'video': 'assets/fountain_video.mp4'
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Initialize the video controller with the first track's video
    _videoController = VideoPlayerController.asset(_playlist[_currentTrackIndex]['video']!)
      ..initialize().then((_) {
        setState(() {});
        _videoController.setVolume(0.0); // Mute the video
        _videoController.play();
        _videoController.setLooping(true);
      }).catchError((error) {
        print("Error initializing video: $error");
      });
    
    _setupAudio(_currentTrackIndex);
  }

  Future<void> _initVideoPlayer(int index) async {
    // Dispose of previous video controller if it's initialized
    if (mounted && _videoController.value.isInitialized) {
      await _videoController.pause();
      await _videoController.dispose();
    }
    
    try {
      print("Initializing video: ${_playlist[index]['video']}");
      _videoController = VideoPlayerController.asset(_playlist[index]['video']!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController.setVolume(0.0); // Mute the video
            _videoController.play();
            _videoController.setLooping(true);
          }
        }).catchError((error) {
          print("Error initializing video: $error");
        });
    } catch (e) {
      print("Error setting up video: $e");
    }
  }

  Future<void> _setupAudio(int index) async {
    try {
      print("Attempting to load audio: ${_playlist[index]['title']}");
      await _audioPlayer.setAsset(_playlist[index]['file']!);
      print("Audio loaded successfully.");
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _videoController.pause();
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

  void _playTrack(int index) async {
    if (_currentTrackIndex != index) {
      await _audioPlayer.stop();
      setState(() {
        _currentTrackIndex = index;
        _isPlaying = false;
        _position = Duration.zero;
      });
      
      // Change the background video for the new track
      await _initVideoPlayer(index);
      await _setupAudio(index);
    }
    _togglePlayPause();
  }

  void _nextTrack() {
    if (_currentTrackIndex < _playlist.length - 1) {
      _playTrack(_currentTrackIndex + 1);
    }
  }

  void _previousTrack() {
    if (_currentTrackIndex > 0) {
      _playTrack(_currentTrackIndex - 1);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
      print("Player state updated: Playing = $_isPlaying");
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                          child: Text(
                            _playlist[_currentTrackIndex]['title']!,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Slider(
                                value: _position.inSeconds.toDouble(),
                                min: 0.0,
                                max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
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
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(
                              icon: Icons.skip_previous,
                              onPressed: _previousTrack,
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
                              onPressed: _nextTrack,
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
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _playlist.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  _playlist[index]['title']!,
                                  style: TextStyle(
                                    color: _currentTrackIndex == index ? Color(0xFF1DB954) : Colors.white,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                                onTap: () => _playTrack(index),
                                trailing: _currentTrackIndex == index && _isPlaying
                                    ? Icon(Icons.play_circle_filled, color: Color(0xFF1DB954))
                                    : null,
                              );
                            },
                          ),
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