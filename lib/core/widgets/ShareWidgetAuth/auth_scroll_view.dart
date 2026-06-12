import 'package:flutter/material.dart';

class AuthScrollView extends StatelessWidget {
  final Widget child;

  const AuthScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final hasKeyboard = keyboardBottom > 0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: keyboardBottom + 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: hasKeyboard ? 0 : constraints.maxHeight,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
