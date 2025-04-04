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

# Reorderable Multi-Select List

A highly customizable Flutter widget for multi-selection and animated reordering of items.

## Features

- **Multi-selection**: Select multiple items with checkboxes
- **Reordering**: Drag and drop items to reorder them
- **Animated stacking**: Selected items are stacked with a slight offset when dragging
- **Highly customizable**: Extensive theming and builder support
- **Modular architecture**: Well-structured code with separation of concerns

![Demo Animation](https://via.placeholder.com/350x200.png?text=Reorderable+Multi+Select+Demo)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  reorderable_multi_select: ^1.0.0
```

Then import it in your Dart code:

```dart
import 'package:multi_reorderable/reorderable_multi_select.dart';
```

## Basic Usage

```dart
ReorderableMultiSelectList<String>(
  items: ['Item 1', 'Item 2', 'Item 3'],
  itemBuilder: (context, item, index, isSelected, isDragging) {
    return ListTile(
      title: Text(item),
    );
  },
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  },
  onSelectionChanged: (selectedItems) {
    // Handle selection changes
    setState(() {
      this.selectedItems = selectedItems;
    });
  },
  onDone: (selectedItems) {
    // Handle done button press
  },
)
```

## Customization

### Theming

The widget can be styled using the `ReorderableMultiSelectTheme` class:

```dart
ReorderableMultiSelectList<String>(
  // ... other properties
  theme: ReorderableMultiSelectTheme(
    primaryColor: Colors.blue,
    itemBackgroundColor: Colors.white,
    selectedItemBackgroundColor: Colors.blue.withOpacity(0.1),
    dividerColor: Colors.grey,
    itemTextStyle: TextStyle(fontSize: 16),
    cardElevation: 2.0,
    itemBorderRadius: BorderRadius.circular(8.0),
    // ... many more styling options
  ),
)
```

You can also create a theme from the app's theme:

```dart
final customTheme = ReorderableMultiSelectTheme.fromTheme(Theme.of(context));
```

### Custom Builders

Customize every aspect of the widget using builder functions:

```dart
ReorderableMultiSelectList<TaskItem>(
  // ... other properties
  headerBuilder: (context, selectedItems, isSelectionMode) {
    // Build custom header
  },
  footerBuilder: (context, selectedItems, isSelectionMode, onDone) {
    // Build custom footer
  },
  dragHandleBuilder: (context, isSelected, isDragging) {
    // Build custom drag handle
  },
  checkboxBuilder: (context, isSelected, onChanged) {
    // Build custom checkbox
  },
  // ... other builders
)
```

### Animation Configuration

Customize animations using the `ReorderableAnimationConfig` class:

```dart
ReorderableMultiSelectList<String>(
  // ... other properties
  animationConfig: ReorderableAnimationConfig(
    collectAnimationDuration: Duration(milliseconds: 300),
    reorderAnimationDuration: Duration(milliseconds: 200),
    dragAnimationDuration: Duration(milliseconds: 150),
    collectAnimationCurve: Curves.easeInOut,
    // ... other animation properties
  ),
)
```

### Stack Configuration

Customize the stacking behavior when dragging selected items:

```dart
ReorderableMultiSelectList<String>(
  // ... other properties
  stackConfig: ReorderableStackConfig(
    stackOffset: Offset(4, 4),
    maxStackOffset: 8.0,
    maxStackRotation: 2.0,
    maxStackItems: 3,
  ),
)
```

## Advanced Example

See the `/example` folder for a complete example with advanced customization.

## License

This package is available under the MIT License.
