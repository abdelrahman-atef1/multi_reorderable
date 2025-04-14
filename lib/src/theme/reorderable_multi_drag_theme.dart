import 'package:flutter/material.dart';

/// Theme class for the ReorderableMultiDragList widget.
///
/// This class provides styling options for the ReorderableMultiDragList widget.
/// It allows for customization of colors, dimensions, and other visual properties.
class ReorderableMultiDragTheme {
  /// Background color for the selection bar
  final Color selectionBarColor;

  /// Background color for selected items
  final Color selectedItemColor;

  /// Background color for non-selected items
  final Color itemColor;

  /// Border color for the dragged item
  final Color draggedItemBorderColor;

  /// Border radius for items
  final double itemBorderRadius;

  /// Horizontal margin for items
  final double itemHorizontalMargin;

  /// Vertical margin for items
  final double itemVerticalMargin;

  /// Maximum stack offset for cards
  final double maxStackOffset;

  /// Maximum rotation for cards in the stack
  final double maxStackRotation;

  /// Color for the drop target highlight
  final Color dropTargetColor;

  /// Height of the drop target highlight
  final double dropTargetHeight;

  /// Text style for the selection count
  final TextStyle? selectionCountTextStyle;

  /// Text style for the done button
  final TextStyle? doneButtonTextStyle;

  /// Creates a ReorderableMultiDragTheme with default or custom values.
  const ReorderableMultiDragTheme({
    this.selectionBarColor = const Color(0xFFF5F5F5),
    this.selectedItemColor = const Color(0xFFE3F2FD),
    this.itemColor = Colors.white,
    this.draggedItemBorderColor = Colors.blue,
    this.itemBorderRadius = 8.0,
    this.itemHorizontalMargin = 8.0,
    this.itemVerticalMargin = 4.0,
    this.maxStackOffset = 8.0,
    this.maxStackRotation = 2.0,
    this.dropTargetColor = const Color(0x4D0000FF),
    this.dropTargetHeight = 4.0,
    this.selectionCountTextStyle,
    this.doneButtonTextStyle,
  });

  /// Creates a copy of this theme with the given fields replaced with new values.
  ReorderableMultiDragTheme copyWith({
    Color? selectionBarColor,
    Color? selectedItemColor,
    Color? itemColor,
    Color? draggedItemBorderColor,
    double? itemBorderRadius,
    double? itemHorizontalMargin,
    double? itemVerticalMargin,
    double? maxStackOffset,
    double? maxStackRotation,
    Color? dropTargetColor,
    double? dropTargetHeight,
    TextStyle? selectionCountTextStyle,
    TextStyle? doneButtonTextStyle,
  }) {
    return ReorderableMultiDragTheme(
      selectionBarColor: selectionBarColor ?? this.selectionBarColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      itemColor: itemColor ?? this.itemColor,
      draggedItemBorderColor: draggedItemBorderColor ?? this.draggedItemBorderColor,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      itemHorizontalMargin: itemHorizontalMargin ?? this.itemHorizontalMargin,
      itemVerticalMargin: itemVerticalMargin ?? this.itemVerticalMargin,
      maxStackOffset: maxStackOffset ?? this.maxStackOffset,
      maxStackRotation: maxStackRotation ?? this.maxStackRotation,
      dropTargetColor: dropTargetColor ?? this.dropTargetColor,
      dropTargetHeight: dropTargetHeight ?? this.dropTargetHeight,
      selectionCountTextStyle: selectionCountTextStyle ?? this.selectionCountTextStyle,
      doneButtonTextStyle: doneButtonTextStyle ?? this.doneButtonTextStyle,
    );
  }

  /// Creates a theme that's a combination of this theme and another theme.
  ReorderableMultiDragTheme merge(ReorderableMultiDragTheme? other) {
    if (other == null) return this;
    return copyWith(
      selectionBarColor: other.selectionBarColor,
      selectedItemColor: other.selectedItemColor,
      itemColor: other.itemColor,
      draggedItemBorderColor: other.draggedItemBorderColor,
      itemBorderRadius: other.itemBorderRadius,
      itemHorizontalMargin: other.itemHorizontalMargin,
      itemVerticalMargin: other.itemVerticalMargin,
      maxStackOffset: other.maxStackOffset,
      maxStackRotation: other.maxStackRotation,
      dropTargetColor: other.dropTargetColor,
      dropTargetHeight: other.dropTargetHeight,
      selectionCountTextStyle: other.selectionCountTextStyle,
      doneButtonTextStyle: other.doneButtonTextStyle,
    );
  }

  /// Creates a dark theme version
  factory ReorderableMultiDragTheme.dark() {
    return const ReorderableMultiDragTheme(
      selectionBarColor: Color(0xFF303030),
      selectedItemColor: Color(0xFF1E3A5F),
      itemColor: Color(0xFF424242),
      draggedItemBorderColor: Colors.lightBlue,
    );
  }

  /// Creates a light theme version
  factory ReorderableMultiDragTheme.light() {
    return const ReorderableMultiDragTheme();
  }

  /// Creates a theme based on the current brightness
  factory ReorderableMultiDragTheme.fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? ReorderableMultiDragTheme.dark()
        : ReorderableMultiDragTheme.light();
  }

  /// Creates a theme based on the current color scheme
  factory ReorderableMultiDragTheme.fromColorScheme(ColorScheme colorScheme) {
    return ReorderableMultiDragTheme(
      selectionBarColor: colorScheme.surface,
      selectedItemColor: colorScheme.primaryContainer,
      itemColor: colorScheme.surface,
      draggedItemBorderColor: colorScheme.primary,
      selectionCountTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      doneButtonTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
