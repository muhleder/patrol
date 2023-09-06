import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example/main.dart' as app_main;

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig();
final _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20), // 10 seconds is too short for some CIs
);

Future<void> createApp(PatrolTester $) async {
  await app_main.main();
}

void patrol(
  String description,
  Future<void> Function(PatrolTester) callback, {
  bool? skip,
  NativeAutomatorConfig? nativeAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    nativeAutomation: true,
    framePolicy: framePolicy,
    timeout: Timeout(Duration(seconds: 60)),
    skip: skip,
    callback,
  );
}
