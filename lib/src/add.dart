import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';

import 'api.dart';

class AddCommand extends Command {
  AddCommand() {
    argParser.addFlag(
      'dev',
      help: 'Add dev dependency',
    );
    argParser.addFlag(
      'lock',
      help: 'Specify a lower boundary for the package version with the "^" symbol',
    );
  }

  @override
  final String name = 'add';

  @override
  final List<String> aliases = ['a'];

  @override
  final String description = 'Add a package to your pubspec.yaml file';

  @override
  final String invocation = 'pubx add {packageName}';

  Future<void> run() async {
    final packageName = argResults.rest.join(' ');
    bool devDependency = argResults['dev'];
    bool lockVersion = argResults['lock'];

    var pub = await _getPubspec();

    if (pub == null) {
      throw FileNotFoundException("No pubspec.yaml file found");
    }

    try {
      // check if current directory has a pubspec.yaml file
      PackageInfo package = await view(packageName);

      // Read file
      var contents = StringBuffer();
      var contentStream = pub.openRead();

      contentStream
          .transform(Utf8Decoder())
          .transform(LineSplitter())
          .listen((String line) {
        var match = devDependency ? "dev_dependencies:" : "dependencies:";
        if (line == (match)) {
          line +=
          "\n  ${package.name}: ${lockVersion ? "^" : ""}${package.version}";
        }
        contents.write(line + "\n");
      }, // Add line to our StringBuffer object
          onDone: () => pub.writeAsStringSync(contents.toString()));

    } on PackageNotFoundException catch (e) {
      stderr.writeln('${e.packageName} not found');
      exit(64);
    } catch (e) {
      print('There was a problem adding the dependency to your project');
      rethrow;
    }
  }

  Future<File> _getPubspec() async {
    Directory current = Directory.current;
    var context = Context();
    var file = File(context.join(current.path, 'pubspec.yaml'));
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}

class FileNotFoundException implements Exception {
  String message;

  FileNotFoundException(this.message);

  String toString() => "FileNotFoundException: $message";
}
