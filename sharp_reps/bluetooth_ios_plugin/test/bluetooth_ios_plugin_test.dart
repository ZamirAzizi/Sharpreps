// import 'package:flutter_test/flutter_test.dart';
// import 'package:bluetooth_ios_plugin/bluetooth_ios_plugin.dart';
// import 'package:bluetooth_ios_plugin/bluetooth_ios_plugin_platform_interface.dart';
// import 'package:bluetooth_ios_plugin/bluetooth_ios_plugin_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockBluetoothIosPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements BluetoothIosPluginPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final BluetoothIosPluginPlatform initialPlatform = BluetoothIosPluginPlatform.instance;

//   test('$MethodChannelBluetoothIosPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelBluetoothIosPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     BluetoothIosPlugin bluetoothIosPlugin = BluetoothIosPlugin();
//     MockBluetoothIosPluginPlatform fakePlatform = MockBluetoothIosPluginPlatform();
//     BluetoothIosPluginPlatform.instance = fakePlatform;

//     expect(await bluetoothIosPlugin.getPlatformVersion(), '42');
//   });
// }
