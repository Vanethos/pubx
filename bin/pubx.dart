import 'package:args/command_runner.dart';
import 'package:pubx/pubx.dart';

main(List<String> arguments) {
  final runner = CommandRunner("pubx", "The missing pub commands.")
    ..addCommand(SearchCommand())
    ..addCommand(ViewCommand());

  runner.run(arguments);
}
