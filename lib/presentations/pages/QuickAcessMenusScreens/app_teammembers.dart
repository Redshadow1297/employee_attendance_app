import 'package:flutter/material.dart';

class AppTeamMembersScreen extends StatefulWidget {
  const AppTeamMembersScreen({super.key});

  @override
  State<AppTeamMembersScreen> createState() => _AppTeamMembersScreenState();
}

class _AppTeamMembersScreenState extends State<AppTeamMembersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('App Team Members Screen'),
      ),
    );
  }
}