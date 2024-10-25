import 'package:flutter/material.dart';
import 'dart:async';

import 'package:railway_food_delivery/delivery_form.dart'; // For using Future

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for popping up the image
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // pop-up animation duration
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Start the animation
    _controller.forward();

    // Start the timer to move to the home screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DeliveryForm())); // Replace with your home route
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation, // Apply the pop-up animation
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
