import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final RouteSettings? routeSettings;

  SmoothPageRoute({required this.builder, this.routeSettings})
    : super(settings: routeSettings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // iOS-like slide transition from right
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    var offsetAnimation = animation.drive(tween);

    // Fade out previous page slightly
    var fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

    return Stack(
      children: [
        // Previous page with fade effect
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-0.3, 0.0),
                ).animate(
                  CurvedAnimation(parent: secondaryAnimation, curve: curve),
                ),
            child: Container(),
          ),
        ),
        // New page sliding in
        SlideTransition(position: offsetAnimation, child: child),
      ],
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);
}

// Helper function for easier usage
Route<T> smoothPageRoute<T>(Widget page, {RouteSettings? settings}) {
  return SmoothPageRoute<T>(
    builder: (context) => page,
    routeSettings: settings,
  );
}
