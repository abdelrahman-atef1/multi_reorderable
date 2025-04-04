import 'package:flutter/material.dart';
import 'package:multi_reorderable/reorderable_multi_select.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reorderable Multi Select Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // Sample data
  List<ItemData> items = List.generate(
    20,
    (index) => ItemData(
      id: 'item_$index',
      title: 'Item ${index + 1}',
      subtitle: 'Description for item ${index + 1}',
      color: Colors.primaries[index % Colors.primaries.length],
    ),
  );

  // Selected items
  List<ItemData> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorderable Multi Select Demo'),
      ),
      body: Column(
        children: [
          // Basic usage example
          Expanded(
            child: ReorderableMultiSelectList<ItemData>(
              items: items,
              itemBuilder: (context, item, index, isSelected, isDragging) {
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  leading: CircleAvatar(
                    backgroundColor: item.color,
                    child: Text('${index + 1}'),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                });
              },
              onSelectionChanged: (selected) {
                setState(() {
                  selectedItems = List.from(selected);
                });
              },
              onDone: (selected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected ${selected.length} items'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              initialSelection: selectedItems,
              showDoneButton: true,
              doneButtonText: 'Done',
              showSelectionCount: true,
              selectionCountText: 'Selected {} items',
              itemHeight: 80.0,
              showDividers: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Selected ${selectedItems.length} items',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

// Example data model
class ItemData {
  final String id;
  final String title;
  final String subtitle;
  final Color color;

  ItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
