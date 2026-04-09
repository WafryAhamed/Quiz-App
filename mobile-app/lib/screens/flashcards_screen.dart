import 'package:flutter/material.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  static const routeName = '/flashcards';

  static const _cards = [
    {
      'title': 'OOP Pillars',
      'front': 'What are the main OOP pillars?',
      'back': 'Encapsulation, Inheritance, Polymorphism, Abstraction.',
    },
    {
      'title': 'Sri Lankan IT Industry',
      'front': 'Name one Sri Lankan university known for Computer Science.',
      'back':
          'University of Moratuwa, University of Colombo School of Computing.',
    },
    {
      'title': 'Database Concept',
      'front': 'What is normalization?',
      'back': 'A process to reduce redundancy and improve data integrity.',
    },
    {
      'title': 'Machine Learning',
      'front': 'What is overfitting?',
      'back': 'Model performs well on training data but poorly on unseen data.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Card(
            child: ExpansionTile(
              title: Text(card['title'] ?? ''),
              subtitle: Text(card['front'] ?? ''),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    card['back'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
