import 'package:flutter/material.dart';

/// Theme class for customizing the appearance of the ReorderableMultiSelectList.
///
/// This class allows for comprehensive styling of the ReorderableMultiSelectList
/// widget, including colors, text styles, animations, and layout properties.
class ReorderableMultiSelectTheme {
  /// The primary color used for selection indicators and buttons
  final Color primaryColor;

  /// The background color of the list items
  final Color itemBackgroundColor;

  /// The background color of selected list items
  final Color selectedItemBackgroundColor;

  /// The color of the dividers between items
  final Color dividerColor;

  /// The text style for the item content
  final TextStyle itemTextStyle;

  /// The text style for the selection count text
  final TextStyle selectionCountTextStyle;

  /// The text style for the done button
  final TextStyle doneButtonTextStyle;

  /// The elevation of the cards when not being dragged
  final double cardElevation;

  /// The elevation of the cards when being dragged
  final double draggedCardElevation;

  /// Border radius for the list items
  final BorderRadius itemBorderRadius;

  /// Padding for the list items
  final EdgeInsets itemPadding;

  /// Padding for the list container
  final EdgeInsets listPadding;

  /// The decoration for the list container
  final BoxDecoration? listDecoration;

  /// The decoration for the header container
  final BoxDecoration? headerDecoration;

  /// The decoration for the footer container
  final BoxDecoration? footerDecoration;

  /// The color of the checkbox when selected
  final Color checkboxActiveColor;

  /// The color of the checkbox border when not selected
  final Color checkboxBorderColor;

  /// The color of the drag handle icon
  final Color dragHandleColor;

  /// The size of the drag handle icon
  final double dragHandleSize;

  /// The icon used for the drag handle
  final IconData dragHandleIcon;

  /// The scale factor for items when being dragged
  final double dragScaleFactor;

  /// The opacity of items in the stack when dragging
  final double stackItemOpacity;

  /// Creates a [ReorderableMultiSelectTheme] with the specified properties.
  const ReorderableMultiSelectTheme({
    this.primaryColor = Colors.blue,
    this.itemBackgroundColor = Colors.white,
    this.selectedItemBackgroundColor = Colors.blue,
    this.dividerColor = Colors.grey,
    this.itemTextStyle = const TextStyle(fontSize: 16),
    this.selectionCountTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.doneButtonTextStyle = const TextStyle(fontSize: 16, color: Colors.white),
    this.cardElevation = 1.0,
    this.draggedCardElevation = 6.0,
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.itemPadding = const EdgeInsets.all(8.0),
    this.listPadding = const EdgeInsets.all(8.0),
    this.listDecoration,
    this.headerDecoration,
    this.footerDecoration,
    this.checkboxActiveColor = Colors.blue,
    this.checkboxBorderColor = Colors.grey,
    this.dragHandleColor = Colors.grey,
    this.dragHandleSize = 24.0,
    this.dragHandleIcon = Icons.drag_handle,
    this.dragScaleFactor = 0.05,
    this.stackItemOpacity = 0.8,
  });

