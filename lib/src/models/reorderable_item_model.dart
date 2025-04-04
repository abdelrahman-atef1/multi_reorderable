import 'package:flutter/material.dart';

/// A model class that represents an item in the ReorderableMultiSelectList.
///
/// This class provides a convenient way to structure data for use with the
/// ReorderableMultiSelectList widget.
class ReorderableItem<T> {
  /// The unique identifier for this item
  final String id;

  /// The data associated with this item
  final T data;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Whether this item is currently being dragged
  final bool isDragging;

  /// Optional custom data that can be associated with this item
  final Map<String, dynamic>? metadata;

  /// Creates a [ReorderableItem] with the specified properties.
  const ReorderableItem({
    required this.id,
    required this.data,
    this.isSelected = false,
    this.isDragging = false,
    this.metadata,
  });

  /// Creates a copy of this item with the given fields replaced with new values.
  ReorderableItem<T> copyWith({
    String? id,
    T? data,
    bool? isSelected,
    bool? isDragging,
    Map<String, dynamic>? metadata,
  }) {
    return ReorderableItem<T>(
      id: id ?? this.id,
      data: data ?? this.data,
      isSelected: isSelected ?? this.isSelected,
      isDragging: isDragging ?? this.isDragging,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReorderableItem<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Configuration for the animation behavior of the ReorderableMultiSelectList.
class ReorderableAnimationConfig {
  /// Duration for the collect animation when items are selected
  final Duration collectAnimationDuration;

  /// Duration for the reorder animation
  final Duration reorderAnimationDuration;

  /// Duration for the drag animation
  final Duration dragAnimationDuration;

  /// Curve for the collect animation
  final Curve collectAnimationCurve;

  /// Curve for the reorder animation
  final Curve reorderAnimationCurve;

  /// Curve for the drag animation
  final Curve dragAnimationCurve;

  /// Creates a [ReorderableAnimationConfig] with the specified properties.
  const ReorderableAnimationConfig({
    this.collectAnimationDuration = const Duration(milliseconds: 300),
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.dragAnimationDuration = const Duration(milliseconds: 150),
    this.collectAnimationCurve = Curves.easeInOut,
    this.reorderAnimationCurve = Curves.easeInOut,
    this.dragAnimationCurve = Curves.easeOut,
  });

  /// Creates a copy of this config with the given fields replaced with new values.
  ReorderableAnimationConfig copyWith({
    Duration? collectAnimationDuration,
    Duration? reorderAnimationDuration,
    Duration? dragAnimationDuration,
    Curve? collectAnimationCurve,
    Curve? reorderAnimationCurve,
    Curve? dragAnimationCurve,
  }) {
    return ReorderableAnimationConfig(
      collectAnimationDuration: collectAnimationDuration ?? this.collectAnimationDuration,
      reorderAnimationDuration: reorderAnimationDuration ?? this.reorderAnimationDuration,
      dragAnimationDuration: dragAnimationDuration ?? this.dragAnimationDuration,
      collectAnimationCurve: collectAnimationCurve ?? this.collectAnimationCurve,
      reorderAnimationCurve: reorderAnimationCurve ?? this.reorderAnimationCurve,
      dragAnimationCurve: dragAnimationCurve ?? this.dragAnimationCurve,
    );
  }
}

/// Configuration for the stack behavior when dragging selected items.
class ReorderableStackConfig {
  /// Offset for stacking selected items when dragging
  final Offset stackOffset;

  /// Maximum stack offset for cards
  final double maxStackOffset;

  /// Maximum rotation for cards in the stack (in degrees)
  final double maxStackRotation;

  /// Maximum number of items to show in the stack
  final int maxStackItems;

  /// Creates a [ReorderableStackConfig] with the specified properties.
  const ReorderableStackConfig({
    this.stackOffset = const Offset(4, 4),
    this.maxStackOffset = 8.0,
    this.maxStackRotation = 2.0,
    this.maxStackItems = 3,
  });

  /// Creates a copy of this config with the given fields replaced with new values.
  ReorderableStackConfig copyWith({
    Offset? stackOffset,
    double? maxStackOffset,
    double? maxStackRotation,
    int? maxStackItems,
  }) {
    return ReorderableStackConfig(
      stackOffset: stackOffset ?? this.stackOffset,
      maxStackOffset: maxStackOffset ?? this.maxStackOffset,
      maxStackRotation: maxStackRotation ?? this.maxStackRotation,
      maxStackItems: maxStackItems ?? this.maxStackItems,
    );
  }
}
