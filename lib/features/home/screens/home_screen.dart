import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [HomeHeader(user: user)],
          ),
        ),
      ),
    );
  }
}
