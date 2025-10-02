import 'package:flutter/material.dart';

class AiCtaCard extends StatelessWidget {
  final VoidCallback onStartChatTap;

  const AiCtaCard({super.key, required this.onStartChatTap});

  @override
  Widget build(BuildContext context) {
    const cardHeight = 150.0;
    const cardColor = Colors.lightBlueAccent;

    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cardColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'AI Chat Diagnosis: Triage Your Symptoms 🤖',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onStartChatTap,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Triage Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
