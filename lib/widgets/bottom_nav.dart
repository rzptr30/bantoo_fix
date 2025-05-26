import 'package:flutter/material.dart';

Widget mainBottomBar({
  required int current,
  required Function(int) onTap,
}) {
  return BottomNavigationBar(
    currentIndex: current,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: const Color(0xFF0D4C92),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism), label: 'Volunteer'),
      BottomNavigationBarItem(
          icon: Icon(Icons.notifications), label: 'Notif'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  );
}
