<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Multi Reorderable

A powerful and customizable Flutter widget for multi-selection and animated reordering of items.

[![Portfolio](https://img.shields.io/badge/Portfolio-Abdelrahman%20Atef-0077B5?style=for-the-badge&logo=googlechrome&logoColor=white)](https://abdelrahman.codesters-inc.com/)

[![Work with me](https://img.shields.io/badge/Work%20with%20me-Hire%20on%20Upwork-6FDA44?style=for-the-badge&logo=upwork&logoColor=white)](https://www.upwork.com/freelancers/abdelrahmanatef4)

## Features

- **Multi-selection**: Select multiple items with checkboxes
- **Drag & Drop Reordering**: Easily reorder items with smooth animations
- **Animated Stacking**: Selected items stack visually when being dragged
- **Customizable UI**: Extensive theming options and builder patterns
- **Selection Management**: Built-in selection state management with callbacks
- **Auto-scrolling**: Automatically scrolls when dragging near edges
- **Header & Footer Support**: Add custom widgets above and below the list
- **Pagination Support**: Load more items as the user scrolls
- **Programmable Refresh**: Refresh the list from outside using a GlobalKey

## Examples

### Simple Usage
![Simple Example](https://i.ibb.co/6cLfNdQj/2025-04-04-04-37-01.gif)

### Advanced Usage
![Advanced Example](https://i.ibb.co/7fyyxN7/2025-04-04-04-39-17.gif)


## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  multi_reorderable: ^0.0.1
```

Then import it in your Dart code:

```dart
import 'package:multi_reorderable/multi_reorderable.dart';
```

## Basic Usage

```dart
ReorderableMultiDragList<String>(
  items: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'],
  itemBuilder: (context, item, index, isSelected, isDragging) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      child: Text(
        item,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDragging ? Colors.grey : Colors.black,
        ),
      ),
    );
  },
  onReorder: (reorderedItems) {
    setState(() {
      items = reorderedItems;
    });
  },
  onSelectionChanged: (selectedItems) {
    print('Selected items: $selectedItems');
  },
  onDone: (selectedItems) {
    print('Done with selection: $selectedItems');
  },
)
```

## Customization

### Theming

Customize the appearance using the `ReorderableMultiDragTheme`:

```dart
ReorderableMultiDragList<String>(
  // ... other properties
  theme: ReorderableMultiDragTheme(
    itemColor: Colors.white,
    selectedItemColor: Colors.blue.shade50,
    selectionBarColor: Colors.blue.shade100,
    draggedItemBorderColor: Colors.blue,
    itemBorderRadius: 8.0,
    itemHorizontalMargin: 8.0,
    itemVerticalMargin: 4.0,
    maxStackOffset: 6.0,
    maxStackRotation: 3.0,
  ),
)
```

### Custom Builders

Use builder functions for advanced customization:

```dart
ReorderableMultiDragList<String>(
  // ... other properties
  selectionBarBuilder: (context, selectedCount, onDone) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey.shade100,
      child: Row(
        children: [
          Text('$selectedCount items selected'),
          const Spacer(),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  },
  dragHandleBuilder: (context, isSelected) {
    return Icon(
      Icons.drag_indicator,
      color: isSelected ? Colors.blue : Colors.grey,
    );
  },
)
```

### Additional Options

```dart
ReorderableMultiDragList<String>(
  // ... other properties
  showDoneButton: true,
  doneButtonText: 'Apply',
  showSelectionCount: true,
  selectionCountText: '{} selected',
  itemHeight: 70.0,
  showDividers: true,
  dragAnimationDuration: const Duration(milliseconds: 200),
  reorderAnimationDuration: const Duration(milliseconds: 300),
  autoScrollSpeed: 15.0,
  autoScrollThreshold: 100.0,
  headerWidget: Container(
    padding: const EdgeInsets.all(16),
    child: const Text('My Items', style: TextStyle(fontWeight: FontWeight.bold)),
  ),
  footerWidget: Container(
    padding: const EdgeInsets.all(16),
    child: const Text('Swipe to see more'),
  ),
)
```

### Pagination

Enable pagination to load more items as the user scrolls:

```dart
// Create a global key to access the widget's state
final listKey = GlobalKey<ReorderableMultiDragListState<MyItem>>();

// In your build method
ReorderableMultiDragList<MyItem>(
  listKey: listKey,
  items: myItems,
  pageSize: 20, // Number of items per page
  onPageRequest: (page, pageSize) async {
    // Load more items when user scrolls
    final newItems = await fetchMoreItems(page, pageSize);
    setState(() {
      myItems.addAll(newItems);
    });
  },
  // ... other properties
)
```

### Programmatic Refresh

Refresh the list from outside using the GlobalKey:

```dart
// Refresh the list programmatically
void refreshList() {
  // Reset pagination (optional)
  listKey.currentState?.refreshItems(resetPagination: true);
}

// Use in a button or other event
FloatingActionButton(
  onPressed: refreshList,
  child: Icon(Icons.refresh),
)
```

## Example

Check out the `/example` folder for a complete implementation.

## About the Developer

This package is developed and maintained by [Abdelrahman Atef](https://abdelrahman.codesters-inc.com/), a Flutter developer specializing in creating custom, high-quality UI components and applications.

[![Work with me](https://img.shields.io/badge/Work%20with%20me-Hire%20on%20Upwork-6FDA44?style=for-the-badge&logo=upwork&logoColor=white)](https://www.upwork.com/freelancers/abdelrahmanatef4)

Feel free to reach out for custom development or modifications to this package.

## License

This package is available under the MIT License.
