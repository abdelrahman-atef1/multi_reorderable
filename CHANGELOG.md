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