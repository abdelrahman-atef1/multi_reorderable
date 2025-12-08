import 'package:flutter/material.dart';

/// Global configuration for ReorderableMultiDragList widgets
///
/// Use this class to set default builders that apply to all widgets automatically.
/// Individual widgets can override these defaults by providing their own builders.
class ReorderableMultiDragConfig {
  ReorderableMultiDragConfig._();

  /// Global default builder for empty state (when items list is empty)
  ///
  /// This builder is used automatically by all ReorderableMultiDragList widgets
  /// when their items list is empty, unless they provide their own emptyStateBuilder.
  ///
  /// Example:
  /// ```dart
  /// ReorderableMultiDragConfig.setEmptyStateBuilder((context) {
  ///   return Center(
  ///     child: Column(
  ///       mainAxisAlignment: MainAxisAlignment.center,
  ///       children: [
  ///         Icon(Icons.inbox, size: 64, color: Colors.grey),
  ///         SizedBox(height: 16),
  ///         Text('No items available'),
  ///       ],
  ///     ),
  ///   );
  /// });
  /// ```
  static Widget Function(BuildContext context)? emptyStateBuilder;

  /// Set the global default empty state builder
  ///
  /// This builder will be used by all ReorderableMultiDragList widgets
  /// when their items list is empty, unless they provide their own emptyStateBuilder.
  static void setEmptyStateBuilder(
      Widget Function(BuildContext context) builder) {
    emptyStateBuilder = builder;
  }

  /// Clear the global default empty state builder
  static void clearEmptyStateBuilder() {
    emptyStateBuilder = null;
  }
}
