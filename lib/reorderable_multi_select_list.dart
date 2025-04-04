import 'package:flutter/material.dart';

/// A reusable widget for multi-selection and animated reordering of items.
/// 
/// This widget allows users to:
/// 1. Select multiple items using checkboxes
/// 2. Drag and drop items to reorder them
/// 3. See selected items stacked with a slight offset when dragging
class ReorderableMultiSelectList<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;
  
  /// Builder function to create a widget for each item
  final Widget Function(BuildContext context, T item, int index, bool isSelected, bool isDragging) itemBuilder;
  
  /// Callback when items are reordered
  final void Function(int oldIndex, int newIndex) onReorder;
  
  /// Callback when selection changes
  final void Function(List<T> selectedItems) onSelectionChanged;
  
  /// Callback when the "Done" button is pressed
  final void Function(List<T> selectedItems) onDone;
  
  /// Optional initial selection
  final List<T>? initialSelection;
  
  /// Whether to show the done button
  final bool showDoneButton;
  
  /// Text for the done button
  final String doneButtonText;
  
  /// Whether to show the selection count
  final bool showSelectionCount;
  
  /// Text format for selection count (use {} for count placeholder)
  final String selectionCountText;
  
  /// Offset for stacking selected items when dragging
  final Offset stackOffset;
  
  /// The height of each item
  final double itemHeight;
  
  /// Whether to show dividers between items
  final bool showDividers;
  
  /// Animation duration for the collect animation
  final Duration collectAnimationDuration;
  
  /// Maximum stack offset for cards
  final double maxStackOffset;
  
  /// Maximum rotation for cards in the stack
  final double maxStackRotation;
  
  const ReorderableMultiSelectList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    required this.onSelectionChanged,
    required this.onDone,
    this.initialSelection,
    this.showDoneButton = true,
    this.doneButtonText = 'تم',
    this.showSelectionCount = true,
    this.selectionCountText = 'تم اختيار {} عنصر',
    this.stackOffset = const Offset(4, 4),
    this.itemHeight = 80.0,
    this.showDividers = true,
    this.collectAnimationDuration = const Duration(milliseconds: 300),
    this.maxStackOffset = 8.0,
    this.maxStackRotation = 2.0,
  });

  @override
  State<ReorderableMultiSelectList<T>> createState() => _ReorderableMultiSelectListState<T>();
}

class _ReorderableMultiSelectListState<T> extends State<ReorderableMultiSelectList<T>> with SingleTickerProviderStateMixin {
  /// Set of selected items
  late Set<T> _selectedItems;
  
  /// Currently dragged item index
  int? _draggedItemIndex;
  
  /// Whether we're in selection mode
  bool _isSelectionMode = false;
  
  /// Animation controller for the collect animation
  late AnimationController _collectAnimationController;
  
  /// Animation for collecting items
  late Animation<double> _collectAnimation;
  
  @override
  void initState() {
    super.initState();
    _selectedItems = Set<T>.from(widget.initialSelection ?? []);
    _isSelectionMode = _selectedItems.isNotEmpty;
    
    // Initialize animation controller
    _collectAnimationController = AnimationController(
      vsync: this,
      duration: widget.collectAnimationDuration,
    );
    
    _collectAnimation = CurvedAnimation(
      parent: _collectAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _collectAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReorderableMultiSelectList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      _selectedItems = Set<T>.from(widget.initialSelection ?? []);
      _isSelectionMode = _selectedItems.isNotEmpty;
    }
    
    if (oldWidget.collectAnimationDuration != widget.collectAnimationDuration) {
      _collectAnimationController.duration = widget.collectAnimationDuration;
    }
  }

