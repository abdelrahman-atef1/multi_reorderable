import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/reorderable_multi_drag_theme.dart';

/// The default stacked style implementation
class StackedStyle {
  /// Build a stacked style layout for dragged items
  static Widget build<T>({
    required BuildContext context,
    required T draggedItem,
    required List<T> selectedItems,
    required int draggedItemIndex,
    required ReorderableMultiDragTheme theme,
    required Widget Function(BuildContext, T, int, bool, bool) itemBuilder,
  }) {
    final List<Widget> stackItems = [];
    
    // Base dimensions for the stack
    final double itemWidth = 300.0;
    final double itemHeight = 80.0;
    final double contentWidth = itemWidth * 0.95;
    final double contentHeight = itemHeight * 0.9;
    
    // Stack offset constants
    final double stackOffsetVertical = 15.0; // pixels
    final double stackOffsetHorizontal = 10.0; // pixels
    
    // Get all selected items in order (except the dragged one)
    final filteredItems = selectedItems
        .where((item) => item != draggedItem)
        .toList();
    
    // Add all selected items to the stack
    for (int i = 0; i < filteredItems.length; i++) {
      final item = filteredItems[i];
      final itemIndex = selectedItems.indexOf(item);
      
      if (itemIndex < 0) continue;
      
      // Calculate the position in the stack (0 is bottom, length-1 is top)
      final int stackPosition = i;
      final int stackTotal = filteredItems.length;
      
      // Build the item widget
      final Widget itemWidget = itemBuilder(
        context,
        item,
        itemIndex,
        true,
        false,
      );
      
      // Calculate offset based on position in stack - no rotation
      // Items stack neatly behind the main item
      final int relativePos = stackTotal - stackPosition;
      
      // Calculate precise offsets for a simple staggered arrangement
      final double xOffset = stackOffsetHorizontal * relativePos;
      final double yOffset = stackOffsetVertical * relativePos;
      
      // Create a widget for this item in the stack
      stackItems.add(
        Transform.translate(
          offset: Offset(xOffset, yOffset),
          child: Opacity(
            opacity: math.max(0.7, 1.0 - (0.1 * relativePos)),
            child: Container(
              width: itemWidth,
              height: itemHeight,
              decoration: BoxDecoration(
                color: theme.selectedItemColor,
                borderRadius: BorderRadius.circular(theme.itemBorderRadius),
                border: Border.all(
                  color: Colors.black12,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(theme.itemBorderRadius - 1),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: contentWidth,
                      height: contentHeight,
                      child: Center(
                        child: itemWidget,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Build the dragged item widget
    final Widget draggedItemWidget = itemBuilder(
      context,
      draggedItem,
      draggedItemIndex,
      true,
      true,
    );
    
    // Add the dragged item on top
    stackItems.add(
      Container(
        width: itemWidth,
        height: itemHeight,
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(theme.itemBorderRadius),
          border: Border.all(
            color: theme.draggedItemBorderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.draggedItemBorderColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.itemBorderRadius - 3),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: contentWidth,
                height: contentHeight,
                child: Center(
                  child: draggedItemWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    // Calculate total stack size
    final double stackWidth = itemWidth + (stackOffsetHorizontal * filteredItems.length);
    final double stackHeight = itemHeight + (stackOffsetVertical * filteredItems.length) + 15;
    
    // Create the final stack with fixed dimensions
    return SizedBox(
      width: stackWidth,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: stackItems,
      ),
    );
  }
} 