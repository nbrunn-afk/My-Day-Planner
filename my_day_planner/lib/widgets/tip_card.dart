import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TipCard extends StatefulWidget {
  const TipCard({super.key});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  late Future<String> _futureTip;

  @override
  void initState() {
    super.initState();
    _futureTip = _loadRandomTip();
  }

  Future<String> _loadRandomTip() async {
    try {
      final raw = await rootBundle.loadString('assets/tips.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      final tips = List<String>.from(data['tips'] as List);
      if (tips.isEmpty) {
        return 'Stay positive and keep going!';
      }
      final randomIndex = Random().nextInt(tips.length);
      return tips[randomIndex];
    } catch (e) {
      return 'Could not load tips: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _futureTip,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading today\'s tip...');
            }
            final tip = snapshot.data ?? 'Have a great day!';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(tip),
              ],
            );
          },
        ),
      ),
    );
  }
}
