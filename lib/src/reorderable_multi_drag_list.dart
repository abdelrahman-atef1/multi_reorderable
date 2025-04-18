import 'package:flutter/material.dart';
import 'dart:async';

import 'theme/reorderable_multi_drag_theme.dart';
import 'utils/drag_list_utils.dart';

/// A custom reorderable widget that supports multi-selection and animated reordering.
///
/// Features:
/// 1. Multi-select widgets and move them together by dragging
/// 2. Animate all widgets' positions from origin to dragged point
/// 3. Selection is maintained after moving until "Done" is clicked
/// 4. Natural animations for all interactions
/// 5. Can move one item at a time
/// 6. Can use any widget as a child
class ReorderableMultiDragList<T> extends StatefulWidget {
  /// List of items to display
  final List<T> items;

  /// Builder function to create a widget for each item
  final Widget Function(BuildContext context, T item, int index, bool isSelected, bool isDragging) itemBuilder;

  /// Callback when items are reordered
  final void Function(List<T> reorderedItems) onReorder;

  /// Callback when selection changes
  final void Function(List<T> selectedItems)? onSelectionChanged;

  /// Callback when the "Done" button is pressed
  final void Function(List<T> selectedItems)? onDone;

  /// Optional initial selection
  final List<T>? initialSelection;

  /// Theme data for the reorderable list
  final ReorderableMultiDragTheme theme;

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

  /// Animation duration for dragging
  final Duration dragAnimationDuration;

  /// Animation duration for reordering
  final Duration reorderAnimationDuration;

  /// Auto-scroll speed when dragging near edges
  final double autoScrollSpeed;
  
  /// Auto-scroll threshold (distance from edge to trigger scrolling)
  final double autoScrollThreshold;

  /// Optional header widget to display at the top of the list
  final Widget? headerWidget;

  /// Optional footer widget to display at the bottom of the list
  final Widget? footerWidget;

  /// Optional builder for the selection bar
  final Widget Function(BuildContext context, int selectedCount, VoidCallback onDone)? selectionBarBuilder;

  /// Optional builder for the drag handle
  final Widget Function(BuildContext context, bool isSelected)? dragHandleBuilder;

  /// Add pagination parameters
  final int? pageSize;
  final Future<void> Function(int page, int pageSize)? onPageRequest;

  /// Creates a ReorderableMultiDragList widget
  ReorderableMultiDragList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.onPageRequest,
    this.pageSize = 20,
    this.onSelectionChanged,
    this.onDone,
    this.initialSelection,
    ReorderableMultiDragTheme? theme,
    this.showDoneButton = true,
    this.doneButtonText = 'Done',
    this.showSelectionCount = true,
    this.selectionCountText = '{} items selected',
    this.itemHeight = 80.0,
    this.showDividers = true,
    this.dragAnimationDuration = const Duration(milliseconds: 250),
    this.reorderAnimationDuration = const Duration(milliseconds: 300),
    this.autoScrollSpeed = 10.0,
    this.autoScrollThreshold = 100.0,
    this.headerWidget,
    this.footerWidget,
    this.selectionBarBuilder,
    this.dragHandleBuilder,
  }) : theme = theme ?? const ReorderableMultiDragTheme(),
      super();

  @override
  State<ReorderableMultiDragList<T>> createState() => _ReorderableMultiDragListState<T>();
}

