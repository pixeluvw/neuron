// process_info_io.dart

import 'dart:io' show ProcessInfo;

abstract class ProcessInfoProxy {
  static int get currentRss => ProcessInfo.currentRss;
}
