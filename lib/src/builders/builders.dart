import 'package:flutter/material.dart';

/// A collection of builder functions for customizing the ReorderableMultiSelectList.

/// Builder for creating the header of the ReorderableMultiSelectList.
///
/// This allows for complete customization of the header section.
typedef ReorderableHeaderBuilder = Widget Function(
  BuildContext context,
  List<dynamic> selectedItems,
  bool isSelectionMode,
);

/// Builder for creating the footer of the ReorderableMultiSelectList.
///
/// This allows for complete customization of the footer section.
typedef ReorderableFooterBuilder = Widget Function(
  BuildContext context,
  List<dynamic> selectedItems,
  bool isSelectionMode,
  VoidCallback onDone,
);

/// Builder for creating each item in the ReorderableMultiSelectList.
///
/// This allows for complete customization of how each item is rendered.
typedef ReorderableItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isSelected,
  bool isDragging,
);

/// Builder for creating the drag handle for each item.
///
/// This allows for customization of the drag handle appearance.
typedef DragHandleBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
  bool isDragging,
);

/// Builder for creating the checkbox for each item.
///
/// This allows for customization of the checkbox appearance.
typedef CheckboxBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
  ValueChanged<bool?> onChanged,
);

/// Builder for creating the selection count indicator.
///
/// This allows for customization of how the selection count is displayed.
typedef SelectionCountBuilder = Widget Function(
  BuildContext context,
  int count,
  int total,
);

/// Builder for creating the done button.
///
/// This allows for customization of the done button appearance.
typedef DoneButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
  int selectedCount,
);

/// Builder for creating the placeholder when the list is empty.
///
/// This allows for customization of what is shown when there are no items.
typedef EmptyPlaceholderBuilder = Widget Function(
  BuildContext context,
);

/// Default implementations of the builders for use when custom builders are not provided.
class DefaultBuilders {
  /// Creates a default header for the ReorderableMultiSelectList.
  static Widget defaultHeaderBuilder(
    BuildContext context,
    List<dynamic> selectedItems,
    bool isSelectionMode,
  ) {
    return isSelectionMode
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected ${selectedItems.length} item(s)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        : const SizedBox.shrink();
  }

  /// Creates a default footer for the ReorderableMultiSelectList.
  static Widget defaultFooterBuilder(
    BuildContext context,
    List<dynamic> selectedItems,
    bool isSelectionMode,
    VoidCallback onDone,
  ) {
    return isSelectionMode
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onDone,
              child: Text('Done (${selectedItems.length})'),
            ),
          )
        : const SizedBox.shrink();
  }

  /// Creates a default drag handle for the ReorderableMultiSelectList.
  static Widget defaultDragHandleBuilder(
    BuildContext context,
    bool isSelected,
    bool isDragging,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        Icons.drag_handle,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  /// Creates a default checkbox for the ReorderableMultiSelectList.
  static Widget defaultCheckboxBuilder(
    BuildContext context,
    bool isSelected,
    ValueChanged<bool?> onChanged,
  ) {
    return Checkbox(
      value: isSelected,
      onChanged: onChanged,
    );
  }

  /// Creates a default selection count indicator for the ReorderableMultiSelectList.
  static Widget defaultSelectionCountBuilder(
    BuildContext context,
    int count,
    int total,
  ) {
    return Text(
      'Selected $count of $total',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  /// Creates a default done button for the ReorderableMultiSelectList.
  static Widget defaultDoneButtonBuilder(
    BuildContext context,
    VoidCallback onPressed,
    int selectedCount,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Done ($selectedCount)'),
    );
  }

  /// Creates a default placeholder for when the list is empty.
  static Widget defaultEmptyPlaceholderBuilder(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No items available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
