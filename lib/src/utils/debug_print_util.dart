import 'dart:io';

import 'package:flutter/foundation.dart';

/// Debug printing utility for multi_reorderable library
///
/// All debug prints are prefixed with [libPrefix] to make them easy to filter.
/// Use this utility instead of direct print() or debugPrint() calls.
class DebugPrintUtil {
  /// Library prefix for all debug messages
  static const String libPrefix = '[multi_reorderable]';

  static void _printDebugInfo(Object? object) {
    String line = "$object";
    if (kDebugMode) {
      if (Platform.isIOS) {
        debugPrint(line);
      } else {
        debugPrint('\x1B[0m$line\x1B[0m');
      }
    }
  }

  /// Print a debug message with library prefix
  ///
  /// Example:
  /// ```dart
  /// DebugPrintUtil.print('Item reordered');
  /// // Output: [multi_reorderable] Item reordered
  /// ```
  static void print(String message) {
    _printDebugInfo('$libPrefix $message');
  }

  /// Print a debug message with a tag/category
  ///
  /// Example:
  /// ```dart
  /// DebugPrintUtil.printTagged('DRAG', 'Drag started at index 5');
  /// // Output: [multi_reorderable] [DRAG] Drag started at index 5
  /// ```
  static void printTagged(String tag, String message) {
    _printDebugInfo('$libPrefix [$tag] $message');
  }

  /// Print a debug message with formatted data
  ///
  /// Example:
  /// ```dart
  /// DebugPrintUtil.printData('Reordering', {'index': 5, 'count': 3});
  /// // Output: [multi_reorderable] Reordering: {index: 5, count: 3}
  /// ```
  static void printData(String label, dynamic data) {
    _printDebugInfo('$libPrefix $label: $data');
  }

  /// Print an error message
  ///
  /// Example:
  /// ```dart
  /// DebugPrintUtil.printError('Failed to reorder items', error);
  /// // Output: [multi_reorderable] [ERROR] Failed to reorder items: ...
  /// ```
  static void printError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    _printDebugInfo('$libPrefix [ERROR] $message');
    if (error != null) {
      _printDebugInfo('$libPrefix [ERROR] Error details: $error');
    }
    if (stackTrace != null) {
      _printDebugInfo('$libPrefix [ERROR] Stack trace: $stackTrace');
    }
  }

  /// Print a warning message
  ///
  /// Example:
  /// ```dart
  /// DebugPrintUtil.printWarning('Target position out of bounds');
  /// // Output: [multi_reorderable] [WARNING] Target position out of bounds
  /// ```
  static void printWarning(String message) {
    _printDebugInfo('$libPrefix [WARNING] $message');
  }

  /// Print debug info for drag events
  static void printDrag(String message) {
    printTagged('DRAG', message);
  }

  /// Print debug info for reorder events
  static void printReorder(String message) {
    printTagged('REORDER', message);
  }

  /// Print debug info for selection events
  static void printSelection(String message) {
    printTagged('SELECTION', message);
  }

  /// Print debug info for pagination events
  static void printPagination(String message) {
    printTagged('PAGINATION', message);
  }

  /// Print debug info for animation events
  static void printAnimation(String message) {
    printTagged('ANIMATION', message);
  }

  /// Print debug info for API/reorder callback events
  static void printApi(String message) {
    printTagged('API', message);
  }
}
