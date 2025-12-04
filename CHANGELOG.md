# [0.2.0]

### Added
* **Single/Multi Mode Support**: Added `ReorderableMode` enum to switch between single-item reordering (using Flutter's `ReorderableListView`) and multi-item selection mode (default)
* **Global Configuration**: Added `ReorderableMultiDragConfig` class for setting global default builders (e.g., empty state builder) that apply to all widgets automatically
* **Empty State Builder**: Added `emptyStateBuilder` parameter and global config support for customizing empty state display
* **Debug Printing Utility**: Added `DebugPrintUtil` class with categorized debug messages prefixed with `[multi_reorderable]` for easy filtering and debugging
* **Enhanced onReorder Callback**: Updated callback signature to provide `newIndex`, `movedItems`, and `reorderedItems` for easier API integration
* **Compact Selection Controls**: Redesigned selection mode UI with combined checkbox and drag handle in a vertical stack for ultra-compact layout

### Changed
* **Breaking Change**: `onReorder` callback signature changed from `void Function(List<T> reorderedItems)` to `void Function(int newIndex, List<T> movedItems, List<T> reorderedItems)`
* **Selection Mode Layout**: Reduced horizontal margins to 0 in selection mode for maximum space efficiency
* **Drag Handle**: Reduced drag handle width from 44px to 32px with combined checkbox/drag handle widget
* **Target Position Calculation**: Improved target position adjustment logic when items are removed before the target position

### Fixed
* Fixed target_id calculation for API calls - now correctly identifies the item after moved items
* Fixed selection count display in debug logs
* Improved reordering logic for moving items from end to beginning positions

# [0.1.3]

### Added
* `currentPage` parameter to control pagination from outside the widget
* `totalPages` parameter to limit pagination requests
* Added better empty list handling with dedicated "No items available" message
* Improved "No more items" indicator visibility

### Changed
* Refactored pagination to prevent duplicate page loading
* Modified page calculation to use the external `currentPage` value
* Better initial load handling to prevent unnecessary requests
* Enhanced error handling during pagination with proper UI feedback

### Fixed
* Fixed issue where the widget would load multiple pages on initialization
* Fixed "No more items" message not showing in certain cases
* Fixed pagination when fewer items than page size are returned

## [0.1.2]

### Added
* Pull-to-refresh functionality with `RefreshIndicator`
* Support for customizing refresh indicator appearance
* Example implementation for pull-to-refresh in the example app

### Changed
* Improved pagination implementation to be resilient to widget rebuilds
* Page numbers are now calculated dynamically based on items count
* Better error handling and debug information for pagination
* Updated documentation and examples

### Fixed
* Fixed pagination issues when widgets are rebuilt
* Fixed issue with page number always being 1 in pagination requests
* Improved widget state retention during rebuilds

## 0.1.1

* Updated ExampleScreen, AdvancedExampleScreen, and PaginationExampleScreen constructors to use the shorthand `super.key` syntax.
* Removed unused import statements from drag_styles_manager.dart to clean up the codebase.

## 0.1.0

* Fixed index out of range error when dragging multiple items to the bottom of the list
* Enhanced stacked style appearance with solid white background for dragged items
* Improved visual hierarchy in the stacked style with proper opacity and transparency
* Fixed various edge cases in the reordering functionality
* Improved bounds checking in DragListUtils for safer reordering operations
* Optimized drag handling for a smoother user experience

## 0.0.1

* Initial release

## 0.0.2

* Edits & fixes

## 0.0.3

* Added drop target highlight feature to visually indicate where items can be dropped during reordering.
* Update version to 0.0.3, and enhance theme properties for improved item reordering experience.

## 0.0.4

* Revert withValues back to withOpacity
* Update version to 0.0.4

## 0.0.5

* Added pagination support for loading more items as user scrolls
* Added ability to refresh the widget programmatically from outside using a GlobalKey
* Exposed ReorderableMultiDragListState class to enable external refresh access
* Added new example demonstrating pagination and refresh functionality
* Improved error handling for data loading

## 0.0.6

* Enhanced drag handling to improve user experience:
  * Improved drag stack positioning to appear directly above finger position
  * Created a clean staggered stack layout with consistent offset patterns
  * Eliminated rotation for better visual clarity
  * Enhanced visual hierarchy with proper opacity, borders and shadows
  * Added visual separation between active item and stacked items
  * Improved prominence of the dragged item with stronger borders and shadows
  * Fixed issues with drag stack placement during movement
  * Optimized continuous tracking of finger/cursor position
