import 'package:flutter/material.dart';

PreferredSizeWidget dashboardAppBar(
  {VoidCallback? onRefresh}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: const Text(
      'Dashboard',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Color(0xFF0D4C92)),
    ),
    actions: [
      IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
      const Padding(
        padding: EdgeInsets.only(right: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ),
    ],
  );
}
