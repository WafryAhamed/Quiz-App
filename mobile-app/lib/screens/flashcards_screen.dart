import 'package:flutter/material.dart';

import '../widgets/index.dart';

class FlashcardsScreen extends StatefulWidget {
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
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final List<bool> _flipped = List.filled(FlashcardsScreen._cards.length, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Flashcards 🎴',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: const Color(0xFF0F3D3E),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Practice with interactive cards',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Flashcards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final card = FlashcardsScreen._cards[index];
                      final isFlipped = _flipped[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _flipped[index] = !_flipped[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: GlassCard(
                              key: ValueKey(isFlipped),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Card Label
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFB7E36D),
                                              Color(0xFF6EDC8C),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          card['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F3D3E),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isFlipped
                                            ? Icons.flip_to_front
                                            : Icons.flip_to_back,
                                        size: 18,
                                        color: const Color(0xFF6EDC8C),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Card Content
                                  Column(
                                    children: [
                                      Text(
                                        isFlipped ? 'Answer' : 'Question',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isFlipped
                                            ? (card['back'] ?? '')
                                            : (card['front'] ?? ''),
                                        textAlign: TextAlign.center,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                          color: const Color(0xFF0F3D3E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Tap Hint
                                  Text(
                                    'Tap to flip',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: FlashcardsScreen._cards.length,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(child: Container()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
