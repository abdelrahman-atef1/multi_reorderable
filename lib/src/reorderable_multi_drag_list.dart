import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'dart:math' as math;

import 'theme/reorderable_multi_drag_theme.dart';
import 'utils/drag_list_utils.dart';

// Export ReorderableMultiDragList and ReorderableMultiDragListState

/// A custom reorderable widget that supports multi-selection and animated reordering.
///
/// Features:
/// 1. Multi-select widgets and move them together by dragging
/// 2. Animate all widgets' positions from origin to dragged point
/// 3. Selection is maintained after moving until "Done" is clicked
/// 4. Natural animations for all interactions
/// 5. Can move one item at a time
/// 6. Can use any widget as a child
/// 7. Supports pagination for loading more items
/// 8. Can be refreshed programmatically from outside
/// 9. Supports pull-to-refresh with RefreshIndicator
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

  /// Optional builder for the loading indicator
  /// 
  /// This builder is called when the list is loading more items during pagination.
  /// It allows you to customize the appearance of the loading indicator that appears
  /// at the bottom of the list when loading more items.
  /// 
  /// If not provided, a default CircularProgressIndicator.adaptive will be used.
  /// 
  /// Example:
  /// ```dart
  /// loadingWidgetBuilder: (context) {
  ///   return Column(
  ///     mainAxisSize: MainAxisSize.min,
  ///     children: [
  ///       const CircularProgressIndicator.adaptive(),
  ///       const SizedBox(height: 8),
  ///       Text('Loading more items...'),
  ///     ],
  ///   );
  /// }
  /// ```
  final Widget Function(BuildContext context)? loadingWidgetBuilder;

  /// Optional builder for the "no more items" state
  /// 
  /// This builder is called when the list has reached the end of pagination
  /// and there are no more items to load.
  /// It allows you to customize the appearance of the message that appears
  /// at the bottom of the list when all items have been loaded.
  /// 
  /// If not provided, a default "No more items to load" message will be shown.
  /// 
  /// Example:
  /// ```dart
  /// noMoreItemsBuilder: (context) {
  ///   return Container(
  ///     padding: const EdgeInsets.all(16),
  ///     child: const Text(
  ///       "You've reached the end of the list",
  ///       style: TextStyle(
  ///         fontStyle: FontStyle.italic,
  ///         color: Colors.grey,
  ///       ),
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(BuildContext context)? noMoreItemsBuilder;

  /// Pagination parameters
  final int? pageSize;
  
  /// Callback for requesting more items when pagination occurs
  /// 
  /// This callback is called when the user scrolls near the end of the list
  /// and more items need to be loaded. The callback provides the next page number
  /// and the page size.
  /// 
  /// The page number is calculated dynamically based on the current number of items
  /// in the list and the page size, using the formula:
  /// `nextPage = (currentItemsCount / pageSize).floor() + 1`
  /// 
  /// This ensures that even if the widget is rebuilt, the correct page number
  /// will be requested based on the actual data.
  /// 
  /// IMPORTANT: When implementing this callback, make sure to:
  /// 1. Use the provided page number in your API request (starts at 1, not 0)
  /// 2. Append new items to your existing list, not replace them
  /// 3. Update your state after receiving the response
  /// 
  /// Example implementation:
  /// ```dart
  /// onPageRequest: (page, pageSize) async {
  ///   // IMPORTANT: Use the exact page number provided by the callback
  ///   print('Loading page $page');
  ///   
  ///   // Update your request object with the provided page number
  ///   final request = YourRequestObject()..page = page;
  ///   
  ///   // Call your API with the updated request
  ///   final response = await yourApi.fetchItems(request);
  ///   
  ///   // Add new items to your existing list (not replace)
  ///   setState(() {
  ///     yourItems.addAll(response.items);
  ///   });
  /// }
  /// ```
  /// 
  /// Common issues:
  /// - If you're always receiving page 1 data, make sure your API request
  ///   is using the page number provided by this callback, not a hardcoded value.
  /// - Ensure your API page numbers start at 1 (not 0) to match this widget's expectations.
  /// - Make sure your items list is properly preserved between widget rebuilds.
  final Future<void> Function(int page, int pageSize)? onPageRequest;
  
  /// Optional global key to access the state from outside
  final GlobalKey<ReorderableMultiDragListState<T>>? listKey;

  /// Whether to enable the pull-to-refresh functionality
  /// 
  /// When set to true, a RefreshIndicator will be added to the list,
  /// allowing users to pull down to refresh the list.
  /// 
  /// The refresh action will reset pagination and reload the first page.
  /// To handle the refresh action, provide an [onRefresh] callback.
  final bool enablePullToRefresh;
  
  /// Callback for when the user pulls to refresh
  /// 
  /// This callback is called when the user pulls down to refresh the list.
  /// If not provided, [onPageRequest] will be used with page=1.
  /// 
  /// Example:
  /// ```dart
  /// onRefresh: () async {
  ///   // Clear your existing items
  ///   setState(() {
  ///     yourItems.clear();
  ///   });
  ///   
  ///   // Fetch the first page
  ///   final response = await yourApi.fetchItems(page: 1);
  ///   
  ///   // Update your state with the new items
  ///   setState(() {
  ///     yourItems.addAll(response.items);
  ///   });
  /// }
  /// ```
  final Future<void> Function()? onRefresh;
  
  /// Color for the refresh indicator
  /// 
  /// If not provided, the theme's primary color will be used.
  final Color? refreshIndicatorColor;
  
  /// Background color for the refresh indicator
  /// 
  /// If not provided, the theme's background color will be used.
  final Color? refreshIndicatorBackgroundColor;
  
  /// Displacement for the refresh indicator
  /// 
  /// The amount of pixels the refresh indicator should be displaced from the top.
  /// Default is 40.0 pixels.
  final double refreshIndicatorDisplacement;
  
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
    this.loadingWidgetBuilder,
    this.noMoreItemsBuilder,
    this.listKey,
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.refreshIndicatorDisplacement = 40.0,
  }) : theme = theme ?? ReorderableMultiDragTheme();

  @override
  State<ReorderableMultiDragList<T>> createState() => ReorderableMultiDragListState<T>();
}

