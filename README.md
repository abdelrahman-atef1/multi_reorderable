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
- **Pagination Support**: Load more items as the user scrolls, with state preservation
- **Pull-to-Refresh**: Standard pull-to-refresh functionality for reloading data
- **Programmable Refresh**: Refresh the list from outside using a GlobalKey

## Examples

### Simple Usage
![Simple Example](https://i.ibb.co/RGNr8JKQ/2025-04-19-04-42-19.gif)

### Advanced Usage
![Advanced Example](https://i.ibb.co/7fyyxN7/2025-04-04-04-39-17.gif)

## Drag Styles

### Stacked Style
The default style stacks items neatly behind the dragged item:
![Stacked Style](https://i.ibb.co/RGNr8JKQ/2025-04-19-04-42-19.gif)

### Animated Cards
Provides a modern animated card interface for your dragged items:
![Animated Cards](https://i.ibb.co/ZpZXhFZJ/2025-04-19-04-42-09.gif)

### Minimalist
A clean, simple approach with minimal visual elements:
![Minimalist Style](https://i.ibb.co/9k6mH3ZR/2025-04-19-04-41-56.gif)

Changing between styles is simple:
```dart
ReorderableMultiDragTheme(
  // Normal theme properties
  draggedItemBorderColor: Colors.blue,
  itemBorderRadius: 8.0,
  // Set the drag style
  dragStyle: DragStyle.animatedCardStyle, // or .stackedStyle, .minimalistStyle
)
```

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  multi_reorderable: ^0.2.0
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

Improved pagination that calculates page numbers dynamically based on items count:

```dart
// Create a global key to access the widget's state
final listKey = GlobalKey<ReorderableMultiDragListState<MyItem>>();

// In your build method
ReorderableMultiDragList<MyItem>(
  listKey: listKey,
  items: myItems,
  pageSize: 20, // Number of items per page
  onPageRequest: (page, pageSize) async {
    print('Loading page: $page'); // Page number is calculated from items.length
    
    // Update your API request with the correct page number
    final request = YourRequestObject()..page = page;
    
    // Load more items when user scrolls
    final newItems = await yourApi.fetchItems(request);
    
    setState(() {
      // Add new items to your list (not replace)
      myItems.addAll(newItems);
    });
  },
  // ... other properties
)
```

### Pull-to-Refresh

Enable pull-to-refresh functionality:

```dart
ReorderableMultiDragList<MyItem>(
  // ... other properties
  enablePullToRefresh: true, // Enable pull-to-refresh
  onRefresh: () async {
    // Clear your existing items
    setState(() {
      myItems.clear();
    });
    
    // Fetch fresh data (first page)
    final response = await yourApi.fetchItems(page: 1);
    
    setState(() {
      myItems.addAll(response.items);
    });
  },
  // Customize refresh indicator (optional)
  refreshIndicatorColor: Colors.blue,
  refreshIndicatorBackgroundColor: Colors.white,
  refreshIndicatorDisplacement: 40.0,
)
```

If you don't provide an `onRefresh` callback, the widget will automatically use the `onPageRequest` callback with page 1.

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
