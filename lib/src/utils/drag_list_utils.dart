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
    required void Function(
            int newIndex, List<T> movedItems, List<T> reorderedItems)
        onReorder,
  }) {
    // Create a copy of the list to work with
    final List<T> newList = List<T>.from(items);

    // Get moved items sorted by original position
    final List<T> movedItems = selectedItems.toList()
      ..sort((a, b) {
        final posA = originalPositions[a] ?? 0;
        final posB = originalPositions[b] ?? 0;
        return posA.compareTo(posB);
      });

    // First, remove all selected items from their original positions
    // Sort so we remove from highest index to lowest to avoid shifting issues
    final List<MapEntry<T, int>> sortedOriginal = originalPositions.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedOriginal) {
      if (entry.value < newList.length) {
        newList.removeAt(entry.value);
      }
    }

    // Get the target position (they should all be the same)
    if (targetPositions.isEmpty) {
      onReorder(0, movedItems, newList);
      return;
    }

    // Get first target position (this is the position BEFORE items were removed)
    int originalTargetPosition = targetPositions.values.first;

    // Adjust target position if items were removed before it
    // Count how many selected items were at positions before the target
    int itemsRemovedBeforeTarget = 0;
    for (final entry in sortedOriginal) {
      if (entry.value < originalTargetPosition) {
        itemsRemovedBeforeTarget++;
      }
    }

    // Calculate adjusted target position: subtract items removed before target
    // This gives us the correct position in the new list (after removals)
    int targetPosition = originalTargetPosition - itemsRemovedBeforeTarget;

    // Ensure the target position is within bounds after removing items
    targetPosition = targetPosition.clamp(0, newList.length);

    // Insert all selected items at the target position
    // Sort by original position to maintain original relative order
    final List<MapEntry<T, int>> sortedEntries = originalPositions.entries
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in sortedEntries) {
      if (targetPosition <= newList.length) {
        newList.insert(targetPosition, entry.key);
        targetPosition++; // Increment for each insert
      } else {
        // Safely add to the end if we somehow exceed bounds
        newList.add(entry.key);
      }
    }

    // Notify about the reordering with new index and moved items
    // Use the adjusted target position (where items were actually inserted)
    onReorder(
        originalTargetPosition - itemsRemovedBeforeTarget, movedItems, newList);
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
