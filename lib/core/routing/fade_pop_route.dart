import 'package:flutter/material.dart';

/// A fast fade + slight scale-up, used for opening the tools menu — it
/// intentionally does *not* match the platform's default push/slide
/// transition, so the menu reads as its own layer popping in rather than
/// another page in the same stack.
Route<T> fadePopRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
