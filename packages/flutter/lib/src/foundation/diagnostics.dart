// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'print.dart';

/// Styles for displaying a node in a [DiagnosticsNode] tree.
///
/// See also:
///
///  * [DiagnosticsNode.toStringDeep], which dumps text art trees for these
///    styles.
enum DiagnosticsTreeStyle {
  /// Sparse style for displaying trees.
  ///
  /// See also:
  ///
  ///  * [RenderObject], which uses this style.
  sparse,

  /// Connects a node to its parent with a dashed line.
  ///
  /// See also:
  ///
  ///  * [RenderSliverMultiBoxAdaptor], which uses this style to distinguish
  ///    offstage children from onstage children.
  offstage,

  /// Slightly more compact version of the [sparse] style.
  ///
  /// See also:
  ///
  ///  * [Element], which uses this style.
  dense,

  /// Style that enables transitioning from nodes of one style to children of
  /// another.
  ///
  /// See also:
  ///
  ///  * [RenderParagraph], which uses this style to display a [TextSpan] child
  ///    in a way that is compatible with the [DiagnosticsTreeStyle.sparse]
  ///    style of the [RenderObject] tree.
  transition,

  /// Render the tree just using whitespace without connecting parents to
  /// children using lines.
  ///
  /// See also:
  ///
  ///  * [SliverGeometry], which uses this style.
  whitespace,

  /// Render the tree on a single line without showing children.
  singleLine,
}

/// Configuration specifying how a particular [DiagnosticsTreeStyle] should be
/// rendered as text art.
///
/// See also:
///
///  * [sparseTextConfiguration], which is a typical style.
///  * [transitionTextConfiguration], which is an example of a complex tree style.
///  * [DiagnosticsNode.toStringDeep], for code using [TextTreeConfiguration]
///    to render text art for arbitrary trees of [DiagnosticsNode] objects.
class TextTreeConfiguration {
  /// Create a configuration object describing how to render a tree as text.
  ///
  /// All of the arguments must not be null.
  TextTreeConfiguration({
    @required this.prefixLineOne,
    @required this.prefixOtherLines,
    @required this.prefixLastChildLineOne,
    @required this.prefixOtherLinesRootNode,
    @required this.linkCharacter,
    @required this.propertyPrefixIfChildren,
    @required this.propertyPrefixNoChildren,
    this.lineBreak: '\n',
    this.lineBreakProperties: true,
    this.afterName: ':',
    this.afterDescriptionIfBody: '',
    this.beforeProperties: '',
    this.afterProperties: '',
    this.propertySeparator: '',
    this.bodyIndent: '',
    this.footer: '',
    this.showChildren: true,
    this.addBlankLineIfNoChildren: true,
    this.isNameOnOwnLine: false,
    this.isBlankLineBetweenPropertiesAndChildren: true,
  }) : assert(prefixLineOne != null),
       assert(prefixOtherLines != null),
       assert(prefixLastChildLineOne != null),
       assert(prefixOtherLinesRootNode != null),
       assert(linkCharacter != null),
       assert(propertyPrefixIfChildren != null),
       assert(propertyPrefixNoChildren != null),
       assert(lineBreak != null),
       assert(lineBreakProperties != null),
       assert(afterName != null),
       assert(afterDescriptionIfBody != null),
       assert(beforeProperties != null),
       assert(afterProperties != null),
       assert(propertySeparator != null),
       assert(bodyIndent != null),
       assert(footer != null),
       assert(showChildren != null),
       assert(addBlankLineIfNoChildren != null),
       assert(isNameOnOwnLine != null),
       assert(isBlankLineBetweenPropertiesAndChildren != null),
       childLinkSpace = ' ' * linkCharacter.length;

  /// Prefix to add to the first line to display a child with this style.
  final String prefixLineOne;

  /// Prefix to add to other lines to display a child with this style.
  ///
  /// [prefixOtherLines] should typically be one character shorter than
  /// [prefixLineOne] as
  final String prefixOtherLines;

  /// Prefix to add to the first line to display the last child of a node with
  /// this style.
  final String prefixLastChildLineOne;

  /// Additional prefix to add to other lines of a node if this is the root node
  /// of the tree.
  final String prefixOtherLinesRootNode;

  /// Prefix to add before each property if the node as children.
  ///
  /// Plays a similar role to [linkCharacter] except that some configurations
  /// intentionally use a different line style than the [linkCharacter].
  final String propertyPrefixIfChildren;

  /// Prefix to add before each property if the node does not have children.
  ///
  /// This string is typically a whitespace string the same length as
  /// [propertyPrefixIfChildren] but can have a different length.
  final String propertyPrefixNoChildren;

  /// Character to use to draw line linking parent to child.
  ///
  /// The first child does not require a line but all subsequent children do
  /// with the line drawn immediately before the left edge of the previous
  /// sibling.
  final String linkCharacter;

  /// Whitespace to draw instead of the childLink character if this node is the
  /// last child of its parent so no link line is required.
  final String childLinkSpace;

  /// Character(s) to use to separate lines.
  ///
  /// Typically leave set at the default value of '\n' unless this style needs
  /// to treat lines differently as is the case for
  /// [singleLineTextConfiguration].
  final String lineBreak;

  /// Whether to place line breaks between properties or to leave all
  /// properties on one line.
  final bool lineBreakProperties;

  /// Text added immediately after the name of the node.
  ///
  /// See [transitionTextConfiguration] for an example of using a value other
  /// than ':' to achieve a custom line art style.
  final String afterName;

  /// Text to add immediately after the description line of a node with
  /// properties and/or children.
  final String afterDescriptionIfBody;

  /// Optional string to add before the properties of a node.
  ///
  /// Only displayed if the node has properties.
  /// See [singleLineTextConfiguration] for an example of using this field
  /// to enclose the property list with parenthesis.
  final String beforeProperties;

  /// Optional string to add after the properties of a node.
  ///
  /// See documentation for [beforeProperties].
  final String afterProperties;

  /// Property separator to add between properties.
  ///
  /// See [singleLineTextConfiguration] for an example of using this field
  /// to render properties as a comma separated list.
  final String propertySeparator;

  /// Prefix to add to all lines of the body of the tree node.
  ///
  /// The body is all content in the node other than the name and description.
  final String bodyIndent;

  /// Whether the children of a node should be shown.
  ///
  /// See [singleLineTextConfiguration] for an example of using this field to
  /// hide all children of a node.
  final bool showChildren;

  /// Whether to add a blank line at the end of the output for a node if it has
  /// no children.
  ///
  /// See [denseTextConfiguration] for an example of setting this to false.
  final bool addBlankLineIfNoChildren;

  /// Whether the name should be displayed on the same line as the description.
  final bool isNameOnOwnLine;

  /// Footer to add as its own line at the end of a non-root node.
  ///
  /// See [transitionTextConfiguration] for an example of using footer to draw a box
  /// around the node. [footer] is indented the same amount as [prefixOtherLines].
  final String footer;

  /// Add a blank line between properties and children if both are present.
  final bool isBlankLineBetweenPropertiesAndChildren;
}

/// Default text tree configuration.
///
/// Example:
/// ```
/// <root_name>: <root_description>
///  │ <property1>
///  │ <property2>
///  │ ...
///  │ <propertyN>
///  ├─<child_name>: <child_description>
///  │ │ <property1>
///  │ │ <property2>
///  │ │ ...
///  │ │ <propertyN>
///  │ │
///  │ └─<child_name>: <child_description>
///  │     <property1>
///  │     <property2>
///  │     ...
///  │     <propertyN>
///  │
///  └─<child_name>: <child_description>'
///    <property1>
///    <property2>
///    ...
///    <propertyN>
/// ```
///
/// See also:
///
///  * [DiagnosticsTreeStyle.sparse]
final TextTreeConfiguration sparseTextConfiguration = new TextTreeConfiguration(
  prefixLineOne:            '├─',
  prefixOtherLines:         ' ',
  prefixLastChildLineOne:   '└─',
  linkCharacter:            '│',
  propertyPrefixIfChildren: '│ ',
  propertyPrefixNoChildren: '  ',
  prefixOtherLinesRootNode: ' ',
);

