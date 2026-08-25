import 'package:flutter/material.dart';

/// A page transition where the incoming and outgoing screens slide together
/// in the same direction, like two panels on one physical plane, instead of
/// one screen dropping a shadow and covering the other. Used for the
/// calculator <-> tools-menu transition specifically.
class SamePlaneTransitionsBuilder extends PageTransitionsBuilder {
  const SamePlaneTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    final outgoing = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(incoming),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0)).animate(outgoing),
        child: child,
      ),
    );
  }
}

const samePlanePageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: SamePlaneTransitionsBuilder(),
    TargetPlatform.iOS: SamePlaneTransitionsBuilder(),
    TargetPlatform.windows: SamePlaneTransitionsBuilder(),
    TargetPlatform.macOS: SamePlaneTransitionsBuilder(),
    TargetPlatform.linux: SamePlaneTransitionsBuilder(),
  },
);
