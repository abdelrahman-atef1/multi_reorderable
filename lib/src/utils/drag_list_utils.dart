/// Utility functions for the ReorderableMultiDragList widget.
class DragListUtils {
  /// Applies reordering to a list based on original and target positions.
  ///
  /// This method creates a new list with the reordered items and calls the onReorder callback.
  static void applyReordering<T>({
    required List<T> items,
    required Set<T> selectedItems,
    required Map<T, int> originalPositions,
    required Map<T, int> targetPositions,
    required void Function(List<T> reorderedItems) onReorder,
  }) {
    if (targetPositions.isEmpty) return;

    // Create a new list with the reordered items
    final List<T> newItems = List<T>.from(items);
    
    // Remove all selected items
    newItems.removeWhere((item) => selectedItems.contains(item));
    
    // Get the target index (where to insert the selected items)
    int targetIndex = targetPositions.values.first;
    
    // Get the selected items in their original order
    final List<T> selectedItemsInOrder = selectedItems
        .toList()
        .where((item) => originalPositions.containsKey(item))
        .toList()
      ..sort((a, b) => originalPositions[a]!.compareTo(originalPositions[b]!));
    
    // Insert all selected items at the target position
    newItems.insertAll(targetIndex, selectedItemsInOrder);
    
    // Notify about the reordering
    onReorder(newItems);
  }

  /// Calculates the optimal stack offset for a given number of items.
  ///
  /// This method ensures that the stack doesn't get too large when there are many items.
  static double calculateStackOffset(int itemCount, double maxOffset) {
    if (itemCount <= 1) return 0;
    if (itemCount <= 3) return maxOffset;
    
    // Gradually reduce the offset as the number of items increases
    return maxOffset * (3 / itemCount).clamp(0.3, 1.0);
  }

  /// Calculates the optimal stack rotation for a given number of items.
  ///
  /// This method ensures that the stack doesn't rotate too much when there are many items.
  static double calculateStackRotation(int itemCount, double maxRotation) {
    if (itemCount <= 1) return 0;
    if (itemCount <= 3) return maxRotation;
    
    // Gradually reduce the rotation as the number of items increases
    return maxRotation * (3 / itemCount).clamp(0.3, 1.0);
  }
}