/// Identical to [sparseTextConfiguration] except that the lines connecting
/// parent to children are dashed.
///
/// Example:
/// ```
/// <root_name>: <root_description>
///  │ <property1>
///  │ <property2>
///  │ ...
///  │ <propertyN>
///  ├─<normal_child_name>: <child_description>
///  ╎ │ <property1>
///  ╎ │ <property2>
///  ╎ │ ...
///  ╎ │ <propertyN>
///  ╎ │
///  ╎ └─<child_name>: <child_description>
///  ╎     <property1>
///  ╎     <property2>
///  ╎     ...
///  ╎     <propertyN>
///  ╎
///  ╎╌<dashed_child_name>: <child_description>
///  ╎ │ <property1>
///  ╎ │ <property2>
///  ╎ │ ...
///  ╎ │ <propertyN>
///  ╎ │
///  ╎ └─<child_name>: <child_description>
///  ╎     <property1>
///  ╎     <property2>
///  ╎     ...
///  ╎     <propertyN>
///  ╎
///  └╌<dashed_child_name>: <child_description>'
///    <property1>
///    <property2>
///    ...
///    <propertyN>
/// ```
///
/// See also:
///
///  * [DiagnosticsTreeStyle.offstage], uses this style for ascii art display.
final TextTreeConfiguration dashedTextConfiguration = new TextTreeConfiguration(
  prefixLineOne:            '╎╌',
  prefixLastChildLineOne:   '└╌',
  prefixOtherLines:         ' ',
  linkCharacter:            '╎',
  // Intentionally not set as a dashed line as that would make the properties
  // look like they were disabled.
  propertyPrefixIfChildren: '│ ',
  propertyPrefixNoChildren: '  ',
  prefixOtherLinesRootNode: ' ',
);

/// Dense text tree configuration that minimizes horizontal whitespace.
///
/// Example:
/// ```
/// <root_name>: <root_description>(<property1>; <property2> <propertyN>)
/// ├<child_name>: <child_description>(<property1>, <property2>, <propertyN>)
/// └<child_name>: <child_description>(<property1>, <property2>, <propertyN>)
/// ```
///
/// See also:
///
///  * [DiagnosticsTreeStyle.dense]
final TextTreeConfiguration denseTextConfiguration = new TextTreeConfiguration(
  propertySeparator: ', ',
  beforeProperties: '(',
  afterProperties: ')',
  lineBreakProperties: false,
  prefixLineOne:            '├',
  prefixOtherLines:         '',
  prefixLastChildLineOne:   '└',
  linkCharacter:            '│',
  propertyPrefixIfChildren: '│',
  propertyPrefixNoChildren: ' ',
  prefixOtherLinesRootNode: '',
  addBlankLineIfNoChildren: false,
  isBlankLineBetweenPropertiesAndChildren: false,
);

/// Configuration that draws a box around a leaf node.
///
/// Used by leaf nodes such as [TextSpan] to draw a clear border around the
/// contents of a node.
///
/// Example:
/// ```
///  <parent_node>
///  ╞═╦══ <name> ═══
///  │ ║  <description>:
///  │ ║    <body>
///  │ ║    ...
///  │ ╚═══════════
///  ╘═╦══ <name> ═══
///    ║  <description>:
///    ║    <body>
///    ║    ...
///    ╚═══════════
/// ```
///
/// /// See also:
///
///  * [DiagnosticsTreeStyle.transition]
final TextTreeConfiguration transitionTextConfiguration = new TextTreeConfiguration(
  prefixLineOne:           '╞═╦══ ',
  prefixLastChildLineOne:  '╘═╦══ ',
  prefixOtherLines:         ' ║ ',
  footer:                   ' ╚═══════════\n',
  linkCharacter:            '│',
  // Subtree boundaries are clear due to the border around the node so omit the
  // property prefix.
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  prefixOtherLinesRootNode: '',
  afterName:                ' ═══',
  // Add a colon after the description if the node has a body to make the
  // connection between the description and the body clearer.
  afterDescriptionIfBody: ':',
  // Members are indented an extra two spaces to disambiguate as the description
  // is placed within the box instead of along side the name as is the case for
  // other styles.
  bodyIndent: '  ',
  isNameOnOwnLine: true,
  // No need to add a blank line as the footer makes the boundary of this
  // subtree unambiguous.
  addBlankLineIfNoChildren: false,
  isBlankLineBetweenPropertiesAndChildren: false,
);

/// Whitespace only configuration where children are consistently indented
/// two spaces.
///
/// Use this style for displaying properties with structured values or for
/// displaying children within a [transitionTextConfiguration] as using a style that
/// draws line art would be visually distracting for those cases.
///
/// Example:
/// ```
/// <parent_node>
///   <name>: <description>:
///     <properties>
///     <children>
///   <name>: <description>:
///     <properties>
///     <children>
///```
///
/// See also:
///
///  * [DiagnosticsTreeStyle.whitespace]
final TextTreeConfiguration whitespaceTextConfiguration = new TextTreeConfiguration(
  prefixLineOne: '',
  prefixLastChildLineOne: '',
  prefixOtherLines: ' ',
  prefixOtherLinesRootNode: '  ',
  bodyIndent: '',
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  linkCharacter: ' ',
  addBlankLineIfNoChildren: false,
  // Add a colon after the description and before the properties to link the
  // properties to the description line.
  afterDescriptionIfBody: ':',
  isBlankLineBetweenPropertiesAndChildren: false,
);

/// Render a node as a single line omitting children.
///
/// Example:
/// `<name>: <description>(<property1>, <property2>, ..., <propertyN>)`
///
/// See also:
///
///   * [DiagnosticsTreeStyle.singleLine]
final TextTreeConfiguration singleLineTextConfiguration = new TextTreeConfiguration(
  propertySeparator: ', ',
  beforeProperties: '(',
  afterProperties: ')',
  prefixLineOne: '',
  prefixOtherLines: '',
  prefixLastChildLineOne: '',
  lineBreak: '',
  lineBreakProperties: false,
  addBlankLineIfNoChildren: false,
  showChildren: false,
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  linkCharacter: '',
  prefixOtherLinesRootNode: '',
);

/// Builder that builds a String with specified prefixes for the first and
/// subsequent lines.
///
/// Allows for the incremental building of strings using `write*()` methods.
/// The strings are concatenated into a single string with the first line
/// prefixed by [prefixLineOne] and subsequent lines prefixed by
/// [prefixOtherLines].
class _PrefixedStringBuilder {
  _PrefixedStringBuilder(this.prefixLineOne, this.prefixOtherLines);

  /// Prefix to add to the first line.
  final String prefixLineOne;

  /// Prefix to add to subsequent lines.
  ///
  /// The prefix can be modified while the string is being built in which case
  /// subsequent lines will be added with the modified prefix.
  String prefixOtherLines;

  final StringBuffer _buffer = new StringBuffer();
  bool _atLineStart = true;
  bool _hasMultipleLines = false;

  /// Whether the string being built already has more than 1 line.
  bool get hasMultipleLines => _hasMultipleLines;

  /// Write text ensuring the specified prefixes for the first and subsequent
  /// lines.
  void write(String s) {
    if (s.isEmpty)
      return;

    if (s == '\n') {
      // Edge case to avoid adding trailing whitespace when the caller did
      // not explicitly add trailing trailing whitespace.
      if (_buffer.isEmpty) {
        _buffer.write(prefixLineOne.trimRight());
      } else if (_atLineStart) {
        _buffer.write(prefixOtherLines.trimRight());
        _hasMultipleLines = true;
      }
      _buffer.write('\n');
      _atLineStart = true;
      return;
    }

    if (_buffer.isEmpty) {
      _buffer.write(prefixLineOne);
    } else if (_atLineStart) {
      _buffer.write(prefixOtherLines);
      _hasMultipleLines = true;
    }
    bool lineTerminated = false;

    if (s.endsWith('\n')) {
      s = s.substring(0, s.length - 1);
      lineTerminated = true;
    }
    final List<String> parts = s.split('\n');
    _buffer.write(parts[0]);
    for (int i = 1; i < parts.length; ++i) {
      _buffer
        ..write('\n')
        ..write(prefixOtherLines)
        ..write(parts[i]);
    }

    if (lineTerminated)
      _buffer.write('\n');

    _atLineStart = lineTerminated;
  }

  /// Write text assuming the text already obeys the specified prefixes for the
  /// first and subsequent lines.
  void writeRaw(String text) {
    if (text.isEmpty)
      return;
    _buffer.write(text);
    _atLineStart = text.endsWith('\n');
  }


  /// Write a line assuming the line obeys the specified prefixes. Ensures that
  /// a newline is added if one is not present.
  /// The same as [writeRaw] except a newline is added at the end of [line] if
  /// one is not already present.
  ///
  /// A new line is not added if the input string already contains a newline.
  void writeRawLine(String line) {
    if (line.isEmpty)
      return;
    _buffer.write(line);
    if (!line.endsWith('\n'))
      _buffer.write('\n');
    _atLineStart = true;
  }

  @override
  String toString() => _buffer.toString();
}

class _NoDefaultValue {
  const _NoDefaultValue();
}

/// Marker object indicating that a [DiagnosticsNode] has no default value.
const _NoDefaultValue kNoDefaultValue = const _NoDefaultValue();

