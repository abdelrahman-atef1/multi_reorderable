import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/reorderable_multi_drag_theme.dart';
import 'stacked_style.dart';
import 'animated_card_style.dart';
import 'minimalist_style.dart';

/// A manager class that handles different drag styles and builds them
class DragStylesManager {
  /// Build a dragged items widget based on the selected style
  static Widget buildDraggedItems<T>({
    required BuildContext context,
    required DragStyle style,
    required T draggedItem,
    required List<T> selectedItems,
    required int draggedItemIndex,
    required Offset dragPosition,
    required double itemHeight,
    required ReorderableMultiDragTheme theme,
    required Widget Function(BuildContext, T, int, bool, bool) itemBuilder,
  }) {
    // Get global position and screen info
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();
    
    final Size screenSize = MediaQuery.of(context).size;
    
    // Calculate the width and height of the stack
    final double stackWidth = 300.0;
    final double stackHeight = itemHeight + 20.0;
    
    // Position the stack directly under the finger/cursor
    // with offset to ensure visibility
    final double fingerOffset = 150.0; // Position above finger
    final double left = dragPosition.dx - (stackWidth / 2); // Center horizontally 
    final double top = dragPosition.dy - fingerOffset; // Position above finger
    
    // Apply bounds to keep on screen
    final double boundedLeft = math.max(0, math.min(left, screenSize.width - stackWidth));
    final double boundedTop = math.max(0, math.min(top, screenSize.height - stackHeight));

    // Choose the appropriate style based on the theme
    Widget content;
    switch (style) {
      case DragStyle.stackedStyle:
        content = StackedStyle.build(
          context: context,
          draggedItem: draggedItem, 
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: theme,
          itemBuilder: itemBuilder,
        );
        break;
      case DragStyle.animatedCardStyle:
        content = AnimatedCardStyle.build(
          context: context,
          draggedItem: draggedItem, 
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: theme,
          itemBuilder: itemBuilder,
        );
        break;
      case DragStyle.minimalistStyle:
        content = MinimalistStyle.build(
          context: context,
          draggedItem: draggedItem, 
          selectedItems: selectedItems,
          draggedItemIndex: draggedItemIndex,
          theme: theme,
          itemBuilder: itemBuilder,
        );
        break;
    }
    
    // Create the final positioned element
    return Positioned(
      left: boundedLeft,
      top: boundedTop,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: stackWidth,
          child: content,
        ),
      ),
    );
  }
} 