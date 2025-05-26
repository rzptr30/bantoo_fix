import 'package:flutter/material.dart';

AppBar dashboardAppBar({required VoidCallback onRefresh}) {
  return AppBar(
    title: const Text('Bantoo'),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: onRefresh,
      ),
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          // Show notifications
        },
      ),
    ],
  );
}