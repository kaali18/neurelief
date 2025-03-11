import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neurelief/loginpage.dart';
import 'package:neurelief/TestScreen.dart';
import 'apiServices.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Map<String, bool> _conditions = {
    'ADHD': false,
    'Autism': false,
    'Alzheimer’s': false,
    'Anxiety': false,
    'Stroke Recovery': false,
    'Lazy Eyes': false,
    'Other': false,
  };
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception("Please fill in all fields");
      }
      final selectedConditions = _conditions.keys.where((k) => _conditions[k]!).toList();
      if (selectedConditions.isEmpty) {
        throw Exception("Please select at least one condition");
      }
      await _apiService.signup(_emailController.text.trim(), _passwordController.text.trim(), selectedConditions);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please verify your email.")));
      Navigator.push(context, MaterialPageRoute(builder: (context) => TestPageScreen(conditions: _conditions)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign up: $e")));
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
              SliverAppBar(expandedHeight: 120.0, floating: true, flexibleSpace: FlexibleSpaceBar(title: Text('Join Neurelief', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900], shadows: [Shadow(color: Colors.black45, blurRadius: 3)]))), backgroundColor: Colors.transparent, elevation: 0),
              SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20.0), child: Card(elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: Colors.white.withOpacity(0.95), child: Padding(padding: EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create Your Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                SizedBox(height: 20),
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: Colors.grey[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                SizedBox(height: 15),
                TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.grey[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                SizedBox(height: 15),
                TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.grey[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), obscureText: true),
                SizedBox(height: 20),
                Text("Select Conditions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                SizedBox(height: 10),
                Wrap(spacing: 8.0, runSpacing: 4.0, children: _conditions.keys.map((condition) => FilterChip(label: Text(condition), selected: _conditions[condition]!, onSelected: (selected) { setState(() => _conditions[condition] = selected); }, selectedColor: Colors.blue[100], checkmarkColor: Colors.blue[900], labelStyle: TextStyle(color: Colors.grey[800]), backgroundColor: Colors.white)).toList()),
                SizedBox(height: 30),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 5), onPressed: _isLoading ? null : _signup, child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                SizedBox(height: 15),
                Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())), child: Text('Already have an account? Login', style: TextStyle(color: Colors.blue[900], fontSize: 16, fontWeight: FontWeight.w600)))),
              ]))))),
            ],
          ),
        ),
      ),
    );
  }
}