  /// Creates a copy of this theme with the given fields replaced with new values.
  ReorderableMultiSelectTheme copyWith({
    Color? primaryColor,
    Color? itemBackgroundColor,
    Color? selectedItemBackgroundColor,
    Color? dividerColor,
    TextStyle? itemTextStyle,
    TextStyle? selectionCountTextStyle,
    TextStyle? doneButtonTextStyle,
    double? cardElevation,
    double? draggedCardElevation,
    BorderRadius? itemBorderRadius,
    EdgeInsets? itemPadding,
    EdgeInsets? listPadding,
    BoxDecoration? listDecoration,
    BoxDecoration? headerDecoration,
    BoxDecoration? footerDecoration,
    Color? checkboxActiveColor,
    Color? checkboxBorderColor,
    Color? dragHandleColor,
    double? dragHandleSize,
    IconData? dragHandleIcon,
    double? dragScaleFactor,
    double? stackItemOpacity,
  }) {
    return ReorderableMultiSelectTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
      selectedItemBackgroundColor: selectedItemBackgroundColor ?? this.selectedItemBackgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      selectionCountTextStyle: selectionCountTextStyle ?? this.selectionCountTextStyle,
      doneButtonTextStyle: doneButtonTextStyle ?? this.doneButtonTextStyle,
      cardElevation: cardElevation ?? this.cardElevation,
      draggedCardElevation: draggedCardElevation ?? this.draggedCardElevation,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      itemPadding: itemPadding ?? this.itemPadding,
      listPadding: listPadding ?? this.listPadding,
      listDecoration: listDecoration ?? this.listDecoration,
      headerDecoration: headerDecoration ?? this.headerDecoration,
      footerDecoration: footerDecoration ?? this.footerDecoration,
      checkboxActiveColor: checkboxActiveColor ?? this.checkboxActiveColor,
      checkboxBorderColor: checkboxBorderColor ?? this.checkboxBorderColor,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      dragHandleSize: dragHandleSize ?? this.dragHandleSize,
      dragHandleIcon: dragHandleIcon ?? this.dragHandleIcon,
      dragScaleFactor: dragScaleFactor ?? this.dragScaleFactor,
      stackItemOpacity: stackItemOpacity ?? this.stackItemOpacity,
    );
  }

  /// Creates a theme from the given [ThemeData].
  ///
  /// This allows the ReorderableMultiSelectList to inherit colors and styles
  /// from the app's theme.
  factory ReorderableMultiSelectTheme.fromTheme(ThemeData theme) {
    return ReorderableMultiSelectTheme(
      primaryColor: theme.colorScheme.primary,
      itemBackgroundColor: theme.cardColor,
      selectedItemBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      dividerColor: theme.dividerColor,
      itemTextStyle: theme.textTheme.bodyMedium!,
      selectionCountTextStyle: theme.textTheme.titleMedium!,
      doneButtonTextStyle: theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onPrimary,
      ),
      checkboxActiveColor: theme.colorScheme.primary,
      checkboxBorderColor: theme.unselectedWidgetColor,
      dragHandleColor: theme.unselectedWidgetColor,
    );
  }

  /// Lerp between two [ReorderableMultiSelectTheme]s.
  ///
  /// This is useful for animations.
  static ReorderableMultiSelectTheme lerp(
    ReorderableMultiSelectTheme a, 
    ReorderableMultiSelectTheme b, 
    double t
  ) {
    return ReorderableMultiSelectTheme(
      primaryColor: Color.lerp(a.primaryColor, b.primaryColor, t)!,
      itemBackgroundColor: Color.lerp(a.itemBackgroundColor, b.itemBackgroundColor, t)!,
      selectedItemBackgroundColor: Color.lerp(a.selectedItemBackgroundColor, b.selectedItemBackgroundColor, t)!,
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t)!,
      itemTextStyle: TextStyle.lerp(a.itemTextStyle, b.itemTextStyle, t)!,
      selectionCountTextStyle: TextStyle.lerp(a.selectionCountTextStyle, b.selectionCountTextStyle, t)!,
      doneButtonTextStyle: TextStyle.lerp(a.doneButtonTextStyle, b.doneButtonTextStyle, t)!,
      cardElevation: lerpDouble(a.cardElevation, b.cardElevation, t),
      draggedCardElevation: lerpDouble(a.draggedCardElevation, b.draggedCardElevation, t),
      itemBorderRadius: BorderRadius.lerp(a.itemBorderRadius, b.itemBorderRadius, t)!,
      itemPadding: EdgeInsets.lerp(a.itemPadding, b.itemPadding, t)!,
      listPadding: EdgeInsets.lerp(a.listPadding, b.listPadding, t)!,
      checkboxActiveColor: Color.lerp(a.checkboxActiveColor, b.checkboxActiveColor, t)!,
      checkboxBorderColor: Color.lerp(a.checkboxBorderColor, b.checkboxBorderColor, t)!,
      dragHandleColor: Color.lerp(a.dragHandleColor, b.dragHandleColor, t)!,
      dragHandleSize: lerpDouble(a.dragHandleSize, b.dragHandleSize, t),
      dragScaleFactor: lerpDouble(a.dragScaleFactor, b.dragScaleFactor, t),
      stackItemOpacity: lerpDouble(a.stackItemOpacity, b.stackItemOpacity, t),
    );
  }

  /// Helper method to lerp double values.
  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

/// A widget that provides a [ReorderableMultiSelectTheme] to its descendants.
///
/// This widget is useful for applying a consistent theme to all
/// ReorderableMultiSelectList widgets in a subtree.
class ReorderableMultiSelectThemeProvider extends InheritedWidget {
  /// The theme to provide to descendants.
  final ReorderableMultiSelectTheme theme;

  /// Creates a [ReorderableMultiSelectThemeProvider].
  const ReorderableMultiSelectThemeProvider({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  /// Gets the current [ReorderableMultiSelectTheme] from the closest provider.
  ///
  /// If there is no [ReorderableMultiSelectThemeProvider] in the widget tree,
  /// this will create a default theme based on the current [ThemeData].
  static ReorderableMultiSelectTheme of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ReorderableMultiSelectThemeProvider>();
    if (provider != null) {
      return provider.theme;
    }
    return ReorderableMultiSelectTheme.fromTheme(Theme.of(context));
  }

  @override
  bool updateShouldNotify(ReorderableMultiSelectThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