/// Defines diagnostics data for a [value].
///
/// [DiagnosticsNode] provides a high quality multi-line string dump via
/// [toStringDeep]. The core members are the [name], [toDescription],
/// [getProperties], [value], and [getChildren]. All other members exist
/// typically to provide hints for how [toStringDeep] and debugging tools should
/// format output.
abstract class DiagnosticsNode {
  /// Initializes the object.
  ///
  /// The [style], [showName] and [showSeparator] arguments must not be null.
  DiagnosticsNode({
    @required this.name,
    this.style,
    this.showName: true,
    this.showSeparator: true,
  }) : assert(showName != null),
       assert(showSeparator != null) {
    // A name ending with ':' indicates that the user forgot that the ':' will
    // be automatically added for them when generating descriptions of the
    // property.
    assert(name == null || !name.endsWith(':'), 'Names of diagnostic nodes must not end with colons.');
  }

  /// Diagnostics containing just a string `message` and not a concrete name or
  /// value.
  ///
  /// The [style] argument must not be null.
  ///
  /// See also:
  ///
  ///  * [MessageProperty], which is better suited to messages that are to be
  ///    formatted like a property with a separate name and message.
  factory DiagnosticsNode.message(
    String message, {
    DiagnosticsTreeStyle style: DiagnosticsTreeStyle.singleLine,
  }) {
    assert(style != null);
    return new DiagnosticsProperty<Null>(
      '',
      null,
      description: message,
      style: style,
      showName: false,
    );
  }

  /// Label describing the [DiagnosticsNode], typically shown before a separator
  /// (see [showSeparator]).
  ///
  /// The name will be omitted if the [showName] property is false.
  final String name;

  /// Returns a description with a short summary of the node itself not
  /// including children or properties.
  ///
  /// `parentConfiguration` specifies how the parent is rendered as text art.
  /// For example, if the parent does not line break between properties, the
  /// description of a property should also be a single line if possible.
  String toDescription({ TextTreeConfiguration parentConfiguration });

  /// Whether to show a separator between [name] and description.
  ///
  /// If false, name and description should be shown with no separation.
  /// `:` is typically used as a separator when displaying as text.
  final bool showSeparator;

  /// Whether the diagnostics should be hidden when showing the default
  /// view of a tree.
  bool get hidden;

  /// Whether the name of the property should be shown when showing the default
  /// view of the tree.
  ///
  /// This could be set to false (hiding the name) if the value's description
  /// will make the name self-evident.
  final bool showName;

  /// Description to show if the node has no displayed properties or children.
  String get emptyBodyDescription => null;

  /// The actual object this is diagnostics data for.
  Object get value;

  /// Hint for how the node should be displayed.
  final DiagnosticsTreeStyle style;

  /// Properties of this [DiagnosticsNode].
  ///
  /// Properties and children are kept distinct even though they are both
  /// [List<DiagnosticsNode>] because they should be grouped differently.
  List<DiagnosticsNode> getProperties();

  /// Children of this [DiagnosticsNode].
  ///
  /// See also:
  ///
  ///  * [getProperties]
  List<DiagnosticsNode> getChildren();

  String get _separator => showSeparator ? ':' : '';

  /// Returns a string representation of this diagnostic that is compatible with
  /// the style of the parent if the node is not the root.
  ///
  /// `parentConfiguration` specifies how the parent is rendered as text art.
  /// For example, if the parent places all properties on one line, the
  /// [toString] for each property should avoid line breaks if possible.
  @override
  String toString({ TextTreeConfiguration parentConfiguration }) {
    assert(style != null);
    if (style == DiagnosticsTreeStyle.singleLine)
      return toStringDeep('', '', parentConfiguration);

    final String description = toDescription(parentConfiguration: parentConfiguration);

    if (name == null || name.isEmpty || !showName)
      return description;

    return description.contains('\n') ? '$name$_separator\n$description'
                                      : '$name$_separator $description';
  }

  /// Returns a configuration specifying how this object should be rendered
  /// as text art.
  @protected
  TextTreeConfiguration get textTreeConfiguration {
    assert(style != null);
    switch (style) {
      case DiagnosticsTreeStyle.dense:
        return denseTextConfiguration;
      case DiagnosticsTreeStyle.sparse:
        return sparseTextConfiguration;
      case DiagnosticsTreeStyle.offstage:
        return dashedTextConfiguration;
      case DiagnosticsTreeStyle.whitespace:
        return whitespaceTextConfiguration;
      case DiagnosticsTreeStyle.transition:
        return transitionTextConfiguration;
      case DiagnosticsTreeStyle.singleLine:
        return singleLineTextConfiguration;
    }
    return null;
  }

  /// Text configuration to use to connect this node to a `child`.
  ///
  /// The singleLine style is special cased because the connection from the
  /// parent to the child should be consistent with the parent's style as the
  /// single line style does not provide any meaningful style for how children
  /// should be connected to their parents.
  TextTreeConfiguration _childTextConfiguration(
    DiagnosticsNode child,
    TextTreeConfiguration textStyle,
  ) {
    return (child != null && child.style != DiagnosticsTreeStyle.singleLine) ?
        child.textTreeConfiguration : textStyle;
  }

  /// Returns a string representation of this node and its descendants.
  ///
  /// The [toStringDeep] method takes arguments, but those are intended for
  /// internal use when recursing to the descendants, and so can be ignored.
  ///
  /// See also:
  ///
  ///  * [toString], for a brief description of the [value] but not its children.
  ///  * [toStringShallow], for a detailed description of the [value] but not its
  ///    children.
  String toStringDeep([String prefixLineOne = '', String prefixOtherLines, TextTreeConfiguration parentConfiguration]) {
    prefixOtherLines ??= prefixLineOne;

    final List<DiagnosticsNode> children = getChildren();
    final TextTreeConfiguration config = textTreeConfiguration;
    if (prefixOtherLines.isEmpty)
      prefixOtherLines += config.prefixOtherLinesRootNode;

    final _PrefixedStringBuilder builder =  new _PrefixedStringBuilder(
        prefixLineOne, prefixOtherLines);

    final String description = toDescription(parentConfiguration: parentConfiguration);
    if (description == null || description.isEmpty) {
      if (showName && name != null)
        builder.write(name);
    } else {
      if (name != null && name.isNotEmpty && showName) {
        builder.write(name);
        if (showSeparator)
          builder.write(config.afterName);

        builder.write(
            config.isNameOnOwnLine || description.contains('\n') ? '\n' : ' ');
      }
      builder.prefixOtherLines += children.isEmpty ?
          config.propertyPrefixNoChildren : config.propertyPrefixIfChildren;
      builder.write(description);
    }

    final List<DiagnosticsNode> properties =
        getProperties().where((DiagnosticsNode n) => !n.hidden).toList();
    if (properties.isNotEmpty || children.isNotEmpty || emptyBodyDescription != null)
      builder.write(config.afterDescriptionIfBody);

    if (config.lineBreakProperties)
      builder.write(config.lineBreak);

    if (properties.isNotEmpty)
      builder.write(config.beforeProperties);

    builder.prefixOtherLines += config.bodyIndent;

    if (emptyBodyDescription != null &&
        properties.isEmpty &&
        children.isEmpty &&
        prefixLineOne.isNotEmpty) {
      builder.write(emptyBodyDescription);
      if (config.lineBreakProperties)
        builder.write(config.lineBreak);
    }

    for (int i = 0; i < properties.length; ++i) {
      final DiagnosticsNode property = properties[i];
      if (i > 0)
        builder.write(config.propertySeparator);

      final int kWrapWidth = 65;
      if (property.style != DiagnosticsTreeStyle.singleLine) {
        final TextTreeConfiguration propertyStyle = property.textTreeConfiguration;
        builder.writeRaw(property.toStringDeep(
            '${builder.prefixOtherLines}${propertyStyle.prefixLineOne}',
            '${builder.prefixOtherLines}${propertyStyle.linkCharacter}${propertyStyle.prefixOtherLines}',
            config,
        ));
        continue;
      }
      assert(property.style == DiagnosticsTreeStyle.singleLine);
      final String message = property.toString(parentConfiguration: config);
      if (!config.lineBreakProperties || message.length < kWrapWidth) {
        builder.write(message);
      } else {
        // debugWordWrap doesn't handle line breaks within the text being
        // wrapped so we must call it on each line.
        final List<String> lines = message.split('\n');
        for (int j = 0; j < lines.length; ++j) {
          final String line = lines[j];
          if (j > 0)
            builder.write(config.lineBreak);
          builder.write(debugWordWrap(line, kWrapWidth, wrapIndent: '  ').join('\n'));
        }
      }
      if (config.lineBreakProperties)
        builder.write(config.lineBreak);
    }
    if (properties.isNotEmpty)
      builder.write(config.afterProperties);

    if (!config.lineBreakProperties)
      builder.write(config.lineBreak);

    final String prefixChildren = '$prefixOtherLines${config.bodyIndent}';

    if (children.isEmpty &&
        config.addBlankLineIfNoChildren &&
        builder.hasMultipleLines) {
      final String prefix = prefixChildren.trimRight();
      if (prefix.isNotEmpty)
        builder.writeRaw('$prefix${config.lineBreak}');
    }

    if (children.isNotEmpty && config.showChildren) {
      if (config.isBlankLineBetweenPropertiesAndChildren &&
          properties.isNotEmpty &&
          children.first.textTreeConfiguration.isBlankLineBetweenPropertiesAndChildren) {
        builder.write(config.lineBreak);
      }

      for (int i = 0; i < children.length; i++) {
        final DiagnosticsNode child = children[i];
        assert(child != null);
        final TextTreeConfiguration childConfig = _childTextConfiguration(child, config);
        if (i == children.length - 1) {
          final String lastChildPrefixLineOne = '$prefixChildren${childConfig.prefixLastChildLineOne}';
          builder.writeRawLine(child.toStringDeep(
            lastChildPrefixLineOne,
            '$prefixChildren${childConfig.childLinkSpace}${childConfig.prefixOtherLines}',
            config,
          ));
          if (childConfig.footer.isNotEmpty)
            builder.writeRaw('$prefixChildren${childConfig.childLinkSpace}${childConfig.footer}');
        } else {
          final TextTreeConfiguration nextChildStyle = _childTextConfiguration(children[i + 1], config);
          final String childPrefixLineOne = '$prefixChildren${childConfig.prefixLineOne}';
          final String childPrefixOtherLines ='$prefixChildren${nextChildStyle.linkCharacter}${childConfig.prefixOtherLines}';
          builder.writeRawLine(child.toStringDeep(childPrefixLineOne, childPrefixOtherLines));
          if (childConfig.footer.isNotEmpty)
            builder.writeRaw('$prefixChildren${nextChildStyle.linkCharacter}${childConfig.footer}');
        }
      }
    }
    return builder.toString();
  }
}

