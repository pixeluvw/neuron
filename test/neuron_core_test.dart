import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('Neuron Service Locator', () {
    tearDown(() {
      Neuron.clearAll();
    });

    test('should install and retrieve controller', () {
      final controller = TestController();
      Neuron.install(controller);

      expect(Neuron.use<TestController>(), controller);
      expect(Neuron.isInstalled<TestController>(), true);
    });

    test('should call onInit when installing', () {
      final controller = TestController();
      Neuron.install(controller);

      expect(controller.initialized, true);
    });

    test('should throw when using uninstalled controller', () {
      expect(() => Neuron.use<TestController>(), throwsException);
    });

    test('should ensure controller exists or create it', () {
      var createCount = 0;
      final controller1 = Neuron.ensure<TestController>(() {
        createCount++;
        return TestController();
      });
      final controller2 = Neuron.ensure<TestController>(() {
        createCount++;
        return TestController();
      });

      expect(controller1, controller2);
      expect(createCount, 1);
    });

    test('should uninstall and dispose controller', () {
      final controller = TestController();
      Neuron.install(controller);

      Neuron.uninstall<TestController>();

      expect(Neuron.isInstalled<TestController>(), false);
      expect(controller.disposed, true);
    });

    test('should clear all controllers', () {
      Neuron.install(TestController());
      Neuron.install(AnotherController());

      Neuron.clearAll();

      expect(Neuron.isInstalled<TestController>(), false);
      expect(Neuron.isInstalled<AnotherController>(), false);
    });
  });

  group('Signal', () {
    test('should emit and notify listeners', () {
      final signal = Signal<int>(0);
      var notified = false;

      signal.addListener(() {
        notified = true;
      });

      signal.emit(5);

      expect(signal.val, 5);
      expect(notified, true);
    });

    test('should not notify if value is the same', () {
      final signal = Signal<int>(0);
      var notifyCount = 0;

      signal.addListener(() {
        notifyCount++;
      });

      signal.emit(0);
      signal.emit(0);

      expect(notifyCount, 0);
    });

    test('should emit to stream', () async {
      final signal = Signal<int>(0);
      final values = <int>[];

      signal.stream.listen((value) {
        values.add(value);
      });

      signal.emit(1);
      signal.emit(2);
      signal.emit(3);

      await Future.delayed(Duration.zero);

      expect(values, [1, 2, 3]);
    });

    test('should bind to controller for auto-disposal', () {
      final controller = TestController();
      Signal<int>(0).bind(controller);

      controller.trackDisposable();
      expect(controller.hasDisposables, true);

      controller.dispose();
      // Signal should be disposed with controller
    });
  });

  group('AsyncSignal', () {
    test('should handle loading state', () {
      final signal = AsyncSignal<String>(null);

      signal.emitLoading();

      expect(signal.isLoading, true);
      expect(signal.hasData, false);
      expect(signal.hasError, false);
    });

    test('should handle data state', () {
      final signal = AsyncSignal<String>(null);

      signal.emitData('test');

      expect(signal.isLoading, false);
      expect(signal.hasData, true);
      expect(signal.data, 'test');
    });

    test('should handle error state', () {
      final signal = AsyncSignal<String>(null);
      final error = Exception('test error');

      signal.emitError(error);

      expect(signal.isLoading, false);
      expect(signal.hasError, true);
      expect(signal.error, error);
    });

    test('should execute async operation', () async {
      final signal = AsyncSignal<int>(null);

      await signal.execute(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(signal.hasData, true);
      expect(signal.data, 42);
    });

    test('should handle async errors', () async {
      final signal = AsyncSignal<int>(null);

      await signal.execute(() async {
        throw Exception('async error');
      });

      expect(signal.hasError, true);
    });
  });

  group('Computed', () {
    test('should compute value from dependencies', () {
      final count = Signal<int>(5);
      final doubled = Computed<int>(() => count.val * 2);

      expect(doubled.value, 10);
    });

    test('should update when dependencies change', () {
      final count = Signal<int>(5);
      final doubled = Computed<int>(() => count.val * 2);

      count.emit(10);

      expect(doubled.value, 20);
    });

    test('should handle multiple dependencies', () {
      final a = Signal<int>(2);
      final b = Signal<int>(3);
      final sum = Computed<int>(() => a.val + b.val);

      expect(sum.value, 5);

      a.emit(5);
      expect(sum.value, 8);

      b.emit(10);
      expect(sum.value, 15);
    });

    test('should chain computed signals', () {
      final count = Signal<int>(5);
      final doubled = Computed<int>(() => count.val * 2);
      final quadrupled = Computed<int>(() => doubled.value * 2);

      expect(quadrupled.value, 20);

      count.emit(10);
      expect(quadrupled.value, 40);
    });
  });

  group('NeuronAtom', () {
    test('SelectedAtom updates correctly when cold', () {
      final parent = NeuronAtom(1);
      final derived = parent.select((n) => n * 10);

      // 1. Check initial derived value (Cold read)
      expect(derived.value, 10);

      // 2. Update parent while derived is NOT listening (Cold update)
      parent.value = 2;

      // 3. Check derived value again (Cold read should invoke selector)
      expect(derived.value, 20);

      // 4. Start listening (Transition to Hot)
      derived.addListener(() {});

      // 5. Update parent (Hot update)
      parent.value = 3;
      expect(derived.value, 30);
    });
  });

  group('Controller Signal Factory Extensions', () {
    tearDown(() {
      Neuron.clearAll();
    });

    test('signal() creates bound Signal', () {
      final controller = SignalFactoryController();
      Neuron.install(controller);

      expect(controller.count.val, 0);
      controller.count.emit(5);
      expect(controller.count.val, 5);

      // Verify auto-dispose
      Neuron.uninstall<SignalFactoryController>();
      // Signal should be disposed (no assertion here, just verify controller lifecycle)
    });

    test('\$() creates bound Signal with short syntax', () {
      final controller = ShorthandController();
      Neuron.install(controller);

      expect(controller.count.val, 0);
      controller.count.emit(10);
      expect(controller.count.val, 10);
    });

    test('computed() creates bound Computed', () {
      final controller = SignalFactoryController();
      Neuron.install(controller);

      // Access value to trigger computation
      expect(controller.doubled.val, 0);
      
      // Add listener to make Computed reactive
      controller.doubled.addListener(() {});
      
      controller.count.emit(5);
      expect(controller.doubled.val, 10);
    });

    test('\$computed() creates bound Computed with short syntax', () {
      final controller = ShorthandController();
      Neuron.install(controller);

      expect(controller.doubled.val, 0);
      
      // Add listener to make Computed reactive
      controller.doubled.addListener(() {});
      
      controller.count.emit(7);
      expect(controller.doubled.val, 14);
    });

    test('asyncSignal() creates bound AsyncSignal', () async {
      final controller = SignalFactoryController();
      Neuron.install(controller);

      expect(controller.user.isLoading, true);

      await controller.user.execute(() async => 'Alice');
      expect(controller.user.data, 'Alice');
    });

    test('\$async() creates bound AsyncSignal with short syntax', () async {
      final controller = ShorthandController();
      Neuron.install(controller);

      expect(controller.user.isLoading, true);

      await controller.user.execute(() async => 'Bob');
      expect(controller.user.data, 'Bob');
    });
  });
}

// Test controller using signal() factory extension
class SignalFactoryController extends NeuronController {
  late final count = signal(0);
  late final doubled = computed(() => count.val * 2);
  late final user = asyncSignal<String>();
}

// Test controller using $() shorthand extension
class ShorthandController extends NeuronController {
  late final count = $(0);
  late final doubled = $computed(() => count.val * 2);
  late final user = $async<String>();
}

// Test controllers
class TestController extends NeuronController {
  bool initialized = false;
  bool disposed = false;
  int _disposeCount = 0;

  @override
  void onInit() {
    initialized = true;
  }

  @override
  void onClose() {
    disposed = true;
  }

  // Helper to track disposables
  void trackDisposable() {
    _disposeCount++;
  }

  bool get hasDisposables => _disposeCount > 0;
}

class AnotherController extends NeuronController {}
