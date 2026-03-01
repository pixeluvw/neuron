import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';
import 'dart:async';

void main() {
  group('Vectorized Computation Tests', () {
    test('SIMD float processing off-thread', () async {
      // Simulate matrix multiplication / image processing array using SIMD lists
      final vectorSignal = IsolateSignal<Float32x4List, Float32x4List>(
        Float32x4List(1000), // Initial dummy message
        (Float32x4List input) {
          final result = Float32x4List(input.length);
          // SIMD vectorized scaling
          final scale = Float32x4.splat(2.5);
          for (int i = 0; i < input.length; i++) {
            result[i] = input[i] * scale;
          }
          return result;
        },
      );

      final buffer = Float32x4List(100);
      for (int i = 0; i < buffer.length; i++) {
        buffer[i] = Float32x4(1.0, 2.0, 3.0, 4.0);
      }

      vectorSignal.compute(buffer);

      final completer = Completer<Float32x4List>();
      vectorSignal.subscribe(() {
        if (vectorSignal.state.hasData && !completer.isCompleted) {
          completer
              .complete((vectorSignal.state as AsyncData<Float32x4List>).value);
        }
      });

      final output = await completer.future;

      // Verify SIMD math operated correctly in isolate
      expect(output.length, 100);
      expect(output[0].x, 2.5);
      expect(output[0].y, 5.0);
      expect(output[0].z, 7.5);
      expect(output[0].w, 10.0);

      vectorSignal.dispose();
    });
  });
}
