import 'package:flutter/material.dart';

/// A widget that disables the swipe back gesture.
/// 
/// Wrap your Scaffold with this widget to prevent users from navigating back
/// using the swipe gesture (from left to right).
class DisableSwipeBack extends StatelessWidget {
  final Widget child;

  const DisableSwipeBack({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: child,
    );
  }
}
