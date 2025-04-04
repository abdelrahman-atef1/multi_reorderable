import 'package:flutter/material.dart';

/// A builder for creating a custom drag handle.
///
/// This builder allows for customizing the appearance of the drag handle
/// in the ReorderableMultiDragList widget.
typedef DragHandleBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
);

/// A builder for creating a custom selection bar.
///
/// This builder allows for customizing the appearance of the selection bar
/// that appears when items are selected in the ReorderableMultiDragList widget.
typedef SelectionBarBuilder = Widget Function(
  BuildContext context,
  int selectedCount,
  VoidCallback onDone,
);

/// A builder for creating a custom item widget.
///
/// This builder allows for customizing the appearance of each item
/// in the ReorderableMultiDragList widget.
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isSelected,
  bool isDragging,
);

/// Default implementations of the builders.
class DefaultBuilders {
  /// Creates a default drag handle.
  static Widget defaultDragHandle(BuildContext context, bool isSelected) {
    return Icon(
      Icons.drag_handle,
      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      size: 24,
    );
  }

  /// Creates a default selection bar.
  static Widget defaultSelectionBar(
    BuildContext context,
    int selectedCount,
    VoidCallback onDone,
    String selectionCountText,
    String doneButtonText,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Row(
        children: [
          Text(
            selectionCountText.replaceAll('{}', selectedCount.toString()),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: onDone,
            child: Text(doneButtonText),
          ),
        ],
      ),
    );
  }
}
