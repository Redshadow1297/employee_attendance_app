import 'package:flutter/material.dart';

class HRContactScreen extends StatefulWidget {
  const HRContactScreen({super.key});

  @override
  State<HRContactScreen> createState() => _HRContactScreenState();
}

class _HRContactScreenState extends State<HRContactScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('HR Contact Screen'),
      ),
    );
  }
}