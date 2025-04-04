import 'package:flutter/material.dart';
import 'package:multi_reorderable/reorderable_multi_select.dart';

void main() {
  runApp(const AdvancedExampleApp());
}

class AdvancedExampleApp extends StatelessWidget {
  const AdvancedExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Reorderable Multi Select Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AdvancedExampleScreen(),
    );
  }
}

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
  late ReorderableMultiSelectTheme customTheme;

  // Animation config
  final animationConfig = const ReorderableAnimationConfig(
    collectAnimationDuration: Duration(milliseconds: 400),
    reorderAnimationDuration: Duration(milliseconds: 300),
    dragAnimationDuration: Duration(milliseconds: 200),
    collectAnimationCurve: Curves.easeOutQuart,
  );

  // Stack config
  final stackConfig = const ReorderableStackConfig(
    stackOffset: Offset(6, 6),
    maxStackOffset: 12.0,
    maxStackRotation: 3.0,
    maxStackItems: 4,
  );

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
    customTheme = ReorderableMultiSelectTheme(
      primaryColor: Theme.of(context).colorScheme.primary,
      itemBackgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      dividerColor: Theme.of(context).dividerColor,
      itemTextStyle: Theme.of(context).textTheme.bodyLarge!,
      selectionCountTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      doneButtonTextStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      cardElevation: 2.0,
      draggedCardElevation: 8.0,
      itemBorderRadius: BorderRadius.circular(12.0),
      itemPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      listPadding: const EdgeInsets.all(16.0),
      listDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(16.0),
      ),
      headerDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      footerDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      checkboxActiveColor: Theme.of(context).colorScheme.primary,
      checkboxBorderColor: Theme.of(context).colorScheme.outline,
      dragHandleColor: Theme.of(context).colorScheme.onSurfaceVariant,
      dragHandleSize: 24.0,
      dragHandleIcon: Icons.drag_indicator,
      dragScaleFactor: 0.03,
      stackItemOpacity: 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Multi-Select Demo'),
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
                    '${tasks.length} tasks',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Advanced usage example with custom builders and theme
            Expanded(
              child: ReorderableMultiSelectList<TaskItem>(
                items: tasks,
                itemBuilder: (context, task, index, isSelected, isDragging) {
                  return _buildTaskItem(task, index);
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final task = tasks.removeAt(oldIndex);
                    tasks.insert(newIndex, task);
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
                showDoneButton: true,
                doneButtonText: 'Mark as Completed',
                showSelectionCount: true,
                selectionCountText: '{} tasks selected',
                itemHeight: 100.0,
                showDividers: true,
                theme: customTheme,
                animationConfig: animationConfig,
                stackConfig: stackConfig,
                headerBuilder: _buildCustomHeader,
                footerBuilder: _buildCustomFooter,
                dragHandleBuilder: _buildCustomDragHandle,
                checkboxBuilder: _buildCustomCheckbox,
                selectionCountBuilder: _buildCustomSelectionCount,
                doneButtonBuilder: _buildCustomDoneButton,
                emptyPlaceholderBuilder: _buildEmptyPlaceholder,
                showDragHandle: true,
                enableLongPressSelection: true,
                enableReordering: true,
                enableSelection: true,
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

  Widget _buildCustomCheckbox(
    BuildContext context,
    bool isSelected,
    ValueChanged<bool?> onChanged,
  ) {
    return Checkbox(
      value: isSelected,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
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