/// Debugging message displayed like a property.
///
/// ## Sample code
///
/// The following two properties are better expressed using this
/// [MessageProperty] class, rather than [StringProperty], as the intent is to
/// show a message with property style display rather than to describe the value
/// of an actual property of the object:
///
/// ```dart
/// new MessageProperty('table size', '$columns\u00D7$rows')
/// ```
/// ```dart
/// new MessageProperty('usefulness ratio', 'no metrics collected yet (never painted)')
/// ```
///
/// On the other hand, [StringProperty] is better suited when the property has a
/// concrete value that is a string:
///
/// ```dart
/// new StringProperty('name', _name)
/// ```
///
/// See also:
///
///  * [DiagnosticsNode.message], which serves the same role for messages
///    without a clear property name.
///  * [StringProperty], which is a better fit for properties with string values.
class MessageProperty extends DiagnosticsProperty<Null> {
  /// Create a diagnostics property that displays a message.
  ///
  /// Messages have no concrete [value] (so [value] will return null). The
  /// message is stored as the description.
  ///
  /// The [name] and `message` arguments must not be null.
  MessageProperty(String name, String message)
   : assert(name != null),
     assert(message != null),
     super(name, null, description: message);
}

/// Property which encloses its string [value] in quotes.
///
/// See also:
///
///  * [MessageProperty], which is a better fit for showing a message
///    instead of describing a property with a string value.
class StringProperty extends DiagnosticsProperty<String> {
  /// Create a diagnostics property for strings.
  ///
  /// The [showName], [hidden], and [quoted] arguments must not be null.
  StringProperty(String name, String value, {
    String description,
    bool showName: true,
    Object defaultValue: kNoDefaultValue,
    bool hidden: false,
    this.quoted: true,
    String ifEmpty,
  }) : assert(showName != null),
       assert(hidden != null),
       assert(quoted != null),
       super(
    name,
    value,
    description: description,
    defaultValue: defaultValue,
    showName: showName,
    hidden: hidden,
    ifEmpty: ifEmpty,
  );

  /// Whether the description is enclosed in double quotes.
  final bool quoted;

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    String text = _description ?? value;
    if (parentConfiguration != null &&
        !parentConfiguration.lineBreakProperties &&
        text != null) {
      // Escape linebreaks in multiline strings to avoid confusing output when
      // the parent of this node is trying to display all properties on the same
      // line.
      text = text.replaceAll('\n', '\\n');
    }

    if (quoted && text != null) {
      // An empty value would not appear empty after being surrounded with
      // quotes so we have to handle this case separately.
      if (ifEmpty != null && text.isEmpty)
        return ifEmpty;
      return '"$text"';
    }
    return text.toString();
  }
}

abstract class _NumProperty<T extends num> extends DiagnosticsProperty<T> {
  _NumProperty(String name,
    T value, {
    bool hidden: false,
    String ifNull,
    this.unit,
    bool showName: true,
    Object defaultValue: kNoDefaultValue,
    String tooltip,
  }) : super(
    name,
    value,
    hidden: hidden,
    ifNull: ifNull,
    showName: showName,
    defaultValue: defaultValue,
    tooltip: tooltip,
  );

  _NumProperty.lazy(String name,
    ComputePropertyValueCallback<T> computeValue, {
    bool hidden: false,
    String ifNull,
    this.unit,
    bool showName: true,
    Object defaultValue: kNoDefaultValue,
    String tooltip,
  }) : super.lazy(
    name,
    computeValue,
    hidden: hidden,
    ifNull: ifNull,
    showName: showName,
    defaultValue: defaultValue,
    tooltip: tooltip,
  );


  /// Optional unit the [value] is measured in.
  ///
  /// Unit must be acceptable to display immediately after a number with no
  /// spaces. For example: 'physical pixels per logical pixel' should be a
  /// [tooltip] not a [unit].
  final String unit;

  /// String describing just the numeric [value] without a unit suffix.
  String numberToString();

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value == null)
      return value.toString();

    return unit != null ?  '${numberToString()}$unit' : numberToString();
  }
}
/// Property describing a [double] [value] with an optional [unit] of measurement.
///
/// Numeric formatting is optimized for debug message readability.
class DoubleProperty extends _NumProperty<double> {
  /// If specified, [unit] describes the unit for the [value] (e.g. px).
  DoubleProperty(String name, double value, {
    bool hidden: false,
    String ifNull,
    String unit,
    String tooltip,
    Object defaultValue: kNoDefaultValue,
    bool showName : true,
  }) : super(
    name,
    value,
    hidden: hidden,
    ifNull: ifNull,
    unit: unit,
    tooltip: tooltip,
    defaultValue: defaultValue,
    showName: showName,
  );

  /// Property with a [value] that is computed only when needed.
  ///
  /// Use if computing the property [value] may throw an exception or is
  /// expensive.
  DoubleProperty.lazy(
    String name,
    ComputePropertyValueCallback<double> computeValue, {
    bool hidden: false,
    String ifNull,
    String unit,
    String tooltip,
    Object defaultValue: kNoDefaultValue,
  }) : super.lazy(
    name,
    computeValue,
    hidden: hidden,
    ifNull: ifNull,
    unit: unit,
    tooltip: tooltip,
    defaultValue: defaultValue,
  );

  @override
  String numberToString() => value?.toStringAsFixed(1);
}

/// An int valued property with an optional unit the value is measured in.
///
/// Examples of units include 'px' and 'ms'.
class IntProperty extends _NumProperty<int> {
  /// Create a diagnostics property for integers.
  ///
  /// The [showName] and [hidden] arguments must not be null.
  IntProperty(String name, int value, {
    String ifNull,
    bool showName: true,
    String unit,
    Object defaultValue: kNoDefaultValue,
    bool hidden: false,
  }) : assert(showName != null),
       assert(hidden != null),
       super(
    name,
    value,
    ifNull: ifNull,
    showName: showName,
    unit: unit,
    defaultValue: defaultValue,
    hidden: hidden,
  );

  @override
  String numberToString() => value.toString();
}

/// Property which clamps a [double] to between 0 and 1 and formats it as a
/// percentage.
class PercentProperty extends DoubleProperty {
  /// Create a diagnostics property for doubles that represent percentages or
  /// fractions.
  ///
  /// Setting [showName] to false is often reasonable for [PercentProperty]
  /// objects, as the fact that the property is shown as a percentage tends to
  /// be sufficient to disambiguate its meaning.
  ///
  /// The [showName] and [hidden] arguments must not be null.
  PercentProperty(String name, double fraction, {
    String ifNull,
    bool showName: true,
    String tooltip,
    String unit,
    bool hidden: false,
  }) : assert(showName != null),
       assert(hidden != null),
       super(
    name,
    fraction,
    ifNull: ifNull,
    showName: showName,
    tooltip: tooltip,
    unit: unit,
    hidden: hidden,
  );

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value == null)
      return value.toString();
    return unit != null ?  '${numberToString()} $unit' : numberToString();
  }

  @override
  String numberToString() {
    if (value == null)
      return value.toString();
    return '${(value.clamp(0.0, 1.0) * 100.0).toStringAsFixed(1)}%';
  }
}

