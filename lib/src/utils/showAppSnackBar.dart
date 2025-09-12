import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

void showAppSnackBar(
    BuildContext context, {
      required String message,
      SnackBarType type = SnackBarType.info,
      Duration duration = const Duration(seconds: 2), // Default duration
      SnackBarAction? action,
    }) {
  // Clear any existing SnackBars
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade700;
      iconData = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade700;
      iconData = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange.shade700;
      iconData = Icons.warning_amber_outlined;
      break;
    case SnackBarType.info:
    default:
      backgroundColor = Colors.blueGrey.shade700;
      iconData = Icons.info_outline;
      break;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(iconData, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
            maxLines: 3, // Allow for slightly longer messages
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    duration: duration,
    action: action,
    behavior: SnackBarBehavior.floating, // Or .fixed as per your design
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    margin: const EdgeInsets.all(10.0), // Adjust if using floating behavior
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}