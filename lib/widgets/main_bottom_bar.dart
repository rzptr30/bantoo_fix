import 'package:flutter/material.dart';

BottomNavigationBar mainBottomBar({
  required int current,
  required Function(int) onTap,
}) {
  return BottomNavigationBar(
    currentIndex: current,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        label: 'Create',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'History',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}