import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void initState() {
    super.initState();

    // Wait for 2 seconds and then check auth status
    Future.delayed(const Duration(seconds: 5), () {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'token');

    try{
      if(token != null){
        Navigator.pushReplacementNamed(context, '/bottomNav');
      }else{
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }catch(e){
      print('Error checking auth status: $e');
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/splash.gif"),fit: BoxFit.cover)
        ),
      ),
    );
  }
}