/// Property where the description is either [ifTrue] or [ifFalse] depending on
/// whether [value] is true or false.
///
/// Using [FlagProperty] instead of [DiagnosticsProperty<bool>] can make
/// diagnostics display more polished. For example, given a property named
/// `visible` that is typically true, the following code will return 'hidden'
/// when `visible` is false and nothing when visible is true, in contrast to
/// `visible: true` or `visible: false`.
///
/// ## Sample code
///
/// ```dart
/// new FlagProperty(
///   'visible',
///   value: true,
///   ifFalse: 'hidden',
/// )
/// ```
///
/// [FlagProperty] should also be used instead of [DiagnosticsProperty<bool>]
/// if showing the bool value would not clearly indicate the meaning of the
/// property value.
///
/// ```dart
/// new FlagProperty(
///   'inherit',
///   value: inherit,
///   ifTrue: '<all styles inherited>',
///   ifFalse: '<no style specified>',
/// )
/// ```
///
/// See also:
///
///  * [ObjectFlagProperty], which provides similar behavior describing whether
///    a [value] is null.
class FlagProperty extends DiagnosticsProperty<bool> {
  /// Constructs a FlagProperty with the given descriptions  with the specified descriptions.
  ///
  /// [showName] defaults to false as typically [ifTrue] and [ifFalse] should
  /// be descriptions that make the property name redundant.
  FlagProperty(String name, {
    @required bool value,
    this.ifTrue,
    this.ifFalse,
    bool showName: false,
    bool hidden: false,
    Object defaultValue,
  }) : super(
    name,
    value,
    showName: showName,
    hidden: hidden,
    defaultValue: defaultValue,
  ) {
    assert(ifTrue != null || ifFalse != null);
  }

  /// Description to use if the property [value] is true.
  ///
  /// If not specified and [value] equals true, the description is set to the
  /// empty string and the property is [hidden].
  final String ifTrue;

  /// Description to use if the property value is false.
  ///
  /// If not specified and [value] equals false, the description is set to the
  /// empty string and the property is [hidden].
  final String ifFalse;

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value == true)
      return ifTrue ?? '';
    if (value == false)
      return ifFalse ?? '';
    return '';
  }

  @override
  bool get hidden {
    if (_hidden || value == defaultValue)
      return true;
    if (value == true)
      return ifTrue == null;
    if (value == false)
      return ifFalse == null;
    return true;
  }
}

/// Property with an `Iterable<T>` [value] that can be displayed with
/// different [DiagnosticsTreeStyle] for custom rendering.
///
/// If [style] is [DiagnosticsTreeStyle.singleLine], the iterable is described
/// as a comma separated list, otherwise the iterable is described as a line
/// break separated list.
class IterableProperty<T> extends DiagnosticsProperty<Iterable<T>> {
  /// Create a diagnostics property for iterables (e.g. lists).
  ///
  /// The [ifEmpty] argument must not be null, as otherwise an iterable
  /// value with 0 elements would, confusingly, be displayed as the empty
  /// string. It defaults to the string `[]`.
  ///
  /// The [style] and [hidden] arguments must also not be null.
  IterableProperty(String name, Iterable<T> value, {
    Object defaultValue: kNoDefaultValue,
    String ifNull,
    String ifEmpty: '[]',
    DiagnosticsTreeStyle style: DiagnosticsTreeStyle.singleLine,
    bool hidden: false,
  }) : assert(ifEmpty != null),
       assert(style != null),
       assert(hidden != null),
       super(
    name,
    value,
    defaultValue: defaultValue,
    ifNull: ifNull,
    ifEmpty: ifEmpty,
    style: style,
    hidden: hidden,
  );

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value == null)
      return value.toString();

    if (parentConfiguration != null && !parentConfiguration.lineBreakProperties) {
      // Always display the value as a single line and enclose the iterable
      // value in brackets to avoid ambiguity.
      return '[${value.join(', ')}]';
    }

    return value.join(style == DiagnosticsTreeStyle.singleLine ? ', ' : '\n');
  }
}

/// An property than displays enum values tersely.
///
/// The enum value is converted to a hyphen-separated string. For example:
/// [HitTestBehavior.deferToChild] is shown as `defer-to-child`.
///
/// See also:
///
///  * [DiagnosticsProperty] which documents named parameters common to all
///    [DiagnosticsProperty]
class EnumProperty<T> extends DiagnosticsProperty<T> {
  /// Create a diagnostics property that displays an enum.
  ///
  /// The [hidden] argument must not be null.
  EnumProperty(String name, T value, {
    Object defaultValue: kNoDefaultValue,
    bool hidden: false,
  }) : super (
    name,
    value,
    defaultValue: defaultValue,
    hidden: hidden,
  );

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value == null)
      return value.toString();
    return camelCaseToHyphenatedName(describeEnum(value));
  }
}

/// A property where the important diagnostic information is primarily whether
/// the [value] is present (non-null) or absent (null), rather than the actual
/// value of the property itself.
///
/// The [ifPresent] and [ifNull] strings describe the property [value] when it
/// is non-null and null respectively. If one of [ifPresent] or [ifNull] is
/// omitted, that is taken to mean that [hidden] should be true when [value] is
/// non-null or null respectively.
///
/// This kind of diagnostics property is typically used for values mostly opaque
/// values, like closures, where presenting the actual object is of dubious
/// value but where reporting the presence or absence of the value is much more
/// useful.
///
/// See also:
///
///  * [FlagProperty], which provides similar functionality describing whether
///    a [value] is true or false.
class ObjectFlagProperty<T> extends DiagnosticsProperty<T> {
  /// Create a diagnostics property for values that can be present (non-null) or
  /// absent (null), but for which the exact value's [Object.toString]
  /// representation is not very transparent (e.g. a callback).
  ///
  /// The [showName] and [hidden] arguments must not be null. Additionally, at
  /// least one of [ifPresent] and [ifNull] must not be null.
  ObjectFlagProperty(String name, T value, {
    this.ifPresent,
    String ifNull,
    bool showName: false,
    bool hidden: false,
  }) : assert(ifPresent != null || ifNull != null),
       assert(showName != null),
       assert(hidden != null),
       super(
    name,
    value,
    showName: showName,
    hidden: hidden,
    ifNull: ifNull,
  );

  /// Shorthand constructor to describe whether the property has a value.
  ///
  /// Only use if prefixing the property name with the word 'has' is a good
  /// flag name.
  ObjectFlagProperty.has(
    String name,
    T value,
  ) : ifPresent = 'has $name',
      super(
        name,
        value,
        showName: false,
      );

  /// Description to use if the property [value] is not null.
  ///
  /// If the property [value] is not null and [ifPresent] is null, the
  /// description returns the empty string and the property is [hidden].
  final String ifPresent;

  @override
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    if (value != null)
      return ifPresent ?? '';

    return ifNull ?? '';
  }

  @override
  bool get hidden {
    if (super.hidden)
      return true;
    if (value != null)
      return ifPresent == null;
    return ifNull == null;
  }
}

/// Signature for computing the value of a property.
///
/// May throw exception if accessing the property would throw an exception
/// and callers must handle that case gracefully. For example, accessing a
/// property may trigger an assert that layout constraints were violated.
typedef T ComputePropertyValueCallback<T>();

/// Property with a [value] of type [T].
///
/// If the default `value.toString()` does not provide an adequate description
/// of the value, specify `description` defining a custom description.
///
/// The [hidden] property specifies whether the property should be hidden from
/// the default output (e.g. the output given by [toStringDeep]).
///
/// The [showSeparator] property indicates whether a separator should be placed
/// between the property [name] and its [value].
class DiagnosticsProperty<T> extends DiagnosticsNode {
  /// Create a diagnostics property.
  ///
  /// The [hidden], [showName], [showSeparator], and [style] arguments must not be null.
  DiagnosticsProperty(
    String name,
    T value, {
    String description,
    bool hidden: false,
    this.ifNull,
    this.ifEmpty,
    bool showName: true,
    bool showSeparator: true,
    this.defaultValue: kNoDefaultValue,
    this.tooltip,
    DiagnosticsTreeStyle style: DiagnosticsTreeStyle.singleLine,
  }) : assert(hidden != null),
       assert(showName != null),
       assert(showSeparator != null),
       assert(style != null),
       _description = description,
       _valueComputed = true,
       _value = value,
       _computeValue = null,
       _hidden = hidden,
       super(
         name: name,
         showName: showName,
         showSeparator: showSeparator,
         style: style,
      );

