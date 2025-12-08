import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

/// Example demonstrating the new dramatic effects in AnimatedSlot
class DramaticEffectsExample extends StatefulWidget {
  const DramaticEffectsExample({super.key});

  @override
  State<DramaticEffectsExample> createState() => _DramaticEffectsExampleState();
}

class _DramaticEffectsExampleState extends State<DramaticEffectsExample> {
  final counter = Signal<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dramatic Effects Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wobble Effect
            _buildEffectDemo(
              'Wobble Effect',
              SlotEffect.wobble,
              Colors.purple,
            ),
            const SizedBox(height: 20),

            // Swing Effect
            _buildEffectDemo(
              'Swing Effect',
              SlotEffect.swing,
              Colors.blue,
            ),
            const SizedBox(height: 20),

            // Shake Effect
            _buildEffectDemo(
              'Shake Effect',
              SlotEffect.shake,
              Colors.green,
            ),
            const SizedBox(height: 20),

            // Bounce Effect
            _buildEffectDemo(
              'Bounce Effect',
              SlotEffect.bounce,
              Colors.orange,
            ),
            const SizedBox(height: 20),

            // Elastic Effect
            _buildEffectDemo(
              'Elastic Effect',
              SlotEffect.elastic,
              Colors.red,
            ),
            const SizedBox(height: 20),

            // Pulse Effect
            _buildEffectDemo(
              'Pulse Effect',
              SlotEffect.pulse,
              Colors.teal,
            ),
            const SizedBox(height: 40),

            // Control button
            ElevatedButton.icon(
              onPressed: () => counter.value++,
              icon: const Icon(Icons.add),
              label: const Text('Trigger All Effects'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectDemo(String label, SlotEffect effect, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        AnimatedSlot<int>(
          connect: counter,
          effect: effect | SlotEffect.fade,
          duration: const Duration(milliseconds: 600),
          to: (context, value) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: DramaticEffectsExample(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
