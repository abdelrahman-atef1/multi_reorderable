import 'package:flutter/material.dart';

import '../styles/animated_card_style.dart';
import '../styles/minimalist_style.dart';
import '../styles/stacked_style.dart';

/// Enum to define the drag style
enum DragStyle {
  /// Stack style
  stackedStyle,

  /// Animated card style
  animatedCardStyle,
  
  /// Minimalist style
  minimalistStyle,
}

/// Theme for the reorderable multi drag widget
class ReorderableMultiDragTheme {
  /// Default constructor for the theme
  ReorderableMultiDragTheme({
    this.dragHandleIcon = Icons.drag_handle,
    this.dragHandleColor = Colors.grey,
    this.dragHandleHoverColor = Colors.blue,
    this.dragHandleGrabColor = Colors.green,
    this.dragHandleSize = 24.0,
    this.selectBoxColor = Colors.blue,
    this.selectBoxIconColor = Colors.white,
    this.selectBoxIconCheckedColor = Colors.white,
    this.selectBoxCheckedColor = Colors.green,
    this.selectBoxIconSize = 16.0,
    this.draggedItemColor = const Color(0x880000FF), // Semitransparent blue
    this.draggedItemBorderWidth = 1.0,
    this.draggedItemBorderColor = Colors.blue,
    this.draggedItemBorderRadius = 8.0,
    this.itemBorderRadius = 8.0,
    this.pointerThresholdDistance = 10.0,
    this.autoScrollSpeed = 50.0,
    this.autoScrollThreshold = 160.0,
    this.dropTargetHeight = 4.0,
    this.dropTargetColor = Colors.blue,
    this.itemHorizontalMargin = 8.0,
    this.itemVerticalMargin = 4.0,
    this.selectedItemColor = const Color(0x442196F3), // Light blue with 27% opacity
    this.itemColor = Colors.white,
    this.selectionBarColor = const Color(0x442196F3), // Light blue with 27% opacity
    this.dragStyle = DragStyle.stackedStyle,
  });

  /// Icon for the drag handle
  final IconData dragHandleIcon;

  /// Color for the drag handle
  final Color dragHandleColor;

  /// Color for the drag handle when hovered
  final Color dragHandleHoverColor;

  /// Color for the drag handle when grabbed
  final Color dragHandleGrabColor;

  /// Size for the drag handle
  final double dragHandleSize;

  /// Color for the select box
  final Color selectBoxColor;

  /// Icon color for the select box
  final Color selectBoxIconColor;

  /// Icon color for the checked select box
  final Color selectBoxIconCheckedColor;

  /// Color for the checked select box
  final Color selectBoxCheckedColor;

  /// Size for the select box icon
  final double selectBoxIconSize;

  /// Color for the dragged item
  final Color draggedItemColor;

  /// Border width for the dragged item
  final double draggedItemBorderWidth;

  /// Border color for the dragged item
  final Color draggedItemBorderColor;

  /// Border radius for the dragged item
  final double draggedItemBorderRadius;

  /// Border radius for the item
  final double itemBorderRadius;

  /// Threshold distance for the pointer
  final double pointerThresholdDistance;

  /// Speed for auto scroll
  final double autoScrollSpeed;

  /// Threshold for auto scroll
  final double autoScrollThreshold;

  /// Height for the drop target
  final double dropTargetHeight;

  /// Color for the drop target
  final Color dropTargetColor;

  /// Horizontal margin for items
  final double itemHorizontalMargin;

  /// Vertical margin for items
  final double itemVerticalMargin;

  /// Color for selected items
  final Color selectedItemColor;

  /// Color for items
  final Color itemColor;

  /// Color for the selection bar
  final Color selectionBarColor;

  /// Style for the dragged item
  final DragStyle dragStyle;

  /// Build style for the dragged item
  Widget buildStyle<T>({
    required BuildContext context,
    required T draggedItem,
    required List<T> selectedItems,
    required int draggedItemIndex,
    required Widget Function(BuildContext, T, int, bool, bool) itemBuilder,
  }) {
    switch (dragStyle) {
      case DragStyle.stackedStyle:
        return StackedStyle.build(
          context: context,
          draggedItem: draggedItem,
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: this,
          itemBuilder: itemBuilder,
        );
      case DragStyle.animatedCardStyle:
        return AnimatedCardStyle.build(
          context: context,
          draggedItem: draggedItem,
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: this,
          itemBuilder: itemBuilder,
        );
      case DragStyle.minimalistStyle:
        return MinimalistStyle.build(
          context: context,
          draggedItem: draggedItem,
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: this,
          itemBuilder: itemBuilder,
        );
    }
  }
}