  /// Property with a [value] that is computed only when needed.
  ///
  /// Use if computing the property [value] may throw an exception or is
  /// expensive.
  ///
  /// The [hidden], [showName], [showSeparator], and [style] arguments must not
  /// be null.
  DiagnosticsProperty.lazy(
    String name,
    ComputePropertyValueCallback<T> computeValue, {
    String description,
    bool hidden: false,
    this.ifNull,
    this.ifEmpty,
    bool showName: true,
    bool showSeparator: true,
    this.defaultValue: kNoDefaultValue,
    this.tooltip,
    DiagnosticsTreeStyle style: DiagnosticsTreeStyle.singleLine,
  }) : assert(hidden != null),
       assert(showName != null),
       assert(showSeparator != null),
       assert(defaultValue == kNoDefaultValue || defaultValue is T),
       assert(style != null),
       _description = description,
       _valueComputed = false,
       _value = null,
       _computeValue = computeValue,
       _hidden = hidden,
       super(
         name: name,
         showName: showName,
         showSeparator: showSeparator,
         style: style,
       );

  final String _description;

  /// Returns a string representation of the property value.
  ///
  /// Subclasses should override this method instead of [toDescription] to
  /// customize how property values are converted to strings.
  ///
  /// Overriding this method ensures that behavior controlling how property
  /// values are decorated to generate a nice [toDescription] are consistent
  /// across all implementations. Debugging tools may also choose to use
  /// [valueToString] directly instead of [toDescription].
  ///
  /// `parentConfiguration` specifies how the parent is rendered as text art.
  /// For example, if the parent places all properties on one line, the value
  /// of the property should be displayed without line breaks if possible.
  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    final T v = value;
    // DiagnosticableTree values are shown using the shorter toStringShort()
    // instead of the longer toString() because the toString() for a
    // DiagnosticableTree value is likely too large to be useful.
    return v is DiagnosticableTree ? v.toStringShort() : v.toString();
  }

  @override
  String toDescription({ TextTreeConfiguration parentConfiguration }) {
    if (_description != null)
      return _addTooltip(_description);

    if (exception != null)
      return 'EXCEPTION (${exception.runtimeType})';

    if (ifNull != null && value == null)
      return _addTooltip(ifNull);

    String result = valueToString(parentConfiguration: parentConfiguration);
    if (result.isEmpty && ifEmpty != null)
      result = ifEmpty;
    return _addTooltip(result);
  }

  /// If a [tooltip] is specified, add the tooltip it to the end of `text`
  /// enclosing it parenthesis to disambiguate the tooltip from the rest of
  /// the text.
  ///
  /// `text` must not be null.
  String _addTooltip(String text) {
    assert(text != null);
    return tooltip == null ? text : '$text ($tooltip)';
  }

  /// Description if the property [value] is null.
  final String ifNull;

  /// Description if the property description would otherwise be empty.
  final String ifEmpty;

  /// Optional tooltip typically describing the property.
  ///
  /// Example tooltip: 'physical pixels per logical pixel'
  ///
  /// If present, the tooltip is added in parenthesis after the raw value when
  /// generating the string description.
  final String tooltip;

  /// The type of the property [value].
  ///
  /// This is determined from the type argument `T` used to instantiate the
  /// [DiagnosticsProperty] class. This means that the type is available even if
  /// [value] is null, but it also means that the [propertyType] is only as
  /// accurate as the type provided when invoking the constructor.
  ///
  /// Generally, this is only useful for diagnostic tools that should display
  /// null values in a manner consistent with the property type. For example, a
  /// tool might display a null [Color] value as an empty rectangle instead of
  /// the word "null".
  Type get propertyType => T;

  /// Returns the value of the property either from cache or by invoking a
  /// [ComputePropertyValueCallback].
  ///
  /// If an exception is thrown invoking the [ComputePropertyValueCallback],
  /// [value] returns null and the exception thrown can be found via the
  /// [exception] property.
  ///
  /// See also:
  ///
  ///  * [valueToString], which converts the property value to a string.
  @override
  T get value {
    _maybeCacheValue();
    return _value;
  }

  T _value;

  bool _valueComputed;

  Object _exception;

  /// Exception thrown if accessing the property [value] threw an exception.
  ///
  /// Returns null if computing the property value did not throw an exception.
  Object get exception {
    _maybeCacheValue();
    return _exception;
  }

  void _maybeCacheValue() {
    if (_valueComputed)
      return;

    _valueComputed = true;
    assert(_computeValue != null);
    try {
      _value = _computeValue();
    } catch (exception) {
      _exception = exception;
      _value = null;
    }
  }

  /// If the [value] of the property equals [defaultValue] the property is
  /// [hidden] as the [value] is uninteresting.
  ///
  /// [defaultValue] has type [T] or is [kNoDefaultValue].
  final Object defaultValue;

  final bool _hidden;

  /// Whether the property should be hidden when showing the default
  /// view of a tree.
  ///
  /// This could be set to true (hiding the property) if another property
  /// provides a normally more useful summary of the value.
  @override
  bool get hidden {
    if (_hidden)
      return true;
    if (defaultValue != kNoDefaultValue) {
      if (exception != null)
        return false;
      return value == defaultValue;
    }
    return false;
  }

  final ComputePropertyValueCallback<T> _computeValue;

  @override
  List<DiagnosticsNode> getProperties() => <DiagnosticsNode>[];

  @override
  List<DiagnosticsNode> getChildren() => <DiagnosticsNode>[];
}

/// [DiagnosticsNode] for an instance of [Diagnosticable].
class _DiagnosticableNode<T extends Diagnosticable> extends DiagnosticsNode {
  _DiagnosticableNode({
    String name,
    @required this.value,
    @required DiagnosticsTreeStyle style,
    String emptyBodyDescription,
  }) : super(
         name: name,
         style: style,
       );

  @override
  final T value;

  DiagnosticPropertiesBuilder _cachedBuilder;

  DiagnosticPropertiesBuilder get _builder {
    if (_cachedBuilder == null) {
      _cachedBuilder = new DiagnosticPropertiesBuilder();
      value?.debugFillProperties(_cachedBuilder);
    }
    return _cachedBuilder;
  }

  @override DiagnosticsTreeStyle get style {
    return super.style ?? _builder.defaultDiagnosticsTreeStyle;
  }

  @override
  String get emptyBodyDescription => _builder.emptyBodyDescription;

  @override
  List<DiagnosticsNode> getProperties() => _builder.properties;

  @override
  List<DiagnosticsNode> getChildren() {
    return const<DiagnosticsNode>[];
  }

  @override
  String toDescription({ TextTreeConfiguration parentConfiguration }) {
    return value.toStringShort();
  }

  @override bool get hidden => false;
}

/// [DiagnosticsNode] for an instance of [DiagnosticableTree].
class _DiagnosticableTreeNode extends _DiagnosticableNode<DiagnosticableTree> {
  _DiagnosticableTreeNode({
    String name,
    @required DiagnosticableTree value,
    @required DiagnosticsTreeStyle style,
  }) : super(
         name: name,
         value: value,
         style: style,
       );

  @override
  List<DiagnosticsNode> getChildren() {
    if (value != null)
      return value.debugDescribeChildren();
    return const <DiagnosticsNode>[];
  }
}

