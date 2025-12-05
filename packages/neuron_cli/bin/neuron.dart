import 'dart:io';

import 'package:neuron_cli/neuron_cli.dart';

Future<void> main(List<String> arguments) async {
  final exitCode = await NeuronCliRunner().run(arguments);
  exit(exitCode);
}