class _ReorderableMultiDragListState<T> extends State<ReorderableMultiDragList<T>>
    with TickerProviderStateMixin {
  // Set of selected items
  late Set<T> _selectedItems;

  // Currently dragged item index
  int? _draggedItemIndex;

  // Whether we're in selection mode
  bool _isSelectionMode = false;

  // Position of the drag
  Offset? _dragPosition;

  // Animation controllers
  late AnimationController _dragAnimationController;
  late AnimationController _reorderAnimationController;

  // Animations
  late Animation<double> _reorderAnimation;

  // Scroll controller
  late ScrollController _scrollController;

  // List of item positions before reordering
  final Map<int, GlobalKey> _itemKeys = {};

  // Positions of items before drag
  final Map<int, Rect> _itemPositions = {};

  // Original positions of selected items
  final Map<T, int> _originalPositions = {};

  // Target positions after reordering
  final Map<T, int> _targetPositions = {};

  // Whether we're currently reordering
  bool _isReordering = false;

  // Whether we're currently dragging
  bool _isDragging = false;

  // Auto-scroll timer
  Timer? _autoScrollTimer;

  // Pagination state variables
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set<T>.from(widget.initialSelection ?? []);
    _isSelectionMode = _selectedItems.isNotEmpty;

    // Initialize animation controllers
    _dragAnimationController = AnimationController(
      vsync: this,
      duration: widget.dragAnimationDuration,
    );

    _reorderAnimationController = AnimationController(
      vsync: this,
      duration: widget.reorderAnimationDuration,
    );

    _reorderAnimation = CurvedAnimation(
      parent: _reorderAnimationController,
      curve: Curves.easeInOutCubic,
    );

    _scrollController = ScrollController();

    // Initialize item keys
    _initItemKeys();

    // Add listeners
    _dragAnimationController.addStatusListener(_onDragAnimationStatusChanged);
    _reorderAnimationController.addStatusListener(_onReorderAnimationStatusChanged);
    _scrollController.addListener(_onScroll);
  }

  void _initItemKeys() {
    _itemKeys.clear();
    for (int i = 0; i < widget.items.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(ReorderableMultiDragList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialSelection != oldWidget.initialSelection) {
      _selectedItems = Set<T>.from(widget.initialSelection ?? []);
      _isSelectionMode = _selectedItems.isNotEmpty;
    }
    
    // Update item keys if items changed
    if (oldWidget.items != widget.items || oldWidget.items.length != widget.items.length) {
      _initItemKeys();
    }
  }

  @override
  void dispose() {
    _dragAnimationController.removeStatusListener(_onDragAnimationStatusChanged);
    _reorderAnimationController.removeStatusListener(_onReorderAnimationStatusChanged);
    _dragAnimationController.dispose();
    _reorderAnimationController.dispose();
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _onDragAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _dragAnimationController.reset();
    }
  }

  void _onReorderAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isReordering = false;
        _reorderAnimationController.reset();
        
        // Apply the reordering to the actual list
        _applyReordering();
      });
    }
  }

  void _applyReordering() {
    if (_targetPositions.isEmpty) return;

    DragListUtils.applyReordering(
      items: widget.items,
      selectedItems: _selectedItems,
      originalPositions: _originalPositions,
      targetPositions: _targetPositions,
      onReorder: widget.onReorder,
    );
    
    // Clear the positions
    _originalPositions.clear();
    _targetPositions.clear();
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
      
      if (widget.onSelectionChanged != null) {
        widget.onSelectionChanged!(List<T>.from(_selectedItems));
      }
    });
  }

  /// Start dragging an item
  void _onDragStarted(int index, Offset position) {
    if (_isReordering) return;
    
    setState(() {
      _draggedItemIndex = index;
      _dragPosition = position;
      _isDragging = true;
      
      // Store original positions of all items
      _captureItemPositions();
      
      // Store original positions of selected items
      for (final item in _selectedItems) {
        int itemIndex = widget.items.indexOf(item);
        if (itemIndex >= 0) {
          _originalPositions[item] = itemIndex;
        }
      }
      
      // If the dragged item is not selected, select it
      final draggedItem = widget.items[index];
      if (!_selectedItems.contains(draggedItem)) {
        _selectedItems.add(draggedItem);
        _isSelectionMode = true;
        _originalPositions[draggedItem] = index;
        
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(List<T>.from(_selectedItems));
        }
      }
    });
    
    _dragAnimationController.forward();
    
    // Start auto-scroll timer
    _startAutoScroll();
  }

  /// Update drag position
  void _onDragUpdate(Offset position) {
    if (!_isDragging) return;
    
    setState(() {
      _dragPosition = position;
      _updateTargetPositions(position);
    });
  }

  /// End dragging an item
  void _onDragEnded() {
    if (!_isDragging) return;
    
    // Cancel auto-scroll
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    
    setState(() {
      _isDragging = false;
      _draggedItemIndex = null;
      _dragPosition = null;
      
      // Start reordering animation
      _isReordering = true;
      _reorderAnimationController.forward(from: 0.0);
    });
  }

  /// Capture the current positions of all items
  void _captureItemPositions() {
    _itemPositions.clear();
    
    for (int i = 0; i < widget.items.length; i++) {
      final key = _itemKeys[i];
      if (key?.currentContext != null) {
        final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        _itemPositions[i] = Rect.fromLTWH(
          position.dx,
          position.dy,
          box.size.width,
          box.size.height,
        );
      }
    }
  }

  /// Update target positions based on current drag position
  void _updateTargetPositions(Offset position) {
    if (_draggedItemIndex == null) return;
    
    // Find the item under the current drag position
    int? targetIndex;
    double minDistance = double.infinity;
    
    for (int i = 0; i < widget.items.length; i++) {
      if (_itemPositions.containsKey(i)) {
        final rect = _itemPositions[i]!;
        
        // Calculate the center of the item
        final center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
        
        // Calculate distance to the drag position
        final distance = (center - position).distance;
        
        if (distance < minDistance) {
          minDistance = distance;
          targetIndex = i;
        }
      }
    }
    
    if (targetIndex != null) {
      // Update target positions for all selected items
      for (final item in _selectedItems) {
        _targetPositions[item] = targetIndex;
      }
    }
  }

  /// Build a drop target highlight widget
  Widget _buildDropTargetHighlight(int index) {
    if (!_isDragging || _targetPositions.isEmpty) return const SizedBox();
    
    final targetIndex = _targetPositions.values.first;
    if (index != targetIndex) return const SizedBox();
    
    return Container(
      height: widget.theme.dropTargetHeight,
      color: widget.theme.dropTargetColor,
      margin: EdgeInsets.symmetric(
        horizontal: widget.theme.itemHorizontalMargin,
      ),
    );
  }

  /// Calculate the position of an item during reordering animation
  Offset _calculateItemPosition(int index, double animationValue) {
    final item = widget.items[index];
    
    // If this item is not selected or we're not reordering, return zero offset
    if (!_selectedItems.contains(item) || !_isReordering) {
      return Offset.zero;
    }
    
    // Get the original position
    final originalIndex = _originalPositions[item];
    if (originalIndex == null) return Offset.zero;
    
    // Get the target position
    final targetIndex = _targetPositions[item];
    if (targetIndex == null) return Offset.zero;
    
    // Calculate the offset
    final originalRect = _itemPositions[originalIndex];
    final targetRect = _itemPositions[targetIndex];
    
    if (originalRect == null || targetRect == null) return Offset.zero;
    
    final originalY = originalRect.top;
    final targetY = targetRect.top;
    
    final dy = (targetY - originalY) * animationValue;
    
    return Offset(0, dy);
  }
  
  /// Start auto-scrolling when dragging near edges
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isDragging || _dragPosition == null) {
        timer.cancel();
        return;
      }
      
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Size size = box.size;
      final Offset localPosition = box.globalToLocal(_dragPosition!);
      
      double scrollDelta = 0;
      
      // Auto-scroll when near the top
      if (localPosition.dy < widget.autoScrollThreshold) {
        scrollDelta = -widget.autoScrollSpeed * 
            (1 - localPosition.dy / widget.autoScrollThreshold);
      }
      // Auto-scroll when near the bottom
      else if (localPosition.dy > size.height - widget.autoScrollThreshold) {
        scrollDelta = widget.autoScrollSpeed * 
            (1 - (size.height - localPosition.dy) / widget.autoScrollThreshold);
      }
      
      if (scrollDelta != 0) {
        final double newOffset = (_scrollController.offset + scrollDelta)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        
        _scrollController.jumpTo(newOffset);
        
        // Recapture positions after scrolling
        _captureItemPositions();
        _updateTargetPositions(_dragPosition!);
      }
    });
  }
  
  /// Handle long press to enter selection mode
  void _onLongPress(T item, Offset position) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedItems.add(item);
        
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(List<T>.from(_selectedItems));
        }
      });
    } else if (!_selectedItems.contains(item)) {
      // If already in selection mode, toggle this item
      _toggleSelection(item);
    }
  }

  /// Build a stack of selected items for dragging
  Widget _buildDraggedStack(BuildContext context) {
    if (_draggedItemIndex == null || _dragPosition == null) return const SizedBox();
    
    final List<Widget> stackItems = [];
    final draggedItem = widget.items[_draggedItemIndex!];
    
    // Get all selected items in order (except the dragged one)
    final selectedItems = _selectedItems
        .where((item) => item != draggedItem)
        .toList();
    
    // Add all selected items to the stack
    for (int i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      final itemIndex = widget.items.indexOf(item);
      
      if (itemIndex < 0) continue;
      
      // Calculate the position in the stack (0 is bottom, length-1 is top)
      final int stackPosition = i;
      
      // Build the item widget
      final itemWidget = widget.itemBuilder(
        context,
        item,
        itemIndex,
        true,
        false,
      );
      
      // Calculate offset based on stack position
      final double xOffset = widget.theme.maxStackOffset * (stackPosition + 1);
      final double yOffset = widget.theme.maxStackOffset * (stackPosition + 1);
      
      // Calculate rotation based on stack position (alternating)
      final double rotation = (stackPosition % 2 == 0 ? 1 : -1) *
          widget.theme.maxStackRotation *
          ((stackPosition + 1) / selectedItems.length);
      
      // Create a widget for this item in the stack
      stackItems.add(
        Transform.translate(
          offset: Offset(xOffset, yOffset),
          child: Transform.rotate(
            angle: rotation * (3.14159 / 180), // Convert to radians
            child: Opacity(
              opacity: 0.9 - (0.1 * stackPosition / selectedItems.length),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.selectedItemColor,
                  borderRadius: BorderRadius.circular(widget.theme.itemBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: itemWidget,
              ),
            ),
          ),
        ),
      );
    }
    
    // Build the dragged item widget
    final draggedItemWidget = widget.itemBuilder(
      context,
      draggedItem,
      _draggedItemIndex!,
      true,
      true,
    );
    
    // Add the dragged item on top
    stackItems.add(
      Container(
        decoration: BoxDecoration(
          color: widget.theme.selectedItemColor,
          borderRadius: BorderRadius.circular(widget.theme.itemBorderRadius),
          border: Border.all(
            color: widget.theme.draggedItemBorderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: draggedItemWidget,
      ),
    );
    
    // Get the global position of the list and screen size
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size screenSize = MediaQuery.of(context).size;
    final Offset localPosition = box.globalToLocal(_dragPosition!);
    
    // Calculate the width and height of the stack
    // Use a default size if we can't determine it
    final double stackWidth = 300.0;
    final double stackHeight = widget.itemHeight + 20.0; // Add some padding
    
    // Calculate position ensuring the stack stays within screen bounds
    double left = localPosition.dx - 40; // Offset from cursor for better visibility
    double top = localPosition.dy - 20; // Position slightly above finger
    
    // Ensure the stack doesn't go off-screen
    if (left < 0) {
      left = 0;
    } else if (left + stackWidth > screenSize.width) {
      left = screenSize.width - stackWidth;
    }
    
    if (top < 0) {
      top = 0;
    } else if (top + stackHeight > screenSize.height) {
      top = screenSize.height - stackHeight;
    }
    
    // Create the final stack
    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: stackWidth,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: stackItems,
          ),
        ),
      ),
    );
  }
  
  /// Build the selection bar at the top of the list
  Widget _buildSelectionBar() {
    if (widget.selectionBarBuilder != null) {
      return widget.selectionBarBuilder!(
        context, 
        _selectedItems.length, 
        _onDonePressed,
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: widget.theme.selectionBarColor,
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
              onPressed: _onDonePressed,
              child: Text(widget.doneButtonText),
            ),
        ],
      ),
    );
  }
  
  /// Handle done button press
  void _onDonePressed() {
    // Cancel any ongoing animations or timers
    _dragAnimationController.stop();
    _reorderAnimationController.stop();
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    
    // Reset drag state
    final wasInSelectionMode = _isSelectionMode;
    final selectedItemsCopy = List<T>.from(_selectedItems);
    
    setState(() {
      _isDragging = false;
      _isReordering = false;
      _draggedItemIndex = null;
      _dragPosition = null;
      _originalPositions.clear();
      _targetPositions.clear();
      _isSelectionMode = false;
      _selectedItems.clear();
    });
    
    // Call the callback outside of setState to avoid potential issues
    if (wasInSelectionMode && widget.onDone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDone!(selectedItemsCopy);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !_isLoading) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (widget.onPageRequest == null) return;
    setState(() {
      _isLoading = true;
    });
    await widget.onPageRequest!(_currentPage + 1, widget.pageSize ?? 20);
    setState(() {
      _isLoading = false;
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Selection controls
            if (_isSelectionMode) _buildSelectionBar(),
            
            // Header widget if provided
            if (widget.headerWidget != null) widget.headerWidget!,
            
            // List of items
            Expanded(
              child: NotificationListener<ScrollNotification>(
                // Prevent scroll during drag operations
                onNotification: (notification) {
                  // Return true to cancel the notification bubbling if we're dragging
                  return _isDragging;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = _selectedItems.contains(item);
                    final isDragging = _draggedItemIndex == index && _isDragging;
                    
                    // Create a key for this item
                    final key = _itemKeys[index] ?? GlobalKey();
                    _itemKeys[index] = key;
                    
                    return AnimatedBuilder(
                      animation: _reorderAnimation,
                      builder: (context, child) {
                        // Calculate the position offset during reordering
                        final offset = _calculateItemPosition(index, _reorderAnimation.value);
                        
                        return Transform.translate(
                          offset: offset,
                          child: Column(
                            children: [
                              _buildDropTargetHighlight(index),
                              child ?? const SizedBox(),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        key: key,
                        margin: EdgeInsets.symmetric(
                          horizontal: widget.theme.itemHorizontalMargin,
                          vertical: widget.theme.itemVerticalMargin,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? widget.theme.selectedItemColor : widget.theme.itemColor,
                          borderRadius: BorderRadius.circular(widget.theme.itemBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Drag handle - only show in selection mode
                            if (_isSelectionMode) 
                              MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragStart: (details) {
                                    _onDragStarted(index, details.globalPosition);
                                  },
                                  onVerticalDragUpdate: (details) {
                                    _onDragUpdate(details.globalPosition);
                                  },
                                  onVerticalDragEnd: (details) {
                                    _onDragEnded();
                                  },
                                  onHorizontalDragStart: (details) {
                                    _onDragStarted(index, details.globalPosition);
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    _onDragUpdate(details.globalPosition);
                                  },
                                  onHorizontalDragEnd: (details) {
                                    _onDragEnded();
                                  },
                                  child: Container(
                                    width: 44,
                                    height: widget.itemHeight,
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: widget.dragHandleBuilder?.call(context, isSelected) ??
                                      Icon(
                                        Icons.drag_handle,
                                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                        size: 24,
                                      ),
                                  ),
                                ),
                              ),
                            
                            // Checkbox for selection
                            if (_isSelectionMode) ...[
                              Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(item),
                              ),
                              const SizedBox(width: 4),
                            ],
                            
                            // Item content
                            Expanded(
                              child: GestureDetector(
                                onLongPress: () {
                                  // Get the global position for the long press
                                  final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
                                  final Offset position = box.localToGlobal(Offset.zero);
                                  _onLongPress(item, position + const Offset(100, 30)); // Approximate center
                                },
                                onTap: _isSelectionMode ? () => _toggleSelection(item) : null,
                                child: Opacity(
                                  opacity: isDragging ? 0.3 : 1.0,
                                  child: widget.itemBuilder(
                                    context,
                                    item,
                                    index,
                                    isSelected,
                                    isDragging,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Footer widget if provided
            if (widget.footerWidget != null) widget.footerWidget!,

            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
        
        // Dragged stack
        if (_isDragging) _buildDraggedStack(context),
      ],
    );
  }
}