/// Returns a 5 character long hexadecimal string generated from
/// [Object.hashCode]'s 20 least-significant bits.
String shortHash(Object object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

/// Returns a summary of the runtime type and hash code of `object`.
///
/// See also:
///
///  * [Object.hashCode], a value used when placing an object in a [Map] or
///    other similar data structure, and which is also used in debug output to
///    distinguish instances of the same class (hash collisions are
///    possible, but rare enough that its use in debug output is useful).
///  * [Object.runtimeType], the [Type] of an object.
String describeIdentity(Object object) => '${object.runtimeType}#${shortHash(object)}';

// This method exists as a workaround for https://github.com/dart-lang/sdk/issues/30021
/// Returns a short description of an enum value.
///
/// Strips off the enum class name from the `enumEntry.toString()`.
///
/// ## Sample code
///
/// ```dart
/// enum Day {
///   monday, tuesday, wednesday, thursday, friday, saturday, sunday
/// }
///
/// validateDescribeEnum() {
///   assert(Day.monday.toString() == 'Day.monday');
///   assert(describeEnum(Day.monday) == 'monday');
/// }
/// ```
String describeEnum(Object enumEntry) {
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}

/// Returns a lowercase hyphen-separated version of a camel case name.
///
/// ## Sample code
///
/// ```dart
/// validateCamelCaseToHyphenatedName() {
///   assert(camelCaseToHyphenatedName('deferToChild') == 'defer-to-child');
///   assert(camelCaseToHyphenatedName('Monday') == 'monday');
///   assert(camelCaseToHyphenatedName('monday') == 'monday');
/// }
/// ```
String camelCaseToHyphenatedName(String word) {
  final String lowerWord = word.toLowerCase();
  if (word == lowerWord)
    return word;

  final StringBuffer buffer = new StringBuffer();
  for (int i = 0; i < word.length; i++) {
    final String lower = lowerWord[i];
    if (word[i] != lower && i > 0)
      buffer.write('-');
    buffer.write(lower);
  }
  return buffer.toString();
}

/// Builder to accumulate properties and configuration used to assemble a
/// [DiagnosticsNode] from a [Diagnosticable] object.
class DiagnosticPropertiesBuilder {
  /// Add a property to the list of properties.
  void add(DiagnosticsNode property) {
    properties.add(property);
  }

  /// List of properties accumulated so far.
  final List<DiagnosticsNode> properties = <DiagnosticsNode>[];

  /// Default style to use for the [DiagnosticsNode] if no style is specified.
  DiagnosticsTreeStyle defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.sparse;

  /// Description to show if the node has no displayed properties or children.
  String emptyBodyDescription;
}

// Examples can assume:
// class ExampleSuperclass extends Diagnosticable { String message; double stepWidth; double scale; double paintExtent; double hitTestExtent; double paintExtend; double maxWidth; bool primary; double progress; int maxLines; Duration duration; int depth; dynamic boxShadow; dynamic style; bool hasSize; Matrix4 transform; Map<Listenable, VoidCallback> handles; Color color; bool obscureText; ImageRepeat repeat; Size size; Widget widget; bool isCurrent; bool keepAlive; TextAlign textAlign; }

/// A base class for providing string and [DiagnosticsNode] debug
/// representations describing the properties of an object.
///
/// The string debug representation is generated from the intermediate
/// [DiagnosticsNode] representation. The [DiagnosticsNode] representation is
/// also used by debugging tools displaying interactive trees of objects and
/// properties.
///
/// See also:
///
///  * [DiagnosticableTree], which extends this class to also describe the
///    children of a tree structured object.
///  * [Diagnosticable.debugFillProperties], which lists best practices
///    for specifying the properties of a [DiagnosticNode]. The most common use
///    case is to override [debugFillProperties] defining custom properties for
///    a subclass of [TreeDiagnosticsMixin] using the existing
///    [DiagnosticsProperty] subclasses.
///  * [DiagnosticableTree.debugDescribeChildren], which lists best practices
///    for describing the children of a [DiagnosticNode]. Typically the base
///    class already describes the children of a node properly or a node has
///    no children.
///  * [DiagnosticsProperty], which should be used to create leaf diagnostic
///    nodes without properties or children. There are many [DiagnosticProperty]
///    subclasses to handle common use cases.
abstract class Diagnosticable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Diagnosticable();

  /// A brief description of this object, usually just the [runtimeType] and the
  /// [hashCode].
  ///
  /// See also:
  ///
  ///  * [toString], for a detailed description of the object.
  String toStringShort() => describeIdentity(this);

  @override String toString() {
    return toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString();
  }

  /// Returns a debug representation of the object that is used by debugging
  /// tools and by [toStringDeep].
  ///
  /// Leave [name] as `null` if there is not a meaningful description of the
  /// relationship between the this node and its parent.
  ///
  /// Typically the [style] argument is only specified to indicate an atypical
  /// relationship between the parent and the node. For example, pass
  /// [DiagnosticsTreeStyle.offstage] to indicate that a node is offstage.
  DiagnosticsNode toDiagnosticsNode({ String name, DiagnosticsTreeStyle style }) {
    return new _DiagnosticableNode<Diagnosticable>(
      name: name,
      value: this,
      style: style,
    );
  }

  /// Add additional properties associated with the node.
  ///
  /// Use the most specific [DiagnosticsProperty] existing subclass to describe
  /// each property instead of the [DiagnosticsProperty] base class. There are
  /// only a small number of [DiagnosticsProperty] subclasses each covering a
  /// common use case. Consider what values a property is relevant for users
  /// debugging as users debugging large trees are overloaded with information.
  /// Common named parameters in [DiagnosticsNode] subclasses help filter when
  /// and how properties are displayed.
  ///
  /// `defaultValue`, `showName`, `showSeparator`, and `hidden` keep string
  /// representations of diagnostics terse and hide properties when they are not
  /// very useful.
  ///
  ///  * Use `defaultValue` any time the default value of a property is
  ///    uninteresting. For example, specify a default value of null any time
  ///    a property being null does not indicate an error.
  ///  * Avoid specifying the `hidden` parameter unless the result you want
  ///    cannot be be achieved by using the `defaultValue` parameter or using
  ///    the [ObjectFlagProperty] class to conditionally display the property
  ///    as a flag.
  ///  * Specify `showName` and `showSeparator` in rare cases where the string
  ///    output would look clumsy if they were not set.
  ///    ```dart
  ///    new DiagnosticsProperty<Object>('child(3, 4)', null, ifNull: 'is null', showSeparator: false).toString()
  ///    ```
  ///    Shows using `showSeparator` to get output `child(3, 4) is null` which
  ///    is more polished than `child(3, 4): is null`.
  ///    ```dart
  ///    new DiagnosticsProperty<IconData>('icon', icon, ifNull: '<empty>', showName: false)).toString()
  ///    ```
  ///    Shows using `showName` to omit the property name as in this context the
  ///    property name does not add useful information.
  ///
  /// `ifNull`, `ifEmpty`, `unit`, and `tooltip` make property
  /// descriptions clearer. The examples in the code sample below illustrate
  /// good uses of all of these parameters.
  ///
  /// ## DiagnosticsProperty subclasses for primitive types
  ///
  ///  * [StringProperty], which supports automatically enclosing a [String]
  ///    value in quotes.
  ///  * [DoubleProperty], which supports specifying a unit of measurement for
  ///    a [double] value.
  ///  * [PercentProperty], which clamps a [double] to between 0 and 1 and
  ///    formats it as a percentage.
  ///  * [IntProperty], which supports specifying a unit of measurement for an
  ///    [int] value.
  ///  * [FlagProperty], which formats a [bool] value as one or more flags.
  ///    Depending on the use case it is better to format a bool as
  ///    `DiagnosticsProperty<bool>` instead of using [FlagProperty] as the
  ///    output is more verbose but unambiguous.
  ///
  /// ## Other important [DiagnosticsProperty] variants
  ///
  ///  * [EnumProperty], which provides terse descriptions of enum values
  ///    working around limitations of the `toString` implementation for Dart
  ///    enum types.
  ///  * [IterableProperty], which handles iterable values with display
  ///    customizable depending on the [DiagnosticsTreeStyle] used.
  ///  * [ObjectFlagProperty], which provides terse descriptions of whether a
  ///    property value is present or not. For example, whether an `onClick`
  ///    callback is specified or an animation is in progress.
  ///
  /// If none of these subclasses apply, use the [DiagnosticsProperty]
  /// constructor or in rare cases create your own [DiagnosticsProperty]
  /// subclass as in the case for [TransformProperty] which handles [Matrix4]
  /// that represent transforms. Generally any property value with a good
  /// `toString` method implementation works fine using [DiagnosticsProperty]
  /// directly.
  ///
  /// ## Sample code
  ///
  /// This example shows best practices for implementing [debugFillProperties]
  /// illustrating use of all common [DiagnosticsProperty] subclasses and all
  /// common [DiagnosticsProperty] parameters.
  ///
  /// ```dart
  /// class ExampleObject extends ExampleSuperclass  {
  ///
  ///   // ...various members and properties...
  ///
  ///   @override
  ///   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  ///     // Always add properties from the base class first.
  ///     super.debugFillProperties(properties);
  ///
  ///     // Omit the property name 'message' when displaying this String property
  ///     // as it would just add visual noise.
  ///     properties.add(new StringProperty('message', message, showName: false));
  ///
  ///     properties.add(new DoubleProperty('stepWidth', stepWidth));
  ///
  ///     // A scale of 1.0 does nothing so should be hidden.
  ///     properties.add(new DoubleProperty('scale', scale, defaultValue: 1.0));
  ///
  ///     // If the hitTestExtent matches the paintExtent, it is just set to its
  ///     // default value so is not relevant.
  ///     properties.add(new DoubleProperty('hitTestExtent', hitTestExtent, defaultValue: paintExtent));
  ///
  ///     // maxWidth of double.INFINITY indicates the width is unconstrained and
  ///     // so maxWidth has no impact.,
  ///     properties.add(new DoubleProperty('maxWidth', maxWidth, defaultValue: double.INFINITY));
  ///
  ///     // Progress is a value between 0 and 1 or null. Showing it as a
  ///     // percentage makes the meaning clear enough that the name can be
  ///     // hidden.
  ///     properties.add(new PercentProperty(
  ///       'progress',
  ///       progress,
  ///       showName: false,
  ///       ifNull: '<indeterminate>',
  ///     ));
  ///
  ///     // Most text fields have maxLines set to 1.
  ///     properties.add(new IntProperty('maxLines', maxLines, defaultValue: 1));
  ///
  ///     // Specify the unit as otherwise it would be unclear that time is in
  ///     // milliseconds.
  ///     properties.add(new IntProperty('duration', duration.inMilliseconds, unit: 'ms'));
  ///
  ///     // Tooltip is used instead of unit for this case as a unit should be a
  ///     // terse description appropriate to display directly after a number
  ///     // without a space.
  ///     properties.add(new DoubleProperty(
  ///       'device pixel ratio',
  ///       ui.window.devicePixelRatio,
  ///       tooltip: 'physical pixels per logical pixel',
  ///     ));
  ///
  ///     // Displaying the depth value would be distracting. Instead only display
  ///     // if the depth value is missing.
  ///     properties.add(new ObjectFlagProperty<int>('depth', depth, ifNull: 'no depth'));
  ///
  ///     // bool flag that is only shown when the value is true.
  ///     properties.add(new FlagProperty('using primary controller', value: primary));
  ///
  ///     properties.add(new FlagProperty(
  ///       'isCurrent',
  ///       value: isCurrent,
  ///       ifTrue: 'active',
  ///       ifFalse: 'inactive',
  ///       showName: false,
  ///     ));
  ///
  ///     properties.add(new DiagnosticsProperty<bool>('keepAlive', keepAlive));
  ///
  ///     // FlagProperty could have also been used in this case.
  ///     // This option results in the text "obscureText: true" instead
  ///     // of "obscureText" which is a bit more verbose but a bit clearer.
  ///     properties.add(new DiagnosticsProperty<bool>('obscureText', obscureText, defaultValue: false));
  ///
  ///     properties.add(new EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null));
  ///     properties.add(new EnumProperty<ImageRepeat>('repeat', repeat, defaultValue: ImageRepeat.noRepeat));
  ///
  ///     // Warn users when the widget is missing but do not show the value.
  ///     properties.add(new ObjectFlagProperty<Widget>('widget', widget, ifNull: 'no widget'));
  ///
  ///     properties.add(new IterableProperty<BoxShadow>(
  ///       'boxShadow',
  ///       boxShadow,
  ///       defaultValue: null,
  ///       style: style,
  ///     ));
  ///
  ///     // Getting the value of size throws an exception unless hasSize is true.
  ///     properties.add(new DiagnosticsProperty<Size>.lazy(
  ///       'size',
  ///       () => size,
  ///       description: '${ hasSize ? size : "MISSING" }',
  ///     ));
  ///
  ///     // If the `toString` method for the property value does not provide a
  ///     // good terse description, write a DiagnosticsProperty subclass as in
  ///     // the case of TransformProperty which displays a nice debugging view
  ///     // of a Matrix4 that represents a transform.
  ///     properties.add(new TransformProperty('transform', transform));
  ///
  ///     // If the value class has a good `toString` method, use
  ///     // DiagnosticsProperty<YourValueType>. Specifying the value type ensures
  ///     // that debugging tools always know the type of the field and so can
  ///     // provide the right UI affordances. For example, in this case even
  ///     // if color is null, a debugging tool still knows the value is a Color
  ///     // and can display relevant color related UI.
  ///     properties.add(new DiagnosticsProperty<Color>('color', color));
  ///
  ///     // Use a custom description to generate a more terse summary than the
  ///     // `toString` method on the map class.
  ///     properties.add(new DiagnosticsProperty<Map<Listenable, VoidCallback>>(
  ///       'handles',
  ///       handles,
  ///       description: handles != null ?
  ///       '${handles.length} active client${ handles.length == 1 ? "" : "s" }' :
  ///       null,
  ///       ifNull: 'no notifications ever received',
  ///       showName: false,
  ///     ));
  ///   }
  /// }
  /// ```
  ///
  /// Used by [toDiagnosticsNode] and [toString].
  @protected
  @mustCallSuper
  void debugFillProperties(DiagnosticPropertiesBuilder properties) { }
}

