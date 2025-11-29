import 'package:flutter/material.dart';

class SnackBarHelper {
  const SnackBarHelper._();

  static void show(
    BuildContext context, {
    required String message,
    bool success = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success
                ? Colors.green
                : Theme.of(context).colorScheme.error,
        duration: Duration(milliseconds: success ? 1000 : 3000),
      ),
    );
  }
}
