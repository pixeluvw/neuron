// Quick test to verify auto-registration works
import 'package:neuron/neuron.dart';

void main() {
  // Enable DevTools
  SignalDevTools().setEnabled(true);

  print('✨ Testing Auto-Registration...\n');

  // Create a test controller
  final controller = TestController();

  // Check registered signals
  final registered = SignalDevTools().signals;
  print('📊 Registered Signals:');
  registered.forEach((id, signal) {
    print('  - $id: ${signal.value}');
  });

  // Test signal changes
  print('\n🔄 Changing signal values...');
  controller.counter.emit(42);
  controller.name.emit('Neuron');

  print('\n✅ Auto-registration test complete!');
  print('   Total signals registered: ${registered.length}');
}

class TestController extends NeuronController {
  // Signals with debugLabel
  final counter = Signal<int>(0, debugLabel: 'counter');
  final name = Signal<String>('test', debugLabel: 'name');

  // Signal without debugLabel (will use auto-generated ID)
  final unnamed = Signal<bool>(false);

  // Computed signal
  late final doubled = Computed<int>(
    () => counter.val * 2,
    [counter],
  );

  TestController() {
    counter.bind(this);
    name.bind(this);
    unnamed.bind(this);
    doubled.bind(this);
  }
}
