import 'package:flutter/material.dart';
import 'builders/builders.dart';
import 'models/reorderable_item_model.dart';
import 'theme/reorderable_multi_select_theme.dart';

/// A reusable widget for multi-selection and animated reordering of items.
///
/// This widget allows users to:
/// 1. Select multiple items using checkboxes
/// 2. Drag and drop items to reorder them
/// 3. See selected items stacked with a slight offset when dragging
///
/// Example usage:
/// ```dart
/// ReorderableMultiSelectList<String>(
///   items: ['Item 1', 'Item 2', 'Item 3'],
///   itemBuilder: (context, item, index, isSelected, isDragging) {
///     return ListTile(
///       title: Text(item),
///     );
///   },
///   onReorder: (oldIndex, newIndex) {
///     // Handle reordering
///   },
///   onSelectionChanged: (selectedItems) {
///     // Handle selection changes
///   },
///   onDone: (selectedItems) {
///     // Handle done button press
///   },
/// )
/// ```
class ReorderableMultiSelectList<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;
  
  /// Builder function to create a widget for each item
  final ReorderableItemBuilder<T> itemBuilder;
  
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
  
  /// The height of each item
  final double itemHeight;
  
  /// Whether to show dividers between items
  final bool showDividers;
  
  /// Custom theme for the widget
  final ReorderableMultiSelectTheme? theme;
  
  /// Animation configuration
  final ReorderableAnimationConfig animationConfig;
  
  /// Stack configuration for dragging selected items
  final ReorderableStackConfig stackConfig;
  
  /// Custom builder for the header
  final ReorderableHeaderBuilder? headerBuilder;
  
  /// Custom builder for the footer
  final ReorderableFooterBuilder? footerBuilder;
  
  /// Custom builder for the drag handle
  final DragHandleBuilder? dragHandleBuilder;
  
  /// Custom builder for the checkbox
  final CheckboxBuilder? checkboxBuilder;
  
  /// Custom builder for the selection count
  final SelectionCountBuilder? selectionCountBuilder;
  
  /// Custom builder for the done button
  final DoneButtonBuilder? doneButtonBuilder;
  
  /// Custom builder for empty state
  final EmptyPlaceholderBuilder? emptyPlaceholderBuilder;
  
  /// Whether to show the drag handle
  final bool showDragHandle;
  
  /// Whether to enable long press to enter selection mode
  final bool enableLongPressSelection;
  
  /// Whether to enable reordering
  final bool enableReordering;
  
  /// Whether to enable selection
  final bool enableSelection;
  
  /// Creates a [ReorderableMultiSelectList] with the specified properties.
  const ReorderableMultiSelectList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    required this.onSelectionChanged,
    required this.onDone,
    this.initialSelection,
    this.showDoneButton = true,
    this.doneButtonText = 'Done',
    this.showSelectionCount = true,
    this.selectionCountText = 'Selected {} items',
    this.itemHeight = 80.0,
    this.showDividers = true,
    this.theme,
    this.animationConfig = const ReorderableAnimationConfig(),
    this.stackConfig = const ReorderableStackConfig(),
    this.headerBuilder,
    this.footerBuilder,
    this.dragHandleBuilder,
    this.checkboxBuilder,
    this.selectionCountBuilder,
    this.doneButtonBuilder,
    this.emptyPlaceholderBuilder,
    this.showDragHandle = true,
    this.enableLongPressSelection = true,
    this.enableReordering = true,
    this.enableSelection = true,
  }) : super(key: key);

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
  
  /// Get the current theme
  ReorderableMultiSelectTheme _getTheme(BuildContext context) {
    return widget.theme ?? ReorderableMultiSelectTheme.fromTheme(Theme.of(context));
  }
  
  @override
  void initState() {
    super.initState();
    _selectedItems = Set<T>.from(widget.initialSelection ?? []);
    _isSelectionMode = _selectedItems.isNotEmpty;
    
    // Initialize animation controller
    _collectAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.collectAnimationDuration,
    );
    
    _collectAnimation = CurvedAnimation(
      parent: _collectAnimationController,
      curve: widget.animationConfig.collectAnimationCurve,
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
    
    if (oldWidget.animationConfig.collectAnimationDuration != 
        widget.animationConfig.collectAnimationDuration) {
      _collectAnimationController.duration = widget.animationConfig.collectAnimationDuration;
    }
  }

  /// Toggle selection of an item
  void _toggleSelection(T item) {
    if (!widget.enableSelection) return;
    
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
      
      widget.onSelectionChanged(_selectedItems.toList());
    });
  }

  /// Start dragging an item
  void _onDragStarted(int index) {
    if (!widget.enableReordering) return;
    
    setState(() {
      _draggedItemIndex = index;
    });
    
    // Start the collect animation if we have selected items
    if (_selectedItems.contains(widget.items[index]) && _selectedItems.length > 1) {
      _collectAnimationController.forward(from: 0.0);
    }
  }

  /// End dragging an item
  void _onDragEnded() {
    setState(() {
      _draggedItemIndex = null;
    });
    
    // Reset the collect animation
    _collectAnimationController.reverse();
  }

  /// Build the header widget
  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(
        context, 
        _selectedItems.toList(), 
        _isSelectionMode
      );
    }
    
    return DefaultBuilders.defaultHeaderBuilder(
      context, 
      _selectedItems.toList(), 
      _isSelectionMode
    );
  }

  /// Build the footer widget
  Widget _buildFooter() {
    if (!widget.showDoneButton || !_isSelectionMode) {
      return const SizedBox.shrink();
    }
    
    if (widget.footerBuilder != null) {
      return widget.footerBuilder!(
        context, 
        _selectedItems.toList(), 
        _isSelectionMode, 
        () => widget.onDone(_selectedItems.toList())
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: widget.doneButtonBuilder != null
          ? widget.doneButtonBuilder!(
              context, 
              () => widget.onDone(_selectedItems.toList()), 
              _selectedItems.length
            )
          : ElevatedButton(
              onPressed: () => widget.onDone(_selectedItems.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTheme(context).primaryColor,
              ),
              child: Text(
                widget.doneButtonText,
                style: _getTheme(context).doneButtonTextStyle,
              ),
            ),
    );
  }

  /// Build the selection count widget
  Widget _buildSelectionCount() {
    if (!widget.showSelectionCount || !_isSelectionMode) {
      return const SizedBox.shrink();
    }
    
    if (widget.selectionCountBuilder != null) {
      return widget.selectionCountBuilder!(
        context, 
        _selectedItems.length, 
        widget.items.length
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        widget.selectionCountText.replaceAll('{}', _selectedItems.length.toString()),
        style: _getTheme(context).selectionCountTextStyle,
      ),
    );
  }

  /// Build the drag handle widget
  Widget _buildDragHandle(bool isSelected, bool isDragging) {
    if (!widget.showDragHandle || !widget.enableReordering) {
      return const SizedBox.shrink();
    }
    
    if (widget.dragHandleBuilder != null) {
      return widget.dragHandleBuilder!(context, isSelected, isDragging);
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        _getTheme(context).dragHandleIcon,
        color: _getTheme(context).dragHandleColor,
        size: _getTheme(context).dragHandleSize,
      ),
    );
  }

  /// Build the checkbox widget
  Widget _buildCheckbox(bool isSelected, ValueChanged<bool?> onChanged) {
    if (!_isSelectionMode && !isSelected) {
      return const SizedBox.shrink();
    }
    
    if (widget.checkboxBuilder != null) {
      return widget.checkboxBuilder!(context, isSelected, onChanged);
    }
    
    return Checkbox(
      value: isSelected,
      onChanged: widget.enableSelection ? onChanged : null,
      activeColor: _getTheme(context).checkboxActiveColor,
      side: BorderSide(
        color: _getTheme(context).checkboxBorderColor,
      ),
    );
  }

  /// Build the empty placeholder widget
  Widget _buildEmptyPlaceholder() {
    if (widget.emptyPlaceholderBuilder != null) {
      return widget.emptyPlaceholderBuilder!(context);
    }
    
    return DefaultBuilders.defaultEmptyPlaceholderBuilder(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(context);
    
    if (widget.items.isEmpty) {
      return _buildEmptyPlaceholder();
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildSelectionCount(),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = _selectedItems.contains(item);
              final isDragging = _draggedItemIndex == index;
              
              // Build the item widget using the provided builder
              final itemWidget = widget.itemBuilder(
                context, 
                item, 
                index, 
                isSelected, 
                isDragging
              );
              
              // Create the list item with selection and drag functionality
              Widget child = Container(
                height: widget.itemHeight,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.selectedItemBackgroundColor 
                      : theme.itemBackgroundColor,
                  borderRadius: theme.itemBorderRadius,
                ),
                child: Padding(
                  padding: theme.itemPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildDragHandle(isSelected, isDragging),
                      if (_isSelectionMode || isSelected) ...[
                        _buildCheckbox(
                          isSelected, 
                          (value) => _toggleSelection(item)
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(child: itemWidget),
                    ],
                  ),
                ),
              );
              
              // Wrap with gesture detector for long press selection
              if (widget.enableLongPressSelection) {
                child = GestureDetector(
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      setState(() {
                        _isSelectionMode = true;
                        _toggleSelection(item);
                      });
                    }
                  },
                  onTap: _isSelectionMode 
                      ? () => _toggleSelection(item) 
                      : null,
                  child: child,
                );
              }
              
              // Create the final item with key for reordering
              return Container(
                key: ValueKey(item),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    child,
                    if (widget.showDividers && index < widget.items.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                  ],
                ),
              );
            },
            onReorder: widget.enableReordering 
                ? widget.onReorder 
                : (_, __) {},
            onReorderStart: (index) => _onDragStarted(index),
            onReorderEnd: (_) => _onDragEnded(),
            proxyDecorator: (child, index, animation) {
              // Get the item
              final item = widget.items[index];
              final isSelected = _selectedItems.contains(item);
              
              // If the item is selected and there are multiple selected items,
              // show a stack of items
              if (isSelected && _selectedItems.length > 1) {
                // Get the progress of the collect animation
                final collectProgress = _collectAnimation.value;
                
                // Create a list to hold the stack items
                final stackItems = <Widget>[];
                
                // Add selected items to the stack (except the dragged one)
                final selectedItemsList = _selectedItems.toList();
                final maxStackItems = widget.stackConfig.maxStackItems;
                final itemsToShow = selectedItemsList.length > maxStackItems 
                    ? maxStackItems 
                    : selectedItemsList.length;
                
                for (int i = 0; i < itemsToShow; i++) {
                  if (selectedItemsList[i] == item) continue;
                  
                  // Get the item widget
                  final stackItem = selectedItemsList[i];
                  final stackItemIndex = widget.items.indexOf(stackItem);
                  final stackItemWidget = widget.itemBuilder(
                    context, 
                    stackItem, 
                    stackItemIndex, 
                    true, 
                    false
                  );
                  
                  // Calculate position in the stack (0 is at the bottom)
                  final stackPosition = i;
                  
                  // Calculate offsets based on stack position
                  final xOffset = widget.stackConfig.stackOffset.dx * 
                                 (stackPosition + 1) * 
                                 (1 - collectProgress);
                  
                  final yOffset = widget.stackConfig.stackOffset.dy * 
                                 (stackPosition + 1) * 
                                 (1 - collectProgress);
                  
                  // Calculate rotation based on stack position
                  final rotation = widget.stackConfig.maxStackRotation * 
                                  (stackPosition / _selectedItems.length) * 
                                  (1 - collectProgress);
                  
                  // Create a widget for this item in the stack
                  stackItems.add(
                    Transform.translate(
                      offset: Offset(xOffset, yOffset),
                      child: Transform.rotate(
                        angle: rotation * (3.14159 / 180), // Convert to radians
                        child: Opacity(
                          opacity: theme.stackItemOpacity - 
                                  (collectProgress * 0.2 * stackPosition / _selectedItems.length),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: theme.cardElevation * (_selectedItems.length - stackPosition) * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  _buildDragHandle(true, false),
                                  if (_isSelectionMode) ...[
                                    _buildCheckbox(true, (_) {}),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(child: stackItemWidget),
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
                  elevation: theme.draggedCardElevation * animation.value,
                  child: Transform.scale(
                    scale: 1.0 - theme.dragScaleFactor * animation.value,
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
              } else {
                // Default decoration for single item
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final double scale = 1.0 - theme.dragScaleFactor * animation.value;
                    return Material(
                      elevation: theme.draggedCardElevation * animation.value,
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
        _buildFooter(),
      ],
    );
  }
}
