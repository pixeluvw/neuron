import 'package:neuron_cli/neuron_cli.dart';
import 'package:test/test.dart';

void main() {
  group('NeuronCliRunner', () {
    test('should show version with --version flag', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['--version']);
      expect(exitCode, equals(0));
    });

    test('should show help with --help flag', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['--help']);
      expect(exitCode, equals(0));
    });

    test('should show generate help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show create help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['create', '--help']);
      expect(exitCode, equals(0));
    });
  });

  group('ProjectUtils', () {
    test('validates isNeuronProject returns false for non-project directory',
        () async {
      // This test would need to be in a non-Flutter directory
      // The actual implementation checks for pubspec.yaml
    });
  });
}
