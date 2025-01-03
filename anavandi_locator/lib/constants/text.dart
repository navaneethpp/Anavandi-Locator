// text.dart

import 'package:package_info_plus/package_info_plus.dart';

class AppText {
  static const version = "Version 1.0.0 alpha";
}

class AppInfo {
  static String appName = '';
  static String version = '';
  static String buildNumber = '';

  static Future<void> loadAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
