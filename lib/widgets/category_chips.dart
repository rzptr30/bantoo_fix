import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.medical_services, 'label': 'Medical'},
      {'icon': Icons.school, 'label': 'Education'},
      {'icon': Icons.house, 'label': 'Housing'},
      {'icon': Icons.local_dining, 'label': 'Food'},
      {'icon': Icons.nature_people, 'label': 'Environment'},
      {'icon': Icons.child_care, 'label': 'Children'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((category) {
          return Chip(
            avatar: Icon(
              category['icon'] as IconData,
              size: 16,
            ),
            label: Text(category['label'] as String),
            backgroundColor: Colors.grey[200],
          );
        }).toList(),
      ),
    );
  }
}