import 'package:flutter/material.dart';

import '../theme/reorderable_multi_drag_theme.dart';

/// A clean, minimalist style for dragged items
class MinimalistStyle {
  /// Build a minimalist layout for dragged items
  static Widget build<T>({
    required BuildContext context,
    required T draggedItem,
    required List<T> selectedItems,
    required int draggedItemIndex,
    required ReorderableMultiDragTheme theme,
    required Widget Function(BuildContext, T, int, bool, bool) itemBuilder,
  }) {
    // Container dimensions
    final double containerWidth = 280.0;
    final double containerHeight = 120.0;
    
    // Item dimensions
    final double itemWidth = 260.0;
    final double itemHeight = 80.0;
    
    // Create the main item widget
    final Widget mainItemWidget = itemBuilder(
      context,
      draggedItem,
      draggedItemIndex,
      true,
      true,
    );
    
    // Create widget list
    final List<Widget> elements = [];
    
    // Add the main container
    elements.add(
      Positioned(
        left: (containerWidth - itemWidth) / 2,
        top: (containerHeight - itemHeight) / 2,
        width: itemWidth,
        height: itemHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(theme.itemBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.itemBorderRadius),
            child: Center(
              child: SizedBox(
                width: itemWidth - 24,
                height: itemHeight - 16,
                child: Center(
                  child: mainItemWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    // Add subtle decorative elements based on selected count
    if (selectedItems.length > 1) {
      // Add selection indicator line
      elements.add(
        Positioned(
          left: (containerWidth - itemWidth) / 2 - 2,
          top: (containerHeight - itemHeight) / 2 + 4,
          width: 4,
          height: itemHeight - 8,
          child: Container(
            decoration: BoxDecoration(
              color: theme.draggedItemBorderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
      
      // Add selection count pill
      elements.add(
        Positioned(
          left: (containerWidth - itemWidth) / 2 - 10,
          top: (containerHeight - itemHeight) / 2 - 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.draggedItemBorderColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${selectedItems.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    
    // Return the complete widget
    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: elements,
      ),
    );
  }
} 