import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('UndoableSignal', () {
    test('tracks initial value in history', () {
      final signal = UndoableSignal<int>(0);

      expect(signal.val, 0);
      expect(signal.historySize, 1);
      expect(signal.canUndo, false);
      expect(signal.canRedo, false);
    });

    test('undo restores previous value', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.emit(2);

      signal.undo();

      expect(signal.val, 1);
      expect(signal.canUndo, true);
      expect(signal.canRedo, true);
    });

    test('redo restores next value', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.emit(2);

      signal.undo();
      signal.redo();

      expect(signal.val, 2);
      expect(signal.canRedo, false);
    });

    test('undo at beginning does nothing', () {
      final signal = UndoableSignal<int>(0);
      signal.undo();
      expect(signal.val, 0);
    });

    test('redo at end does nothing', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.redo();
      expect(signal.val, 1);
    });

    test('emit after undo discards redo history', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.emit(2);
      signal.emit(3);

      signal.undo(); // back to 2
      signal.undo(); // back to 1

      signal.emit(10); // new branch

      expect(signal.val, 10);
      expect(signal.canRedo, false);
      expect(signal.history, [0, 1, 10]);
    });

    test('respects maxHistory limit', () {
      final signal = UndoableSignal<int>(0, maxHistory: 3);

      signal.emit(1);
      signal.emit(2);
      signal.emit(3); // should evict 0

      expect(signal.historySize, 3);
      expect(signal.history, [1, 2, 3]);
    });

    test('clearHistory resets to current value', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.emit(2);

      signal.clearHistory();

      expect(signal.val, 2);
      expect(signal.historySize, 1);
      expect(signal.canUndo, false);
      expect(signal.canRedo, false);
    });

    test('emitting same value is a no-op', () {
      final signal = UndoableSignal<int>(0);
      signal.emit(1);
      signal.emit(1); // same value

      expect(signal.historySize, 2); // 0, 1
    });

    test('multiple undo/redo cycles work correctly', () {
      final signal = UndoableSignal<String>('a');
      signal.emit('b');
      signal.emit('c');
      signal.emit('d');

      signal.undo(); // c
      signal.undo(); // b
      signal.redo(); // c
      signal.undo(); // b
      signal.undo(); // a

      expect(signal.val, 'a');
      expect(signal.canUndo, false);
      expect(signal.canRedo, true);
    });
  });

  group('FormSignal', () {
    test('initializes with valid state', () {
      final form = FormSignal<String>('');

      expect(form.val, '');
      expect(form.isDirty, false);
      expect(form.isTouched, false);
      expect(form.isPristine, true);
      expect(form.isUntouched, true);
    });

    test('emit marks as dirty', () {
      final form = FormSignal<String>('');
      form.emit('hello');

      expect(form.val, 'hello');
      expect(form.isDirty, true);
    });

    test('markAsTouched sets touched flag', () {
      final form = FormSignal<String>('');
      form.markAsTouched();

      expect(form.isTouched, true);
      expect(form.isUntouched, false);
    });

    test('markAsPristine resets dirty flag', () {
      final form = FormSignal<String>('');
      form.emit('changed');
      form.markAsPristine();

      expect(form.isDirty, false);
      expect(form.isPristine, true);
    });

    test('validates with required validator', () {
      final form = FormSignal<String>(
        '',
        validators: [Validators.required('Required')],
      );

      expect(form.isInvalid, true);
      expect(form.error, 'Required');

      form.emit('filled');
      expect(form.isValid, true);
      expect(form.error, null);
    });

    test('validates with minLength', () {
      final form = FormSignal<String>(
        '',
        validators: [Validators.minLength(3, 'Too short')],
      );

      form.emit('ab');
      expect(form.isInvalid, true);
      expect(form.error, 'Too short');

      form.emit('abc');
      expect(form.isValid, true);
    });

    test('validates with maxLength', () {
      final form = FormSignal<String>(
        '',
        validators: [Validators.maxLength(5, 'Too long')],
      );

      form.emit('hello!');
      expect(form.isInvalid, true);

      form.emit('hi');
      expect(form.isValid, true);
    });

    test('validates with email pattern', () {
      final form = FormSignal<String>(
        '',
        validators: [Validators.email('Invalid email')],
      );

      form.emit('not-an-email');
      expect(form.isInvalid, true);

      form.emit('user@example.com');
      expect(form.isValid, true);
    });

    test('chains multiple validators (first failing wins)', () {
      final form = FormSignal<String>(
        '',
        validators: [
          Validators.required('Required'),
          Validators.minLength(3, 'Too short'),
        ],
      );

      expect(form.error, 'Required');

      form.emit('ab');
      expect(form.error, 'Too short');

      form.emit('abc');
      expect(form.isValid, true);
    });

    test('reset restores initial state', () {
      final form = FormSignal<String>(
        'initial',
        validators: [Validators.required('Required')],
      );

      form.emit('changed');
      form.markAsTouched();

      form.reset();

      expect(form.val, 'initial');
      expect(form.isDirty, false);
      expect(form.isTouched, false);
    });

    test('custom validator works', () {
      final form = FormSignal<int>(
        0,
        validators: [
          Validators.custom<int>(
            (v) => v >= 0 && v <= 100,
            'Must be 0-100',
          ),
        ],
      );

      form.emit(50);
      expect(form.isValid, true);

      form.emit(150);
      expect(form.isInvalid, true);
      expect(form.error, 'Must be 0-100');
    });

    test('numeric min/max validators work', () {
      final form = FormSignal<num>(
        0,
        validators: [
          Validators.min(0, 'Too low'),
          Validators.max(100, 'Too high'),
        ],
      );

      form.emit(-1);
      expect(form.error, 'Too low');

      form.emit(101);
      expect(form.error, 'Too high');

      form.emit(50);
      expect(form.isValid, true);
    });
  });
}
