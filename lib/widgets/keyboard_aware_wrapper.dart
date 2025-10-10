import 'package:flutter/material.dart';

/// A wrapper widget that provides keyboard-aware behavior for screens
/// that need to resize when the keyboard appears, while maintaining
/// navigation stability in the main navigation.
class KeyboardAwareWrapper extends StatelessWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;

  const KeyboardAwareWrapper({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    // If this wrapper is inside the MainNavigationScreen, we need to handle
    // keyboard behavior differently to avoid affecting the FloatingActionButton
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    
    if (resizeToAvoidBottomInset && keyboardHeight > 0) {
      // When keyboard is open, add padding to the bottom to push content up
      return Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: child,
      );
    }
    
    return child;
  }
}
