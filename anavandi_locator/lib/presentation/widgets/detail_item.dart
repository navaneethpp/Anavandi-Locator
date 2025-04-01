import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String? value;

  const DetailItem({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(value ?? 'Not Available'),
          const Divider(),
        ],
      ),
    );
  }
}
