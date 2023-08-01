// import 'package:flutter_test/flutter_test.dart';
// import 'package:ios/ios.dart';
// import 'package:ios/ios_platform_interface.dart';
// import 'package:ios/ios_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockIosPlatform
//     with MockPlatformInterfaceMixin
//     implements IosPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final IosPlatform initialPlatform = IosPlatform.instance;

//   test('$MethodChannelIos is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelIos>());
//   });

//   test('getPlatformVersion', () async {
//     Ios iosPlugin = Ios();
//     MockIosPlatform fakePlatform = MockIosPlatform();
//     IosPlatform.instance = fakePlatform;

//     expect(await iosPlugin.getPlatformVersion(), '42');
//   });
// }
