import 'package:flutter/material.dart';

class TasklarimCard extends StatelessWidget {
  final VoidCallback onTap;

  TasklarimCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Card(
        margin: EdgeInsets.all(16),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              "Tasklarim",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
