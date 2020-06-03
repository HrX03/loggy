import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Loggy {
  static const MethodChannel _channel = const MethodChannel('loggy');

  static final List<LogEntry> _registry = [];

  static String _appLabel;
  static bool _generatedAppLabel = false;
  static int _logLevel = 1;

  static Future<void> generateAppLabel() async {
    _appLabel = await _getAppLabel();
    _generatedAppLabel = true;
  }

  static void setLogLevel(int logLevel) {
    _logLevel = logLevel;
  }

  static Future<void> v({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.VERBOSE, tag, message, secure);

  static Future<void> d({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.DEBUG, tag, message, secure);

  static Future<void> i({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.INFO, tag, message, secure);

  static Future<void> w({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.WARN, tag, message, secure);

  static Future<void> e({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.ERROR, tag, message, secure);

  static Future<void> wtf({
    String tag,
    dynamic message,
    bool secure,
  }) =>
      custom(LogEntry.WTF, tag, message, secure);

  static Future<void> custom([
    int level,
    String tag,
    dynamic message,
    bool secure,
  ]) async {
    if (!_generatedAppLabel || _appLabel == null)
      throw ErrorDescription(
        "You should run Logger.generateAppLabel() before you use Logger, it's enough to run it once at the start of your application",
      );

    if (level == null) throw ArgumentError.notNull('level');

    if (message == null) throw ArgumentError.notNull('message');

    _registry.add(
      LogEntry(
        level: level,
        tag: tag ?? _appLabel,
        message: message.toString(),
        secure: secure,
      ),
    );

    if (kDebugMode && level >= _logLevel) {
      await _channel.invokeMethod(
        'log',
        {
          'level': level,
          'tag': tag,
          'message': message.toString(),
        },
      );
    }
  }

  static String dumpRegistry() => _registry.join("\n");

  static Future<String> _getAppLabel() async =>
      _channel.invokeMethod('appLabel');
}

class LogEntry {
  static const int VERBOSE = 2;
  static const int DEBUG = 3;
  static const int INFO = 4;
  static const int WARN = 5;
  static const int ERROR = 6;
  static const int WTF = 7;

  final int level;
  final String tag;
  final String message;
  final bool secure;

  const LogEntry({
    this.level,
    this.tag,
    this.message,
    this.secure = false,
  });

  @override
  String toString() {
    String content;

    if (this.secure ?? false)
      content = "Secure logs can't be dumped";
    else
      content = this.message;

    String date = DateFormat("MM-dd HH:mm:ss").format(DateTime.now());

    return "$date  $_levelToString  $tag: $content";
  }

  String get _levelToString {
    switch (level) {
      case LogEntry.VERBOSE:
        return "V";
      case LogEntry.DEBUG:
        return "D";
      case LogEntry.INFO:
        return "I";
      case LogEntry.WARN:
        return "W";
      case LogEntry.ERROR:
        return "E";
      case LogEntry.WTF:
        return "WTF";
      default:
        throw ArgumentError.value(level, 'level');
    }
  }
}
