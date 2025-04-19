import 'package:flutter/material.dart';

import '../theme/reorderable_multi_drag_theme.dart';

/// Implementation of an animated card style for dragged items
class AnimatedCardStyle {
  /// Build an animated card layout for dragged items
  static Widget build<T>({
    required BuildContext context,
    required T draggedItem,
    required List<T> selectedItems,
    required int draggedItemIndex,
    required ReorderableMultiDragTheme theme,
    required Widget Function(BuildContext, T, int, bool, bool) itemBuilder,
  }) {
    // Create a simple animation controller in the widget
    final List<Widget> cards = [];
    
    // Main container dimensions
    final double containerWidth = 300.0;
    final double containerHeight = 150.0;
    
    // Item dimensions
    final double itemWidth = 280.0;
    final double itemHeight = 100.0;
    
    // Main item position (centered)
    final double mainItemX = (containerWidth - itemWidth) / 2;
    final double mainItemY = (containerHeight - itemHeight) / 2;
    
    // Add main item (dragged item)
    final Widget mainItemWidget = itemBuilder(
      context, 
      draggedItem, 
      draggedItemIndex, 
      true, 
      true
    );
    
    cards.add(
      Positioned(
        left: mainItemX,
        top: mainItemY,
        width: itemWidth,
        height: itemHeight,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(theme.itemBorderRadius),
                  border: Border.all(
                    color: theme.draggedItemBorderColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.draggedItemBorderColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.itemBorderRadius - 2),
                  child: Center(
                    child: SizedBox(
                      width: itemWidth - 16,
                      height: itemHeight - 16,
                      child: Center(
                        child: mainItemWidget,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    
    // Create backdrop count indicator if there are other selected items
    if (selectedItems.length > 1) {
      cards.add(
        Positioned(
          right: 10,
          bottom: 10,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.draggedItemBorderColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${selectedItems.length} selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Return the animated stack
    return Container(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: cards,
      ),
    );
  }
} 