/// A base class for providing string and [DiagnosticsNode] debug
/// representations describing the properties and children of an object.
///
/// The string debug representation is generated from the intermediate
/// [DiagnosticsNode] representation. The [DiagnosticsNode] representation is
/// also used by debugging tools displaying interactive trees of objects and
/// properties.
///
/// See also:
///
///  * [DiagnosticableTreeMixin], which provides a mixin that implements this
///    class.
///  * [Diagnosticable], which should be used instead of this class to provide
///    diagnostics for objects without children.
abstract class DiagnosticableTree extends Diagnosticable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const DiagnosticableTree();

  /// Returns a one-line detailed description of the object.
  ///
  /// This description is often somewhat long. This includes the same
  /// information given by [toStringDeep], but does not recurse to any children.
  ///
  /// The [toStringShallow] method can take an argument, which is the string to
  /// place between each part obtained from [debugFillProperties]. Passing a
  /// string such as `'\n '` will result in a multiline string that indents the
  /// properties of the object below its name (as per [toString]).
  ///
  /// See also:
  ///
  ///  * [toString], for a brief description of the object.
  ///  * [toStringDeep], for a description of the subtree rooted at this object.
  String toStringShallow([String joiner = ', ']) {
    final StringBuffer result = new StringBuffer();
    result.write(toString());
    result.write(joiner);
    final DiagnosticPropertiesBuilder builder = new DiagnosticPropertiesBuilder();
    debugFillProperties(builder);
    result.write(
      builder.properties.where((DiagnosticsNode n) => !n.hidden).join(joiner),
    );
    return result.toString();
  }

  /// Returns a string representation of this node and its descendants.
  ///
  /// The [toStringDeep] method takes arguments, but those are intended for
  /// internal use when recursing to the descendants, and so can be ignored.
  ///
  /// See also:
  ///
  ///  * [toString], for a brief description of the object but not its children.
  ///  * [toStringShallow], for a detailed description of the object but not its
  ///    children.
  String toStringDeep([String prefixLineOne = '', String prefixOtherLines]) {
    return toDiagnosticsNode().toStringDeep(prefixLineOne, prefixOtherLines);
  }

  @override
  String toStringShort() => describeIdentity(this);

  @override
  DiagnosticsNode toDiagnosticsNode({ String name, DiagnosticsTreeStyle style }) {
    return new _DiagnosticableTreeNode(
      name: name,
      value: this,
      style: style,
    );
  }

  /// Returns a list of [DiagnosticsNode] objects describing this node's
  /// children.
  ///
  /// Children that are offstage should be added with `style` set to
  /// [DiagnosticsTreeStyle.offstage] to indicate that they are offstage.
  ///
  /// The list must not contain any null entries. If there are explicit null
  /// children to report, consider [new DiagnosticsNode.message] or
  /// [DiagnosticsProperty<Object>] as possible [DiagnosticsNode] objects to
  /// provide.
  ///
  /// See also:
  ///
  ///  * [RenderTable.debugDescribeChildren], which provides high quality custom
  ///    descriptions for its child nodes.
  ///
  /// Used by [toStringDeep], [toDiagnosticsNode] and [toStringShallow].
  @protected
  List<DiagnosticsNode> debugDescribeChildren() => const <DiagnosticsNode>[];
}

/// A class that can be used as a mixin that helps dump string and
/// [DiagnosticsNode] representations of trees.
///
/// This class is identical to DiagnosticableTree except that it can be used as
/// a mixin.
abstract class DiagnosticableTreeMixin implements DiagnosticableTree {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory DiagnosticableTreeMixin._() => null;

  @override
  String toString() {
    return toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString();
  }

  @override
  String toStringShallow([String joiner = ', ']) {
    final StringBuffer result = new StringBuffer();
    result.write(toStringShort());
    result.write(joiner);
    final DiagnosticPropertiesBuilder builder = new DiagnosticPropertiesBuilder();
    debugFillProperties(builder);
    result.write(
      builder.properties.where((DiagnosticsNode n) => !n.hidden).join(joiner),
    );
    return result.toString();
  }

  @override
  String toStringDeep([String prefixLineOne = '', String prefixOtherLines]) {
    return toDiagnosticsNode().toStringDeep(prefixLineOne, prefixOtherLines);
  }

  @override
  String toStringShort() => describeIdentity(this);

  @override
  DiagnosticsNode toDiagnosticsNode({ String name, DiagnosticsTreeStyle style }) {
    return new _DiagnosticableTreeNode(
      name: name,
      value: this,
      style: style,
    );
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() => const <DiagnosticsNode>[];

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) { }
}
