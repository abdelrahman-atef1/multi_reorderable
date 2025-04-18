import 'package:flutter/material.dart';
import 'package:multi_reorderable/multi_reorderable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reorderable Multi Select Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ExampleScreen(),
    const AdvancedExampleScreen(),
    const PaginationExampleScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Basic Example',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Advanced Example',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_array),
            label: 'Pagination',
          ),
        ],
      ),
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
        title: const Text('Basic Example'),
      ),
      body: Column(
        children: [
          // Basic usage example
          Expanded(
            child: ReorderableMultiDragList<ItemData>(
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
              onReorder: (reorderedItems) {
                setState(() {
                  items = reorderedItems;
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
              theme: ReorderableMultiDragTheme(
                selectionBarColor: Theme.of(context).colorScheme.surface,
                selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
                itemColor: Theme.of(context).colorScheme.surface,
                draggedItemBorderColor: Theme.of(context).colorScheme.primary,
              ),
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

// Advanced Example Screen
class AdvancedExampleScreen extends StatefulWidget {
  const AdvancedExampleScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedExampleScreen> createState() => _AdvancedExampleScreenState();
}

class _AdvancedExampleScreenState extends State<AdvancedExampleScreen> {
  // Sample data
  List<TaskItem> tasks = List.generate(
    15,
    (index) => TaskItem(
      id: 'task_$index',
      title: 'Task ${index + 1}',
      description: 'Complete task ${index + 1} before deadline',
      priority: TaskPriority.values[index % TaskPriority.values.length],
      dueDate: DateTime.now().add(Duration(days: index + 1)),
      isCompleted: false,
    ),
  );

  // Selected items
  List<TaskItem> selectedTasks = [];

  // Custom theme
  late ReorderableMultiDragTheme customTheme;

  @override
  void initState() {
    super.initState();
    // Initialize with some selected tasks
    selectedTasks = [tasks[0], tasks[2]];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create custom theme based on app theme
    customTheme = ReorderableMultiDragTheme(
      selectionBarColor: Theme.of(context).colorScheme.primaryContainer,
      selectedItemColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      itemColor: Theme.of(context).colorScheme.surface,
      draggedItemBorderColor: Theme.of(context).colorScheme.primary,
      itemBorderRadius: 12.0,
      itemHorizontalMargin: 16.0,
      itemVerticalMargin: 8.0,
      maxStackOffset: 12.0,
      maxStackRotation: 3.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Custom header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Task Manager',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    'Selected ${selectedTasks.length} / ${tasks.length} tasks',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Advanced usage example with custom builders and theme
            Expanded(
              child: ReorderableMultiDragList<TaskItem>(
                items: tasks,
                itemBuilder: (context, task, index, isSelected, isDragging) {
                  return _buildTaskItem(task, index);
                },
                onReorder: (reorderedItems) {
                  setState(() {
                    tasks = reorderedItems;
                  });
                },
                onSelectionChanged: (selected) {
                  setState(() {
                    selectedTasks = List.from(selected);
                  });
                },
                onDone: (selected) {
                  // Mark selected tasks as completed
                  setState(() {
                    for (final task in selected) {
                      final index = tasks.indexWhere((t) => t.id == task.id);
                      if (index != -1) {
                        tasks[index] = tasks[index].copyWith(isCompleted: true);
                      }
                    }
                    selectedTasks = [];
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${selected.length} tasks as completed'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                initialSelection: selectedTasks,
                showDoneButton: false,
                doneButtonText: 'Mark as Completed',
                showSelectionCount: false,
                selectionCountText: '{} tasks selected',
                itemHeight: 100.0,
                showDividers: true,
                theme: customTheme,
                dragAnimationDuration: const Duration(milliseconds: 200),
                reorderAnimationDuration: const Duration(milliseconds: 300),
                headerWidget: _buildCustomHeader(context, selectedTasks, selectedTasks.isNotEmpty),
                footerWidget: selectedTasks.isNotEmpty 
                    ? _buildCustomFooter(
                        context, 
                        selectedTasks, 
                        true, 
                        () => _markTasksAsCompleted(selectedTasks)
                      )
                    : null,
                dragHandleBuilder: (context, isSelected) => _buildCustomDragHandle(
                  context, 
                  isSelected, 
                  false
                ),
                selectionBarBuilder: (context, selectedCount, onDone) {
                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Custom builders
  Widget _buildTaskItem(TaskItem task, int index) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getPriorityIcon(task.priority),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted 
                          ? Theme.of(context).colorScheme.outline 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOverdue(task.dueDate) && !task.isCompleted
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: task.isCompleted 
                      ? Theme.of(context).colorScheme.outline 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            if (task.isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    List<dynamic> selectedItems,
    bool isSelectionMode,
  ) {
    if (!isSelectionMode) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Selection Mode',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFooter(
    BuildContext context,
    List<dynamic> selectedItems,
    bool isSelectionMode,
    VoidCallback onDone,
  ) {
    if (!isSelectionMode) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                selectedTasks.clear();
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Selection'),
          ),
          ElevatedButton.icon(
            onPressed: onDone,
            icon: const Icon(Icons.task_alt),
            label: Text('Complete (${selectedItems.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDragHandle(
    BuildContext context,
    bool isSelected,
    bool isDragging,
  ) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Icon(
        Icons.drag_indicator,
        color: isDragging
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        size: 24,
      ),
    );
  }

  Widget _buildCustomSelectionCount(
    BuildContext context,
    int count,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        '$count of $total tasks selected',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCustomDoneButton(
    BuildContext context,
    VoidCallback onPressed,
    int selectedCount,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.task_alt),
      label: Text('Complete $selectedCount tasks'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task using the + button',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewTask,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _getPriorityIcon(TaskPriority priority) {
    IconData iconData;
    Color color;
    
    switch (priority) {
      case TaskPriority.low:
        iconData = Icons.arrow_downward;
        color = Colors.green;
        break;
      case TaskPriority.medium:
        iconData = Icons.remove;
        color = Colors.orange;
        break;
      case TaskPriority.high:
        iconData = Icons.arrow_upward;
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 16,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference < 7) {
      return '${difference} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  void _addNewTask() {
    final newIndex = tasks.length;
    setState(() {
      tasks.add(
        TaskItem(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
          title: 'New Task ${newIndex + 1}',
          description: 'Description for new task ${newIndex + 1}',
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(days: 3)),
          isCompleted: false,
        ),
      );
    });
  }

  void _markTasksAsCompleted(List<TaskItem> tasksToComplete) {
    setState(() {
      for (final task in tasksToComplete) {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = tasks[index].copyWith(isCompleted: true);
        }
      }
      selectedTasks = [];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${tasksToComplete.length} tasks as completed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Task data model
class TaskItem {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Task priority enum
enum TaskPriority {
  low,
  medium,
  high,
}

// Pagination Example Screen
class PaginationExampleScreen extends StatefulWidget {
  const PaginationExampleScreen({Key? key}) : super(key: key);

  @override
  State<PaginationExampleScreen> createState() => _PaginationExampleScreenState();
}

class _PaginationExampleScreenState extends State<PaginationExampleScreen> {
  // Sample data with pagination
  List<ItemData> items = [];
  
  // Create a global key to access the list state
  final listKey = GlobalKey<ReorderableMultiDragListState<ItemData>>();
  
  // Pagination settings
  final int pageSize = 15;
  int totalItems = 200; // simulate a large dataset
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    _loadInitialData();
  }

  // Simulates loading initial data
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      // Generate initial items
      items = List.generate(
        pageSize,
        (index) => ItemData(
          id: 'item_$index',
          title: 'Item ${index + 1}',
          subtitle: 'Description for item ${index + 1}',
          color: Colors.primaries[index % Colors.primaries.length],
        ),
      );
      isLoading = false;
    });
  }

  // Load more data when scrolling
  Future<void> _loadMoreData(int page, int pageSize) async {
    // Skip if we've loaded all items
    if (items.length >= totalItems) return;
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      // Calculate the start index for the next page
      final startIndex = items.length;
      // Determine how many more items to add (handle reaching the end)
      final itemsToAdd = (startIndex + pageSize > totalItems) 
          ? totalItems - startIndex 
          : pageSize;
      
      // Add new items
      items.addAll(
        List.generate(
          itemsToAdd,
          (index) {
            final actualIndex = startIndex + index;
            return ItemData(
              id: 'item_$actualIndex',
              title: 'Item ${actualIndex + 1}',
              subtitle: 'Description for item ${actualIndex + 1}',
              color: Colors.primaries[actualIndex % Colors.primaries.length],
            );
          },
        ),
      );
    });
  }

  // Refresh all data
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      // Generate fresh items
      items = List.generate(
        pageSize,
        (index) => ItemData(
          id: 'item_$index',
          title: 'Item ${index + 1} (Refreshed)',
          subtitle: 'Updated description for item ${index + 1}',
          color: Colors.primaries[index % Colors.primaries.length],
        ),
      );
      isLoading = false;
    });
    
    // Refresh the list widget
    listKey.currentState?.refreshItems(resetPagination: true);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Showing ${items.length} of $totalItems items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ReorderableMultiDragList<ItemData>(
                    listKey: listKey,
                    items: items,
                    pageSize: pageSize,
                    onPageRequest: _loadMoreData,
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
                    onReorder: (reorderedItems) {
                      setState(() {
                        items = reorderedItems;
                      });
                    },
                    headerWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Text(
                        'Scroll down to load more items',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    footerWidget: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'End of list - ${items.length} items loaded',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    theme: ReorderableMultiDragTheme(
                      selectionBarColor: Theme.of(context).colorScheme.surface,
                      selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
                      itemColor: Theme.of(context).colorScheme.surface,
                      draggedItemBorderColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
