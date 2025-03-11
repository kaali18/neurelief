import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();

  // Replace with your API key
  static const apiKey = "AIzaSyAbOU3b5Nv4vvit3GYXLtg8PkqaNVvNb1E";
  
  // Initialize the model
  late final GenerativeModel model;
  
  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-2.0-flash-lite-001',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8, // Slightly higher temperature for more conversational responses
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 150, // Limit response length to keep it brief
      ),
    );
  }

  final List<Message> _messages = [
    Message(
      isUser: false,
      message: "Hey there! I'm your friend in the digital world. Having a rough day? Need to talk? I'm all ears! 😊",
      date: DateTime.now(),
    ),
  ];
  
  bool _isLoading = false;

  Future<void> sendMessage() async {
    final message = _userMessage.text.trim();
    if (message.isEmpty) return;

    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      _isLoading = true;
    });

    try {
      // Create a chat session with friendly context
      final chat = model.startChat(
        history: [
          Content.text("You are a supportive friend who listens and responds with empathy and your name is Mellowmind.Keep your responses brief (2-3 sentences), casual, and use a warm, friendly tone. Avoid sounding like an AI assistant. Don't use formal language or lengthy explanations. Respond like a good friend would in a text message. Use occasional emojis to express emotions. If someone shares stress or problems, be understanding and supportive without giving lengthy advice."),
        ],
      );
      
      // Send the message
      final response = await chat.sendMessage(
        Content.text(message),
      );
      
      if (response.text != null && response.text!.isNotEmpty) {
        setState(() {
          _messages.add(Message(
            isUser: false,
            message: response.text!.trim(),
            date: DateTime.now(),
          ));
        });
      } else {
        throw Exception("Empty response received");
      }
    } catch (e) {
      print("Error generating response: $e");
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Sorry, I'm having a moment! Can we try again? 😅",
          date: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use a background image instead of a gradient
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/light_bg.jpeg'), // Add this image to your assets
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with transparent background to show the image
              AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: const Text(
                  'Chat with Mellowmind',
                  style: TextStyle(
                    color: Color.fromARGB(255, 201, 159, 159),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A4A4A)),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A4A4A)),
                    onPressed: () {
                      setState(() {
                        _messages.clear();
                        _messages.add(Message(
                          isUser: false,
                          message: "Hey there! I'm your friend in the digital world. Having a rough day? Need to talk? I'm all ears! 😊",
                          date: DateTime.now(),
                        ));
                      });
                    },
                  ),
                ],
              ),
              // Chat messages
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date),
                    );
                  },
                ),
              ),
              // Loader for bot response
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B7FD7),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              // Message input area with frosted glass effect
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontFamily: 'Poppins',
                        ),
                        controller: _userMessage,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(color: Color(0xFF757575)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        onFieldSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6B7FD7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 8).copyWith(
        left: isUser ? 80 : 10,
        right: isUser ? 10 : 80,
      ),
      decoration: BoxDecoration(
        color: isUser 
          ? const Color(0xFF6B7FD7).withOpacity(0.9)
          : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isUser 
            ? const Color(0xFF6B7FD7).withOpacity(0.2)
            : Colors.white.withOpacity(0.8), 
          width: 1.5
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF4A4A4A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: isUser ? FontWeight.normal : FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) 
                const Icon(Icons.favorite, size: 12, color: Color(0xFFE91E63)),
              if (!isUser) 
                const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: isUser 
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF757575),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}