import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neurelief/main.dart';
import 'package:neurelief/signuppage.dart';
import 'apiServices.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception("Please fill in all fields");
      }
      await _apiService.login(_emailController.text.trim(), _passwordController.text.trim());
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please verify your email.")));
        return;
      }
      print("User logged in: ${userCredential.user!.email}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print("Error logging in: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to login: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/calm2.jpg'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstATop)),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(expandedHeight: 120.0, floating: true, flexibleSpace: FlexibleSpaceBar(title: Text('Welcome Back', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900], shadows: [Shadow(color: Colors.black45, blurRadius: 3)]))), backgroundColor: Colors.transparent, elevation: 0),
              SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20.0), child: Card(elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: Colors.white.withOpacity(0.95), child: Padding(padding: EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Login to Neurelief', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                SizedBox(height: 20),
                TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.grey[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                SizedBox(height: 15),
                TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.grey[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), obscureText: true),
                SizedBox(height: 30),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 5), onPressed: _isLoading ? null : _login, child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                SizedBox(height: 15),
                Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())), child: Text('Don’t have an account? Sign up', style: TextStyle(color: Colors.blue[900], fontSize: 16, fontWeight: FontWeight.w600)))),
              ]))))),
            ],
          ),
        ),
      ),
    );
  }
}