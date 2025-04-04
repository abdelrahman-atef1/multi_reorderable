/// A model class for items in the ReorderableMultiDragList.
///
/// This class can be used to create a standardized model for items
/// in the ReorderableMultiDragList, though any type can be used.
class DragListItemModel<T> {
  /// Unique identifier for the item
  final String id;

  /// The data associated with this item
  final T data;

  /// Whether the item is selectable
  final bool isSelectable;

  /// Whether the item is draggable
  final bool isDraggable;

  /// Additional metadata for the item
  final Map<String, dynamic>? metadata;

  /// Creates a DragListItemModel.
  const DragListItemModel({
    required this.id,
    required this.data,
    this.isSelectable = true,
    this.isDraggable = true,
    this.metadata,
  });

  /// Creates a copy of this model with the given fields replaced with new values.
  DragListItemModel<T> copyWith({
    String? id,
    T? data,
    bool? isSelectable,
    bool? isDraggable,
    Map<String, dynamic>? metadata,
  }) {
    return DragListItemModel<T>(
      id: id ?? this.id,
      data: data ?? this.data,
      isSelectable: isSelectable ?? this.isSelectable,
      isDraggable: isDraggable ?? this.isDraggable,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DragListItemModel<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