/// State for the ReorderableMultiDragList widget
/// Exposed to allow external refreshing using a GlobalKey
class ReorderableMultiDragListState<T> extends State<ReorderableMultiDragList<T>>
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
  // Remove current page state - we'll calculate it dynamically
  // int _currentPage = 0;
  bool _hasMoreItems = true;
  // Track the previous items length to detect actual new items
  int _previousItemsLength = 0;
  // Track if pagination is initialized
  bool _isPaginationInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set<T>.from(widget.initialSelection ?? []);
    _isSelectionMode = _selectedItems.isNotEmpty;
    _previousItemsLength = widget.items.length;
    
    // No longer need to initialize current page
    // _currentPage = 0;
    _isPaginationInitialized = true;

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
    
    // Load initial data if empty
    if (widget.items.isEmpty) {
      _loadMoreData();
    }
    
    // Add global listener for pointer movements
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointerEvent);
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
      
      // Check for newly added items (for pagination detection)
      if (widget.items.length > _previousItemsLength) {
        // Update hasMoreItems based on actual new items being added
        _hasMoreItems = true;
      } else if (widget.items.length == _previousItemsLength && _isLoading) {
        // If no new items were added during loading, we've reached the end
        _hasMoreItems = false;
      }
      
      // Update previous length tracker
      _previousItemsLength = widget.items.length;
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
    
    // Remove global pointer listener
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handleGlobalPointerEvent);
    
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
    
    // Cancel any previous drag operations
    _autoScrollTimer?.cancel();
    
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
    
    // Start auto-scroll timer - this is a NEW implementation
    _startCustomAutoScroll();
  }
  
  /// Custom auto-scroll that prevents getting stuck
  void _startCustomAutoScroll() {
    _autoScrollTimer?.cancel();
    
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isDragging || _dragPosition == null) {
        timer.cancel();
        return;
      }
      
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        return;
      }
      
      final Size size = box.size;
      final Offset localPosition = box.globalToLocal(_dragPosition!);
      
      double scrollDelta = 0;
      
      // Calculate how much to scroll based on proximity to edges
      if (localPosition.dy < widget.autoScrollThreshold) {
        // Scroll up when near top edge
        scrollDelta = -widget.autoScrollSpeed * 
            (1 - localPosition.dy / widget.autoScrollThreshold);
      } else if (localPosition.dy > size.height - widget.autoScrollThreshold) {
        // Scroll down when near bottom edge
        scrollDelta = widget.autoScrollSpeed * 
            (1 - (size.height - localPosition.dy) / widget.autoScrollThreshold);
      }
      
      // If we need to scroll
      if (scrollDelta != 0) {
        // Get current scroll position
        final double currentScrollPosition = _scrollController.position.pixels;
        
        // Calculate new position with bounds checking
        final double targetScrollPosition = (currentScrollPosition + scrollDelta)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
            
        // Only scroll if we're not already at the min/max
        final bool canScroll = (scrollDelta < 0 && currentScrollPosition > 0) || 
                              (scrollDelta > 0 && currentScrollPosition < _scrollController.position.maxScrollExtent);
        
        // If we can scroll, do it
        if (canScroll) {
          _scrollController.jumpTo(targetScrollPosition);
          
          // After scrolling, update positions
          _captureItemPositions();
          _updateTargetPositions(_dragPosition!);
        }
      }
    });
  }
  
  /// Update drag position with extra safety checks
  void _onDragUpdate(Offset position) {
    if (!_isDragging) return;
    
    // Validate the position
    if (position.dx.isNaN || position.dy.isNaN || 
        position.dx.isInfinite || position.dy.isInfinite) {
      return;
    }
    
    // Make sure we update the position even during continuous scrolling
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
    
    // Recapture positions if needed - to ensure we have fresh data
    if (_itemPositions.isEmpty) {
      _captureItemPositions();
    }
    
    // If still empty (which shouldn't happen normally), return
    if (_itemPositions.isEmpty) return;
    
    // Find the item under the current drag position
    int? targetIndex;
    double minDistance = double.infinity;
    
    // Get the render box
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    // Convert global position to local
    final Offset localPosition = box.globalToLocal(position);
    
    // Check if we're above the visible list area
    if (localPosition.dy < 0) {
      // Target the first visible item if we're dragging above the list
      for (int i = 0; i < widget.items.length; i++) {
        if (_itemPositions.containsKey(i)) {
          targetIndex = i;
          break;
        }
      }
    } 
    // Check if we're below the visible list area
    else if (localPosition.dy > box.size.height) {
      // Target the last visible item if we're dragging below the list
      for (int i = widget.items.length - 1; i >= 0; i--) {
        if (_itemPositions.containsKey(i)) {
          targetIndex = i;
          break;
        }
      }
    }
    // Normal case - find closest item to the drag position
    else {
      for (int i = 0; i < widget.items.length; i++) {
        if (_itemPositions.containsKey(i)) {
          final rect = _itemPositions[i]!;
          
          // Check if we're directly over this item
          if (rect.top <= position.dy && position.dy <= rect.bottom) {
            targetIndex = i;
            break;
          }
          
          // Otherwise calculate distance to center of item
          final center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
          final distance = (center - position).distance;
          
          if (distance < minDistance) {
            minDistance = distance;
            targetIndex = i;
          }
        }
      }
    }
    
    // If we found a target, update all selected items
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
    
    final draggedItem = widget.items[_draggedItemIndex!];
    final dragPosition = _dragPosition!;
    
    // Build the dragged items widget based on the theme style
    final Widget content = widget.theme.buildStyle(
      context: context,
      draggedItem: draggedItem,
      selectedItems: List<T>.from(_selectedItems),
      draggedItemIndex: _draggedItemIndex!,
      itemBuilder: widget.itemBuilder,
    );
    
    // Get global position and screen info
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();
    
    final Size screenSize = MediaQuery.of(context).size;
    
    // Calculate the width and height of the stack
    final double stackWidth = 300.0;
    final double stackHeight = 150.0; // Ensure enough height for all drag styles
    
    // Position the stack directly under the finger/cursor
    // with offset to ensure visibility
    final double fingerOffset = 150.0; // Position well above finger
    final double left = dragPosition.dx - (stackWidth / 2); // Center horizontally 
    final double top = dragPosition.dy - fingerOffset; // Position above finger
    
    // Apply bounds to keep on screen
    final double boundedLeft = math.max(0, math.min(left, screenSize.width - stackWidth));
    final double boundedTop = math.max(0, math.min(top, screenSize.height - stackHeight));
    
    // Create the final positioned element
    return Positioned(
      left: boundedLeft,
      top: boundedTop,
      width: stackWidth,
      height: stackHeight,
      child: Material(
        color: Colors.transparent,
        child: content,
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
    // Ensure we have the scroll controller and it has clients
    if (!_scrollController.hasClients) return;
    
    // Don't trigger pagination if already loading or no more items
    if (!_hasMoreItems || _isLoading) return;
    
    // Get scroll metrics
    final scrollPosition = _scrollController.position;
    final maxScroll = scrollPosition.maxScrollExtent;
    final currentScroll = scrollPosition.pixels;
    final viewportDimension = scrollPosition.viewportDimension;
    
    // Calculate the threshold (80% of the way down)
    final threshold = maxScroll - (viewportDimension * 0.2);
    
    // Load more when scrolling past the threshold
    if (currentScroll >= threshold) {
      _loadMoreData();
    }
  }

  /// Method to load more data for pagination
  Future<void> _loadMoreData() async {
    // Check all pre-conditions to load more data
    if (widget.onPageRequest == null || 
        _isLoading || 
        !_hasMoreItems) {
      return;
    }
    
    // Set loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    // Store the initial items length to detect if new items were added
    final initialItemsLength = widget.items.length;
    
    try {
      // Calculate the next page based on item count and page size
      // (pages start at 1, so we add 1 to the calculated value)
      final pageSize = widget.pageSize ?? 20;
      final nextPage = (initialItemsLength / pageSize).floor() + 1;
      
      // Debug printing to help troubleshoot
      debugPrint('Calculated and requesting page: $nextPage (items: $initialItemsLength, pageSize: $pageSize)');
      
      // Request new page of data
      await widget.onPageRequest!(nextPage, pageSize);
      
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          // Check if new items were actually added
          final newItemsAdded = widget.items.length > initialItemsLength;
          final itemsAdded = widget.items.length - initialItemsLength;
          
          // Debug printing to help troubleshoot
          debugPrint('Items before: $initialItemsLength, after: ${widget.items.length}, added: $itemsAdded');
          
          // If no new items were added, or we received fewer items than the page size,
          // we've likely reached the end
          if (!newItemsAdded || 
              (widget.items.length - initialItemsLength) < pageSize) {
            _hasMoreItems = false;
            debugPrint('No more items to load. hasMoreItems set to false');
          }
          
          // Update previous length tracker
          _previousItemsLength = widget.items.length;
        });
      }
    } catch (e) {
      // Handle errors if needed
      debugPrint('Error loading more data: $e');
    } finally {
      // Reset loading state if widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Method to refresh the list programmatically
  /// Can be called from outside using a GlobalKey
  void refreshItems({bool resetPagination = false}) {
    // Cancel any active operations first
    _autoScrollTimer?.cancel();
    _dragAnimationController.stop();
    _reorderAnimationController.stop();
    
    if (resetPagination) {
      setState(() {
        // No need to reset _currentPage since we're calculating it dynamically
        _hasMoreItems = true;
        _isLoading = false;
        _previousItemsLength = widget.items.length;
        debugPrint('Pagination reset: _hasMoreItems = true');
      });
    }
    
    setState(() {
      _isDragging = false;
      _isReordering = false;
      _draggedItemIndex = null;
      _dragPosition = null;
      
      // Re-initialize keys for any new items
      _initItemKeys();
    });
    
    // Jump to top if requested
    if (resetPagination && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // Handle global pointer events to keep track of drag position
  void _handleGlobalPointerEvent(PointerEvent event) {
    // Only handle move events when we're dragging
    if (_isDragging && event is PointerMoveEvent) {
      // Update the drag position based on the pointer position
      _onDragUpdate(event.position);
    }
    
    // Handle pointer up events to end the drag
    if (_isDragging && event is PointerUpEvent) {
      _onDragEnded();
    }
  }

  /// Handle refresh for pull-to-refresh functionality
  Future<void> _handleRefresh() async {
    // Set initial loading state
    setState(() {
      _isLoading = true;
      _hasMoreItems = true;
      // No need to reset _currentPage since we're calculating it dynamically
    });
    
    try {
      if (widget.onRefresh != null) {
        // Use the provided refresh callback
        await widget.onRefresh!();
      } else if (widget.onPageRequest != null) {
        // If no specific refresh callback is provided, use the page request callback with page 1
        await widget.onPageRequest!(1, widget.pageSize ?? 20);
      }
    } catch (e) {
      debugPrint('Error during refresh: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _previousItemsLength = widget.items.length;
        });
      }
    }
    
    return;
  }

  @override
  Widget build(BuildContext context) {
    // Create the main list content
    Widget listView = ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (_isLoading || !_hasMoreItems && widget.items.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == widget.items.length) {
          if (_isLoading) {
            return Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: widget.loadingWidgetBuilder?.call(context) ?? 
                const CircularProgressIndicator.adaptive(),
            );
          } else if (!_hasMoreItems && widget.items.isNotEmpty) {
            // Show "No more items" message when we've reached the end
            return widget.noMoreItemsBuilder?.call(context) ??
              Container(
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  "No more items to load",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
          }
        }
        
        // Normal item display
        if (index < widget.items.length) {
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
        }
        
        return const SizedBox(); // Fallback
      },
    );

    // Wrap with NotificationListener for drag handling
    Widget listContent = NotificationListener<ScrollNotification>(
      // Prevent scroll during drag operations
      onNotification: (notification) {
        // If we get a scroll end notification during dragging, 
        // ensure positions are updated
        if (notification is ScrollEndNotification && _isDragging && _dragPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Re-capture positions and update targets
            _captureItemPositions();
            _updateTargetPositions(_dragPosition!);
          });
        }
        
        // Return true to cancel the notification bubbling if we're dragging
        return _isDragging;
      },
      child: listView,
    );
    
    // Wrap with RefreshIndicator if enabled
    if (widget.enablePullToRefresh) {
      listContent = RefreshIndicator(
        onRefresh: _handleRefresh,
        color: widget.refreshIndicatorColor,
        backgroundColor: widget.refreshIndicatorBackgroundColor,
        displacement: widget.refreshIndicatorDisplacement,
        child: listContent,
      );
    }

    return GestureDetector(
      // Global listener to catch dragging events that might be missed during scrolling
      onPanEnd: (_) {
        if (_isDragging) {
          _onDragEnded();
        }
      },
      onPanCancel: () {
        if (_isDragging) {
          _onDragEnded();
        }
      },
      child: Stack(
        children: [
          Column(
            children: [
              // Selection controls
              if (_isSelectionMode) _buildSelectionBar(),
              
              // Header widget if provided
              if (widget.headerWidget != null) widget.headerWidget!,
              
              // List of items
              Expanded(
                child: listContent,
              ),
              
              // Footer widget if provided
              if (widget.footerWidget != null) widget.footerWidget!,
            ],
          ),
          
          // Dragged stack
          if (_isDragging) _buildDraggedStack(context),
        ],
      ),
    );
  }
}
