import 'dart:async';

import 'package:ansicolor/ansicolor.dart';

class Loggy {
  final Map<String, Logger> _loggers = {};
  LogLevel logLevel = LogLevel.VERBOSE;

  static final Loggy instance = Loggy._();
  Loggy._();

  static final Logger defaultLogger = Logger("loggy");
}

class Logger {
  final List<LogEntry> _registry = [];
  final String tag;

  factory Logger(String tag) {
    final Logger? _logger = Loggy.instance._loggers[tag];

    if (_logger == null) {
      Loggy.instance._loggers[tag] = Logger._(tag);
      return Loggy.instance._loggers[tag]!;
    } else {
      return _logger;
    }
  }

  Logger._(this.tag);

  Future<void> v(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.VERBOSE, secure);

  Future<void> d(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.DEBUG, secure);

  Future<void> i(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.INFO, secure);

  Future<void> w(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.WARN, secure);

  Future<void> e(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.ERROR, secure);

  Future<void> wtf(
    Object? message, {
    bool secure = false,
  }) =>
      custom(message, LogLevel.WTF, secure);

  Future<void> custom(
    Object? message, [
    LogLevel level = LogLevel.DEBUG,
    bool secure = false,
  ]) async {
    LogEntry entry = LogEntry._(
      level: level,
      tag: tag,
      message: message.toString(),
      secure: secure,
    );

    _registry.add(entry);

    if (level.index >= Loggy.instance.logLevel.index) {
      print(entry.toString());
    }
  }

  String dump() => _registry.join("\n");
}

class LogEntry {
  final String message;
  final String tag;
  final LogLevel level;
  final bool secure;

  const LogEntry._({
    required this.message,
    required this.tag,
    this.level = LogLevel.INFO,
    this.secure = false,
  });

  @override
  String toString() {
    String content;

    if (this.secure)
      content = "Secure logs can't be dumped";
    else
      content = this.message;

    final String date = _formatDate(DateTime.now());

    return "$date  ${level.asString}  $tag: $content";
  }

  String toLogLine() {
    final String content = this.message;

    final String date = _formatDate(DateTime.now());

    return level.color("$date  ${level.asString}  $tag: $content");
  }

  String _formatDate(DateTime date) {
    final String month = _addOptionalZero(date.month).join();
    final String day = _addOptionalZero(date.day).join();
    final String hour = _addOptionalZero(date.hour).join();
    final String minute = _addOptionalZero(date.minute).join();
    final String second = _addOptionalZero(date.second).join();

    return "$month/$day $hour:$minute:$second";
  }

  List<String> _addOptionalZero(int param) {
    final List<String> fromParam = param.toString().split('');

    return [
      if (fromParam.length == 1) "0",
      ...fromParam,
    ];
  }
}

enum LogLevel {
  VERBOSE,
  DEBUG,
  INFO,
  WARN,
  ERROR,
  WTF,
}

extension LogLevelUtils on LogLevel {
  String get asString {
    switch (this) {
      case LogLevel.VERBOSE:
        return "V";
      case LogLevel.DEBUG:
        return "D";
      case LogLevel.INFO:
        return "I";
      case LogLevel.WARN:
        return "W";
      case LogLevel.ERROR:
        return "E";
      case LogLevel.WTF:
        return "F";
    }
  }

  AnsiPen get color {
    switch (this) {
      case LogLevel.VERBOSE:
        return AnsiPen()..white(bold: true);
      case LogLevel.DEBUG:
        return AnsiPen()..green(bold: true);
      case LogLevel.INFO:
        return AnsiPen()..blue(bold: true);
      case LogLevel.WARN:
        return AnsiPen()..yellow(bold: true);
      case LogLevel.ERROR:
        return AnsiPen()..red(bold: true);
      case LogLevel.WTF:
        return AnsiPen()..magenta(bold: true);
    }
  }
}
