import 'package:flutter/material.dart';

class Additionalinfo extends StatelessWidget {
  final IconData icon;
  final String lable;
  final String value;
  const Additionalinfo({
    super.key,
    required this.icon,
    required this.lable,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(lable),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ], //6:36:15 yt
    );
  }
}
