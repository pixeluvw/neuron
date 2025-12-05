import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neuron/neuron.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATED SLOT SHOWCASE
/// Interactive examples with live code preview
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// 1. FADE & SCALE SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class FadeScaleShowcase extends StatefulWidget {
  const FadeScaleShowcase({super.key});

  @override
  State<FadeScaleShowcase> createState() => _FadeScaleShowcaseState();
}

class _FadeScaleShowcaseState extends State<FadeScaleShowcase> {
  final counter = Signal<int>(0);
  final status = Signal<String>('Idle');
  final rating = Signal<int>(3);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Fade & Scale Effects',
      subtitle: 'Smooth opacity and scale transitions',
      examples: [
        // Example 1: Bouncy Counter
        CodeExample(
          title: 'Bouncy Counter',
          description: 'Scale with elastic curve for satisfying taps',
          code: '''
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.fadeScale,
  duration: Duration(milliseconds: 400),
  curve: Curves.elasticOut,
  scaleBegin: 0.3,
  scaleEnd: 1.0,
  to: (context, value) => Text(
    '\$value',
    style: TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.bold,
      color: value >= 0 ? Colors.green : Colors.red,
    ),
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: counter,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            scaleBegin: 0.3,
            scaleEnd: 1.0,
            to: (context, value) => Text(
              '$value',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: value >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
          controls: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.remove,
                onPressed: () => counter.value--,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.add,
                onPressed: () => counter.value++,
              ),
            ],
          ),
        ),

        // Example 2: Status Badge
        CodeExample(
          title: 'Status Badge',
          description: 'Fade with subtle scale for status updates',
          code: '''
AnimatedSlot<String>(
  connect: status,
  effect: SlotEffect.fadeScale,
  duration: Duration(milliseconds: 300),
  scaleBegin: 0.8,
  scaleEnd: 1.0,
  to: (context, value) => _StatusBadge(status: value),
)''',
          demo: AnimatedSlot<String>(
            connect: status,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 300),
            scaleBegin: 0.8,
            scaleEnd: 1.0,
            to: (context, value) => _StatusBadge(status: value),
          ),
          controls: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Idle', 'Loading', 'Success', 'Error'].map((s) {
              return _ChipButton(
                label: s,
                onPressed: () => status.value = s,
              );
            }).toList(),
          ),
        ),

        // Example 3: Star Rating
        CodeExample(
          title: 'Star Rating',
          description: 'Pop-in effect using elastic curve',
          code: '''
AnimatedSlot<int>(
  connect: rating,
  effect: SlotEffect.scale,
  duration: Duration(milliseconds: 500),
  curve: Curves.elasticOut,
  scaleBegin: 0.0,
  scaleEnd: 1.0,
  to: (context, value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => Icon(
      i < value ? Icons.star : Icons.star_border,
      color: Colors.amber,
      size: 40,
    )),
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: rating,
            effect: SlotEffect.scale,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            scaleBegin: 0.0,
            scaleEnd: 1.0,
            to: (context, value) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  i < value ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                );
              }),
            ),
          ),
          controls: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () => rating.value = i + 1,
                tooltip: '${i + 1} stars',
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      'Loading' => (Colors.orange, Icons.hourglass_top),
      'Success' => (Colors.green, Icons.check_circle),
      'Error' => (Colors.red, Icons.error),
      _ => (Colors.grey, Icons.circle_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. DIRECTIONAL SLIDE SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class DirectionalSlideShowcase extends StatefulWidget {
  const DirectionalSlideShowcase({super.key});

  @override
  State<DirectionalSlideShowcase> createState() =>
      _DirectionalSlideShowcaseState();
}

class _DirectionalSlideShowcaseState extends State<DirectionalSlideShowcase> {
  final counter = Signal<int>(0);
  final page = Signal<int>(0);
  final temperature = Signal<int>(20);

  final pages = [
    {'icon': Icons.home, 'label': 'Home', 'color': Colors.blue},
    {'icon': Icons.search, 'label': 'Search', 'color': Colors.green},
    {'icon': Icons.person, 'label': 'Profile', 'color': Colors.purple},
    {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Directional Slide',
      subtitle: 'Value-aware slide direction',
      examples: [
        // Example 1: Number Slider (Vertical)
        CodeExample(
          title: 'Vertical Number Slider',
          description: 'Slides up/down based on value change',
          code: '''
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.fadeSlide,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutCubic,
  directionalEffect: DirectionalEffect.vertical,
  slideOffset: Offset(0, 0.5),
  to: (context, value) => Text(
    '\$value',
    style: TextStyle(fontSize: 72, fontWeight: FontWeight.w700),
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: counter,
            effect: SlotEffect.fadeSlide,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            directionalEffect: DirectionalEffect.vertical,
            slideOffset: const Offset(0, 0.5),
            to: (context, value) => Text(
              '$value',
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w700),
            ),
          ),
          controls: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.arrow_downward,
                onPressed: () => counter.value--,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.arrow_upward,
                onPressed: () => counter.value++,
              ),
            ],
          ),
        ),

        // Example 2: Horizontal Carousel
        CodeExample(
          title: 'Horizontal Carousel',
          description: 'Slides left/right based on navigation',
          code: '''
AnimatedSlot<int>(
  connect: page,
  effect: SlotEffect.fadeSlide,
  duration: Duration(milliseconds: 400),
  curve: Curves.easeInOutCubic,
  directionalEffect: DirectionalEffect.horizontal,
  slideOffset: Offset(0.3, 0),
  to: (context, value) => _PageCard(
    icon: pages[value]['icon'],
    label: pages[value]['label'],
    color: pages[value]['color'],
  ),
)''',
          demo: SizedBox(
            height: 120,
            width: double.infinity,
            child: AnimatedSlot<int>(
              connect: page,
              effect: SlotEffect.fadeSlide,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              directionalEffect: DirectionalEffect.horizontal,
              slideOffset: const Offset(0.3, 0),
              to: (context, value) {
                final item = pages[value];
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: item['color'] as Color, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData,
                          size: 40, color: item['color'] as Color),
                      const SizedBox(height: 8),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: item['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          controls: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.chevron_left,
                onPressed: () =>
                    page.value = (page.value - 1).clamp(0, pages.length - 1),
              ),
              const SizedBox(width: 8),
              Slot(
                connect: page,
                to: (context, value) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${value + 1} / ${pages.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.chevron_right,
                onPressed: () =>
                    page.value = (page.value + 1).clamp(0, pages.length - 1),
              ),
            ],
          ),
        ),

        // Example 3: Temperature Gauge
        CodeExample(
          title: 'Temperature Gauge',
          description: 'Combined slide + scale with vertical direction',
          code: '''
AnimatedSlot<int>(
  connect: temperature,
  effect: SlotEffect.fadeSlide | SlotEffect.scale,
  duration: Duration(milliseconds: 350),
  curve: Curves.easeOutBack,
  directionalEffect: DirectionalEffect.vertical,
  slideOffset: Offset(0, 0.3),
  scaleBegin: 0.9,
  scaleEnd: 1.0,
  to: (context, value) => _TemperatureCard(value: value),
)''',
          demo: AnimatedSlot<int>(
            connect: temperature,
            effect: SlotEffect.fadeSlide | SlotEffect.scale,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            directionalEffect: DirectionalEffect.vertical,
            slideOffset: const Offset(0, 0.3),
            scaleBegin: 0.9,
            scaleEnd: 1.0,
            to: (context, value) {
              // Temperature categories
              final (Color startColor, Color endColor, String label) =
                  switch (value) {
                <= 0 => (
                    Colors.cyan.shade700,
                    Colors.cyan.shade400,
                    '🥶 Freezing'
                  ),
                < 15 => (Colors.blue, Colors.lightBlue, '❄️ Cold'),
                <= 25 => (Colors.green, Colors.teal, '✨ Comfortable'),
                _ => (Colors.red, Colors.orange, '🔥 Hot'),
              };

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [startColor, endColor]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: startColor.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$value°C',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      label,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          controls: Slot(
            connect: temperature,
            to: (context, temp) => Slider(
              value: temp.toDouble(),
              min: -10,
              max: 40,
              divisions: 50,
              label: '$temp°C',
              onChanged: (v) => temperature.value = v.round(),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. BLUR EFFECTS SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class BlurEffectsShowcase extends StatefulWidget {
  const BlurEffectsShowcase({super.key});

  @override
  State<BlurEffectsShowcase> createState() => _BlurEffectsShowcaseState();
}

class _BlurEffectsShowcaseState extends State<BlurEffectsShowcase> {
  final message = Signal<String>('Welcome!');
  final image = Signal<int>(0);
  final notification = Signal<String>('');

  final messages = ['Welcome!', 'Hello World', 'Flutter Rocks', 'Neuron!'];
  final images = [Colors.purple, Colors.teal, Colors.amber, Colors.pink];

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Blur Effects',
      subtitle: 'Gaussian blur transitions',
      examples: [
        // Example 1: Message Blur
        CodeExample(
          title: 'Message Blur',
          description: 'Blur out old content, blur in new',
          code: '''
AnimatedSlot<String>(
  connect: message,
  effect: SlotEffect.fadeBlur,
  duration: Duration(milliseconds: 400),
  blurSigma: 8.0,
  to: (context, value) => Container(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(value, style: TextStyle(fontSize: 24)),
  ),
)''',
          demo: AnimatedSlot<String>(
            connect: message,
            effect: SlotEffect.fadeBlur,
            duration: const Duration(milliseconds: 400),
            blurSigma: 8.0,
            to: (context, value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          controls: ElevatedButton.icon(
            onPressed: () {
              final current = messages.indexOf(message.value);
              message.value = messages[(current + 1) % messages.length];
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Next Message'),
          ),
        ),

        // Example 2: Gallery Blur
        CodeExample(
          title: 'Gallery Blur',
          description: 'Smooth image transitions with blur + scale',
          code: '''
AnimatedSlot<int>(
  connect: image,
  effect: SlotEffect.blur | SlotEffect.scale,
  duration: Duration(milliseconds: 500),
  blurSigma: 12.0,
  scaleBegin: 0.95,
  scaleEnd: 1.0,
  to: (context, value) => _GalleryCard(
    color: images[value],
    index: value,
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: image,
            effect: SlotEffect.blur | SlotEffect.scale,
            duration: const Duration(milliseconds: 500),
            blurSigma: 12.0,
            scaleBegin: 0.95,
            scaleEnd: 1.0,
            to: (context, value) => Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: images[value],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: images[value].withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Image ${value + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          controls: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => image.value = i,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: images[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: images[i].withAlpha(100),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Example 3: Toast Notification
        CodeExample(
          title: 'Toast Notifications',
          description: 'Blur + slide for toast messages',
          code: '''
AnimatedSlot<String>(
  connect: notification,
  effect: SlotEffect.fadeBlur | SlotEffect.slideDown,
  duration: Duration(milliseconds: 350),
  curve: Curves.easeOutBack,
  blurSigma: 5.0,
  slideOffset: Offset(0, 0.5),
  to: (context, value) => value.isEmpty
      ? SizedBox.shrink()
      : _ToastMessage(message: value),
)''',
          demo: AnimatedSlot<String>(
            connect: notification,
            effect: SlotEffect.fadeBlur | SlotEffect.slideDown,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            blurSigma: 5.0,
            slideOffset: const Offset(0, 0.5),
            to: (context, value) => value.isEmpty
                ? const SizedBox(height: 48)
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ),
          controls: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _ChipButton(
                  label: '💾 Saved!',
                  onPressed: () => notification.value = '💾 Saved!'),
              _ChipButton(
                  label: '🗑️ Deleted!',
                  onPressed: () => notification.value = '🗑️ Deleted!'),
              _ChipButton(
                  label: '✅ Updated!',
                  onPressed: () => notification.value = '✅ Updated!'),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. SPRING PHYSICS SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class SpringPhysicsShowcase extends StatefulWidget {
  const SpringPhysicsShowcase({super.key});

  @override
  State<SpringPhysicsShowcase> createState() => _SpringPhysicsShowcaseState();
}

class _SpringPhysicsShowcaseState extends State<SpringPhysicsShowcase> {
  final bounceValue = Signal<int>(0);
  final wobblyValue = Signal<int>(0);
  final snappyValue = Signal<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Spring Physics',
      subtitle: 'Realistic spring-based animations',
      examples: [
        // Example 1: Bouncy Spring
        CodeExample(
          title: 'Bouncy Spring',
          description: 'Elastic curve with overshoot',
          code: '''
AnimatedSlot<int>(
  connect: bounceValue,
  effect: SlotEffect.fadeScale,
  duration: Duration(milliseconds: 600),
  curve: Curves.elasticOut,
  scaleBegin: 0.0,
  scaleEnd: 1.0,
  to: (context, value) => _SpringBox(
    color: Colors.deepPurple,
    value: value,
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: bounceValue,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            scaleBegin: 0.0,
            scaleEnd: 1.0,
            to: (context, value) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          controls: ElevatedButton.icon(
            onPressed: () => bounceValue.value++,
            icon: const Icon(Icons.add),
            label: const Text('Bounce!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // Example 2: Wobbly Spring
        CodeExample(
          title: 'Wobbly Spring',
          description: 'Bounce curve with rotation',
          code: '''
AnimatedSlot<int>(
  connect: wobblyValue,
  effect: SlotEffect.fadeScale | SlotEffect.rotation,
  duration: Duration(milliseconds: 800),
  curve: Curves.bounceOut,
  scaleBegin: 0.5,
  scaleEnd: 1.0,
  rotationTurns: 0.1,
  to: (context, value) => _SpringBall(
    color: Colors.orange,
    value: value,
  ),
)''',
          demo: AnimatedSlot<int>(
            connect: wobblyValue,
            effect: SlotEffect.fadeScale | SlotEffect.rotation,
            duration: const Duration(milliseconds: 800),
            curve: Curves.bounceOut,
            scaleBegin: 0.5,
            scaleEnd: 1.0,
            rotationTurns: 0.1,
            to: (context, value) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          controls: ElevatedButton.icon(
            onPressed: () => wobblyValue.value++,
            icon: const Icon(Icons.autorenew),
            label: const Text('Wobble!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // Example 3: Snappy Toggle
        CodeExample(
          title: 'Snappy Toggle',
          description: 'Quick easeOutBack with slide',
          code: '''
AnimatedSlot<bool>(
  connect: snappyValue,
  effect: SlotEffect.fadeScale | SlotEffect.slideLeft,
  duration: Duration(milliseconds: 250),
  curve: Curves.easeOutBack,
  scaleBegin: 0.8,
  scaleEnd: 1.0,
  slideOffset: Offset(0.2, 0),
  to: (context, value) => _ToggleCard(isOn: value),
)''',
          demo: AnimatedSlot<bool>(
            connect: snappyValue,
            effect: SlotEffect.fadeScale | SlotEffect.slideLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            scaleBegin: 0.8,
            scaleEnd: 1.0,
            slideOffset: const Offset(0.2, 0),
            to: (context, value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                color: value ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (value ? Colors.green : Colors.grey).withAlpha(100),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    value ? 'ON' : 'OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          controls: ElevatedButton.icon(
            onPressed: () => snappyValue.value = !snappyValue.value,
            icon: const Icon(Icons.toggle_on),
            label: const Text('Toggle'),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. GESTURE ANIMATIONS SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class GestureAnimationsShowcase extends StatefulWidget {
  const GestureAnimationsShowcase({super.key});

  @override
  State<GestureAnimationsShowcase> createState() =>
      _GestureAnimationsShowcaseState();
}

class _GestureAnimationsShowcaseState extends State<GestureAnimationsShowcase> {
  final isPressed = Signal<bool>(false);
  final likeCount = Signal<int>(42);
  final dragValue = Signal<double>(0.5);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Gesture Animations',
      subtitle: 'Responsive touch feedback',
      examples: [
        // Example 1: Press & Hold
        CodeExample(
          title: 'Press & Hold',
          description: 'Scale down on press, spring back on release',
          code: '''
GestureDetector(
  onTapDown: (_) => isPressed.value = true,
  onTapUp: (_) => isPressed.value = false,
  onTapCancel: () => isPressed.value = false,
  child: AnimatedSlot<bool>(
    connect: isPressed,
    effect: SlotEffect.scale,
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOutBack,
    to: (context, pressed) => _PressableBox(
      isPressed: pressed,
    ),
  ),
)''',
          demo: GestureDetector(
            onTapDown: (_) => isPressed.value = true,
            onTapUp: (_) => isPressed.value = false,
            onTapCancel: () => isPressed.value = false,
            child: AnimatedSlot<bool>(
              connect: isPressed,
              effect: SlotEffect.scale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              scaleBegin: 0.9,
              scaleEnd: 1.0,
              to: (context, pressed) => Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: pressed ? Colors.blue.shade700 : Colors.blue,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(pressed ? 50 : 100),
                      blurRadius: pressed ? 10 : 25,
                      offset: Offset(0, pressed ? 4 : 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.touch_app, color: Colors.white, size: 56),
                ),
              ),
            ),
          ),
          controls: const Text(
            'Tap and hold the button above!',
            style: TextStyle(color: Colors.grey),
          ),
        ),

        // Example 2: Like Button
        CodeExample(
          title: 'Like Button',
          description: 'Heart animation with count update',
          code: '''
Row(
  children: [
    AnimatedSlot<int>(
      connect: likeCount,
      effect: SlotEffect.scale,
      duration: Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      scaleBegin: 0.5,
      to: (context, _) => Icon(Icons.favorite, 
        color: Colors.red, size: 48),
    ),
    AnimatedSlot<int>(
      connect: likeCount,
      effect: SlotEffect.fadeSlide,
      directionalEffect: DirectionalEffect.vertical,
      to: (context, value) => Text('\$value'),
    ),
  ],
)''',
          demo: GestureDetector(
            onTap: () => likeCount.value++,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlot<int>(
                  connect: likeCount,
                  effect: SlotEffect.scale,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  scaleBegin: 0.5,
                  scaleEnd: 1.0,
                  to: (context, value) => const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 56,
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedSlot<int>(
                  connect: likeCount,
                  effect: SlotEffect.fadeSlide,
                  duration: const Duration(milliseconds: 200),
                  directionalEffect: DirectionalEffect.vertical,
                  to: (context, value) => Text(
                    '$value',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          controls: const Text(
            'Tap the heart to like!',
            style: TextStyle(color: Colors.grey),
          ),
        ),

        // Example 3: Drag Progress
        CodeExample(
          title: 'Drag Progress',
          description: 'Smooth value changes with gestures',
          code: '''
Column(
  children: [
    Slider(
      value: dragValue.value,
      onChanged: (v) => dragValue.value = v,
    ),
    AnimatedSlot<double>(
      connect: dragValue,
      effect: SlotEffect.fadeScale,
      duration: Duration(milliseconds: 100),
      to: (context, value) => _ProgressBar(
        progress: value,
      ),
    ),
  ],
)''',
          demo: Column(
            children: [
              Slot(
                connect: dragValue,
                to: (context, value) => Slider(
                  value: value,
                  onChanged: (v) => dragValue.value = v,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSlot<double>(
                connect: dragValue,
                effect: SlotEffect.fadeScale,
                duration: const Duration(milliseconds: 100),
                to: (context, value) => Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: const [Colors.blue, Colors.purple],
                      stops: [0, value],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          controls: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. PULSE & SHIMMER SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════════

class PulseShimmerShowcase extends StatefulWidget {
  const PulseShimmerShowcase({super.key});

  @override
  State<PulseShimmerShowcase> createState() => _PulseShimmerShowcaseState();
}

class _PulseShimmerShowcaseState extends State<PulseShimmerShowcase> {
  final isLoading = Signal<bool>(true);
  final hasNotification = Signal<bool>(true);
  final isLive = Signal<bool>(true);

  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _startLoadingCycle();
  }

  void _startLoadingCycle() {
    _loadingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      isLoading.value = !isLoading.value;
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Pulse & Shimmer',
      subtitle: 'Attention-grabbing effects',
      examples: [
        // Example 1: Loading Skeleton
        CodeExample(
          title: 'Loading Skeleton',
          description: 'Shimmer effect for loading states',
          code: '''
AnimatedSlot<bool>(
  connect: isLoading,
  effect: SlotEffect.fadeBlur,
  duration: Duration(milliseconds: 400),
  blurSigma: 4.0,
  to: (context, loading) => loading
      ? ShimmerBox(width: 200, height: 80)
      : LoadedContent(),
)''',
          demo: AnimatedSlot<bool>(
            connect: isLoading,
            effect: SlotEffect.fadeBlur,
            duration: const Duration(milliseconds: 400),
            blurSigma: 4.0,
            to: (context, loading) => loading
                ? const _ShimmerBox(width: 220, height: 90)
                : Container(
                    width: 220,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'Content Loaded!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          controls: ElevatedButton.icon(
            onPressed: () => isLoading.value = !isLoading.value,
            icon: const Icon(Icons.refresh),
            label: const Text('Toggle Loading'),
          ),
        ),

        // Example 2: Notification Badge
        CodeExample(
          title: 'Notification Badge',
          description: 'Pulsing attention indicator',
          code: '''
AnimatedSlot<bool>(
  connect: hasNotification,
  effect: SlotEffect.fadeScale,
  duration: Duration(milliseconds: 300),
  curve: Curves.elasticOut,
  scaleBegin: 0.0,
  scaleEnd: 1.0,
  to: (context, hasNotif) => Stack(
    children: [
      NotificationIcon(),
      if (hasNotif) PulsingBadge(),
    ],
  ),
)''',
          demo: AnimatedSlot<bool>(
            connect: hasNotification,
            effect: SlotEffect.fade,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            to: (context, hasNotif) => Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.notifications, size: 40),
                  ),
                  if (hasNotif)
                    const Positioned(
                      right: -6,
                      top: -6,
                      child: _PulsingBadge(),
                    ),
                ],
              ),
            ),
          ),
          controls: AnimatedSlot<bool>(
            connect: hasNotification,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            scaleBegin: 0.9,
            scaleEnd: 1.0,
            to: (context, value) => ElevatedButton.icon(
              onPressed: () => hasNotification.value = !hasNotification.value,
              icon: Icon(
                  value ? Icons.notifications_off : Icons.notifications_active),
              label: const Text('Toggle Notification'),
            ),
          ),
        ),

        // Example 3: Live Indicator
        CodeExample(
          title: 'Live Indicator',
          description: 'Pulsing live status badge',
          code: '''
AnimatedSlot<bool>(
  connect: isLive,
  effect: SlotEffect.fadeScale,
  duration: Duration(milliseconds: 400),
  scaleBegin: 0.8,
  scaleEnd: 1.0,
  to: (context, live) => LiveBadge(isLive: live),
)''',
          demo: AnimatedSlot<bool>(
            connect: isLive,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 400),
            scaleBegin: 0.8,
            scaleEnd: 1.0,
            to: (context, live) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: live ? Colors.red : Colors.grey,
                borderRadius: BorderRadius.circular(24),
                boxShadow: live
                    ? [
                        BoxShadow(
                          color: Colors.red.withAlpha(100),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (live)
                    const _PulsingDot()
                  else
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    live ? 'LIVE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          controls: AnimatedSlot<bool>(
            connect: isLive,
            effect: SlotEffect.fadeScale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            scaleBegin: 0.9,
            scaleEnd: 1.0,
            to: (context, live) => ElevatedButton.icon(
              onPressed: () => isLive.value = !isLive.value,
              icon: Icon(live ? Icons.stop_circle : Icons.play_circle),
              label: Text(live ? 'Go Offline' : 'Go Live'),
              style: ElevatedButton.styleFrom(
                backgroundColor: live ? Colors.grey : Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATED HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingBadge extends StatefulWidget {
  const _PulsingBadge();

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(120),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color:
                Colors.white.withAlpha((150 + 105 * _controller.value).toInt()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LAYOUT & UI COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class ShowcasePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CodeExample> examples;

  const ShowcasePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Examples
          ...examples.map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: example,
              )),
        ],
      ),
    );
  }
}

class CodeExample extends StatefulWidget {
  final String title;
  final String description;
  final String code;
  final Widget demo;
  final Widget controls;

  const CodeExample({
    super.key,
    required this.title,
    required this.description,
    required this.code,
    required this.demo,
    required this.controls,
  });

  @override
  State<CodeExample> createState() => _CodeExampleState();
}

class _CodeExampleState extends State<CodeExample> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                // Code toggle button
                IconButton.filled(
                  onPressed: () => setState(() => _showCode = !_showCode),
                  icon: Icon(_showCode ? Icons.visibility_off : Icons.code),
                  tooltip: _showCode ? 'Hide Code' : 'Show Code',
                ),
              ],
            ),
          ),

          // Demo area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            ),
            child: Center(child: widget.demo),
          ),

          // Controls
          if (widget.controls is! SizedBox)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Center(child: widget.controls),
            ),

          // Code panel (expandable)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showCode
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Dart',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        color: Colors.grey,
                        tooltip: 'Copy code',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    widget.code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF9CDCFE),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ChipButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