  /// Toggle selection of an item
  void _toggleSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(item);
        _isSelectionMode = true;
      }
      widget.onSelectionChanged(List<T>.from(_selectedItems));
    });
  }

  /// Start dragging an item
  void _onDragStarted(int index) {
    final item = widget.items[index];
    
    setState(() {
      _draggedItemIndex = index;
      
      // If we're not in selection mode and start dragging, 
      // automatically select the dragged item
      if (!_isSelectionMode) {
        _isSelectionMode = true;
        _selectedItems.add(item);
        widget.onSelectionChanged(List<T>.from(_selectedItems));
      }
    });
    
    // Start the collect animation
    _collectAnimationController.forward();
  }

  /// End dragging an item
  void _onDragEnded() {
    setState(() {
      _draggedItemIndex = null;
    });
    
    // Reset the collect animation
    _collectAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selection controls
        if (_isSelectionMode) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                if (widget.showSelectionCount) ...[
                  Text(
                    widget.selectionCountText.replaceAll('{}', _selectedItems.length.toString()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
                if (widget.showDoneButton)
                  TextButton(
                    onPressed: () {
                      widget.onDone(List<T>.from(_selectedItems));
                      setState(() {
                        _isSelectionMode = false;
                        _selectedItems.clear();
                      });
                    },
                    child: Text(widget.doneButtonText),
                  ),
              ],
            ),
          ),
        ],
        
        // Reorderable list
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = _selectedItems.contains(item);
              final isDragging = _draggedItemIndex == index;
              
              final itemWidget = widget.itemBuilder(context, item, index, isSelected, isDragging);
              
              return Container(
                key: ValueKey(index),
                margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag handle
                      ReorderableDragStartListener(
                        index: index,
                        child: GestureDetector(
                          onPanStart: (_) => _onDragStarted(index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.drag_handle,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      if (_isSelectionMode) ...[
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(item),
                        ),
                        const SizedBox(width: 4),
                      ],
                      // Item content
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSelectionMode ? () => _toggleSelection(item) : null,
                          onLongPress: !_isSelectionMode ? () {
                            setState(() {
                              _isSelectionMode = true;
                              _selectedItems.add(item);
                              widget.onSelectionChanged(List<T>.from(_selectedItems));
                            });
                          } : null,
                          child: itemWidget,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              // Always ensure the dragged item is selected
              final draggedItem = widget.items[oldIndex];
              if (!_selectedItems.contains(draggedItem)) {
                setState(() {
                  _selectedItems.add(draggedItem);
                  widget.onSelectionChanged(List<T>.from(_selectedItems));
                });
              }
              
              // If we're in selection mode and the dragged item is selected
              if (_isSelectionMode && _selectedItems.contains(draggedItem)) {
                setState(() {
                  // Get all selected indices in ascending order
                  final List<int> selectedIndices = [];
                  final List<T> selectedItems = [];
                  
                  for (int i = 0; i < widget.items.length; i++) {
                    if (_selectedItems.contains(widget.items[i])) {
                      selectedIndices.add(i);
                      selectedItems.add(widget.items[i]);
                    }
                  }
                  
                  // Adjust the target index based on the number of selected items
                  // that come before the target position
                  int targetIndex = newIndex;
                  if (oldIndex < newIndex) {
                    // When dragging downwards, we need to adjust for the removal of items
                    targetIndex -= 1;
                    
                    // Count how many selected items are before the target index
                    // but will be removed
                    int selectedItemsBeforeTarget = 0;
                    for (int idx in selectedIndices) {
                      if (idx < targetIndex) {
                        selectedItemsBeforeTarget++;
                      }
                    }
                    
                    // Adjust target index to account for removed items
                    targetIndex -= selectedItemsBeforeTarget;
                  }
                  
                  // Create a copy of the items list to work with
                  final List<T> newItems = List<T>.from(widget.items);
                  
                  // Remove all selected items
                  newItems.removeWhere((item) => _selectedItems.contains(item));
                  
                  // Insert all selected items at the target position
                  newItems.insertAll(targetIndex, selectedItems);
                  
                  // Update the original list
                  widget.items.clear();
                  widget.items.addAll(newItems);
                  
                  // Notify about the reordering
                  widget.onReorder(oldIndex, newIndex);
                });
              } else {
                // Standard single item reordering
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                widget.onReorder(oldIndex, newIndex);
              }
              
              // End the drag
              _onDragEnded();
            },
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              final item = widget.items[index];
              
              // Always use the enhanced animation when in selection mode
              if (_isSelectionMode) {
                // Create a real stack of all selected items
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    // Combine the drag animation with our collect animation
                    final double dragProgress = animation.value;
                    final double collectProgress = _collectAnimation.value;
                    
                    // Calculate the scale based on both animations
                    final double scale = 1.0 - 0.05 * dragProgress;
                    
                    // First, create a list of all the items that should be in the stack
                    final List<Widget> stackItems = [];
                    
                    // Add all selected items to the stack (except the dragged one)
                    for (int i = 0; i < _selectedItems.length; i++) {
                      final T currentItem = _selectedItems.elementAt(i);
                      
                      // Calculate the position in the stack (0 is top, length-1 is bottom)
                      final int stackPosition = _selectedItems.length - 1 - i;
                      
                      // Skip the dragged item as it will be shown separately
                      if (currentItem == item) continue;
                      
                      // Find the index of this selected item
                      final itemIndex = widget.items.indexOf(currentItem);
                      if (itemIndex == -1) continue;
                      
                      // Build a card for this item
                      final itemWidget = widget.itemBuilder(
                        context, 
                        currentItem, 
                        itemIndex, 
                        true, 
                        false
                      );
                      
                      // Calculate offset based on stack position and collect animation
                      final double offsetAmount = widget.maxStackOffset * (1 - collectProgress);
                      final double xOffset = offsetAmount * stackPosition;
                      final double yOffset = offsetAmount * stackPosition;
                      
                      // Calculate rotation based on stack position (alternating)
                      final double rotation = (stackPosition % 2 == 0 ? 1 : -1) * 
                                            widget.maxStackRotation * 
                                            (stackPosition / _selectedItems.length) * 
                                            (1 - collectProgress);
                      
                      // Create a widget for this item in the stack
                      stackItems.add(
                        Transform.translate(
                          offset: Offset(xOffset, yOffset),
                          child: Transform.rotate(
                            angle: rotation * (3.14159 / 180), // Convert to radians
                            child: Opacity(
                              opacity: 1.0 - (collectProgress * 0.2 * stackPosition / _selectedItems.length),
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: (_selectedItems.length - stackPosition) * 0.5,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.drag_handle,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                      if (_isSelectionMode) ...[
                                        Checkbox(
                                          value: true,
                                          onChanged: null,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Expanded(child: itemWidget),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    }
                    
                    // Now add the dragged item on top
                    stackItems.add(child);
                    
                    // Create the final stack with proper sizing
                    return Material(
                      elevation: 6.0 * dragProgress,
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: stackItems,
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Default decoration for single item
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final double scale = 1.0 - 0.05 * animation.value;
                    return Material(
                      elevation: 4.0 * animation.value,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
