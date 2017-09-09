// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Rect, SemanticsAction, SemanticsFlags;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

import 'debug.dart';
import 'node.dart';
import 'semantics_event.dart';

export 'dart:ui' show SemanticsAction;
export 'semantics_event.dart';

/// Interface for [RenderObject]s to implement when they want to support
/// being tapped, etc.
///
/// The handler will only be called for a particular flag if that flag is set
/// (e.g. [performAction] will only be called with [SemanticsAction.tap] if
/// [SemanticsNode.addAction] was called for [SemanticsAction.tap].)
abstract class SemanticsActionHandler { // ignore: one_member_abstracts
  /// Called when the object implementing this interface receives a
  /// [SemanticsAction]. For example, if the user of an accessibility tool
  /// instructs their device that they wish to tap a button, the [RenderObject]
  /// behind that button would have its [performAction] method called with the
  /// [SemanticsAction.tap] action.
  void performAction(SemanticsAction action);
}

/// Signature for functions returned by [RenderObject.semanticsAnnotator].
///
/// These callbacks are called with the [SemanticsNode] object that
/// corresponds to the [RenderObject]. (One [SemanticsNode] can
/// correspond to multiple [RenderObject] objects.)
///
/// See [RenderObject.semanticsAnnotator] for details on the
/// contract that semantic annotators must follow.
typedef void SemanticsAnnotator(SemanticsNode semantics);

/// Signature for a function that is called for each [SemanticsNode].
///
/// Return false to stop visiting nodes.
///
/// Used by [SemanticsNode.visitChildren].
typedef bool SemanticsNodeVisitor(SemanticsNode node);

/// A tag for a [SemanticsNode].
///
/// Tags can be interpreted by the parent of a [SemanticsNode]
/// and depending on the presence of a tag the parent can for example decide
/// how to add the tagged note as a child. Tags are not sent to the engine.
///
/// As an example, the [RenderSemanticsGestureHandler] uses tags to determine
/// if a child node should be excluded from the scrollable area for semantic
/// purposes.
///
/// The provided [name] is only used for debugging. Two tags created with the
/// same [name] and the `new` operator are not considered identical. However,
/// two tags created with the same [name] and the `const` operator are always
/// identical.
class SemanticsTag {
  /// Creates a [SemanticsTag].
  ///
  /// The provided [name] is only used for debugging. Two tags created with the
  /// same [name] and the `new` operator are not considered identical. However,
  /// two tags created with the same [name] and the `const` operator are always
  /// identical.
  const SemanticsTag(this.name);

  /// A human-readable name for this tag used for debugging.
  ///
  /// This string is not used to determine if two tags are identical.
  final String name;

  @override
  String toString() => '$runtimeType($name)';
}

/// Summary information about a [SemanticsNode] object.
///
/// A semantics node might [SemanticsNode.mergeAllDescendantsIntoThisNode],
/// which means the individual fields on the semantics node don't fully describe
/// the semantics at that node. This data structure contains the full semantics
/// for the node.
///
/// Typically obtained from [SemanticsNode.getSemanticsData].
@immutable
class SemanticsData {
  /// Creates a semantics data object.
  ///
  /// The [flags], [actions], [label], and [Rect] arguments must not be null.
  ///
  /// If [label] is not empty, then [textDirection] must also not be null.
  const SemanticsData({
    @required this.flags,
    @required this.actions,
    @required this.label,
    @required this.textDirection,
    @required this.rect,
    @required this.tags,
    this.transform,
  }) : assert(flags != null),
       assert(actions != null),
       assert(label != null),
       assert(label == '' || textDirection != null, 'A SemanticsData object with label "$label" had a null textDirection.'),
       assert(rect != null),
       assert(tags != null);

  /// A bit field of [SemanticsFlags] that apply to this node.
  final int flags;

  /// A bit field of [SemanticsAction]s that apply to this node.
  final int actions;

  /// A textual description of this node.
  ///
  /// The text's reading direction is given by [textDirection].
  final String label;

  /// The reading direction for the text in [label].
  final TextDirection textDirection;

  /// The bounding box for this node in its coordinate system.
  final Rect rect;

  /// The set of [SemanticsTag]s associated with this node.
  final Set<SemanticsTag> tags;

  /// The transform from this node's coordinate system to its parent's coordinate system.
  ///
  /// By default, the transform is null, which represents the identity
  /// transformation (i.e., that this node has the same coorinate system as its
  /// parent).
  final Matrix4 transform;

  /// Whether [flags] contains the given flag.
  bool hasFlag(SemanticsFlags flag) => (flags & flag.index) != 0;

  /// Whether [actions] contains the given action.
  bool hasAction(SemanticsAction action) => (actions & action.index) != 0;

  @override
  String toString() {
    final StringBuffer buffer = new StringBuffer();
    buffer.write('$runtimeType($rect');
    if (transform != null)
      buffer.write('; $transform');
    for (SemanticsAction action in SemanticsAction.values.values) {
      if ((actions & action.index) != 0)
        buffer.write('; $action');
    }
    for (SemanticsFlags flag in SemanticsFlags.values.values) {
      if ((flags & flag.index) != 0)
        buffer.write('; $flag');
    }
    if (label.isNotEmpty)
      buffer.write('; "$label"');
    if (textDirection != null)
      buffer.write('; $textDirection');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! SemanticsData)
      return false;
    final SemanticsData typedOther = other;
    return typedOther.flags == flags
        && typedOther.actions == actions
        && typedOther.label == label
        && typedOther.textDirection == textDirection
        && typedOther.rect == rect
        && setEquals(typedOther.tags, tags)
        && typedOther.transform == transform;
  }

  @override
  int get hashCode => hashValues(flags, actions, label, textDirection, rect, tags, transform);
}

/// A node that represents some semantic data.
///
/// The semantics tree is maintained during the semantics phase of the pipeline
/// (i.e., during [PipelineOwner.flushSemantics]), which happens after
/// compositing. The semantics tree is then uploaded into the engine for use
/// by assistive technology.
class SemanticsNode extends AbstractNode {
  /// Creates a semantic node.
  ///
  /// Each semantic node has a unique identifier that is assigned when the node
  /// is created.
  SemanticsNode({
    SemanticsActionHandler handler,
    VoidCallback showOnScreen,
  }) : id = _generateNewId(),
       _showOnScreen = showOnScreen,
       _actionHandler = handler;

  /// Creates a semantic node to represent the root of the semantics tree.
  ///
  /// The root node is assigned an identifier of zero.
  SemanticsNode.root({
    SemanticsActionHandler handler,
    VoidCallback showOnScreen,
    SemanticsOwner owner,
  }) : id = 0,
        _showOnScreen = showOnScreen,
       _actionHandler = handler {
    attach(owner);
  }

  static int _lastIdentifier = 0;
  static int _generateNewId() {
    _lastIdentifier += 1;
    return _lastIdentifier;
  }

  /// The unique identifier for this node.
  ///
  /// The root node has an id of zero. Other nodes are given a unique id when
  /// they are created.
  final int id;

  final SemanticsActionHandler _actionHandler;
  final VoidCallback _showOnScreen;

  // GEOMETRY
  // These are automatically handled by RenderObject's own logic

  /// The transform from this node's coordinate system to its parent's coordinate system.
  ///
  /// By default, the transform is null, which represents the identity
  /// transformation (i.e., that this node has the same coorinate system as its
  /// parent).
  Matrix4 get transform => _transform;
  Matrix4 _transform;
  set transform(Matrix4 value) {
    if (!MatrixUtils.matrixEquals(_transform, value)) {
      _transform = MatrixUtils.isIdentity(value) ? null : value;
      _markDirty();
    }
  }

  /// The bounding box for this node in its coordinate system.
  Rect get rect => _rect;
  Rect _rect = Rect.zero;
  set rect(Rect value) {
    assert(value != null);
    if (_rect != value) {
      _rect = value;
      _markDirty();
    }
  }

  /// Whether [rect] might have been influenced by clips applied by ancestors.
  bool wasAffectedByClip = false;


  // FLAGS AND LABELS
  // These are supposed to be set by SemanticsAnnotator obtained from getSemanticsAnnotators

  int _actions = 0;

  /// Adds the given action to the set of semantic actions.
  ///
  /// If the user chooses to perform an action,
  /// [SemanticsActionHandler.performAction] will be called with the chosen
  /// action.
  void addAction(SemanticsAction action) {
    assert(action != null);
    final int index = action.index;
    if ((_actions & index) == 0) {
      _actions |= index;
      _markDirty();
    }
  }

  /// Adds the [SemanticsAction.scrollLeft] and [SemanticsAction.scrollRight] actions.
  void addHorizontalScrollingActions() {
    addAction(SemanticsAction.scrollLeft);
    addAction(SemanticsAction.scrollRight);
  }

  /// Adds the [SemanticsAction.scrollUp] and [SemanticsAction.scrollDown] actions.
  void addVerticalScrollingActions() {
    addAction(SemanticsAction.scrollUp);
    addAction(SemanticsAction.scrollDown);
  }

  /// Adds the [SemanticsAction.increase] and [SemanticsAction.decrease] actions.
  void addAdjustmentActions() {
    addAction(SemanticsAction.increase);
    addAction(SemanticsAction.decrease);
  }

  bool _canPerformAction(SemanticsAction action) {
    return _actionHandler != null && (_actions & action.index) != 0;
  }

  /// Whether all this node and all of its descendants should be treated as one logical entity.
  bool get mergeAllDescendantsIntoThisNode => _mergeAllDescendantsIntoThisNode;
  bool _mergeAllDescendantsIntoThisNode = false;
  set mergeAllDescendantsIntoThisNode(bool value) {
    assert(value != null);
    if (_mergeAllDescendantsIntoThisNode == value)
      return;
    _mergeAllDescendantsIntoThisNode = value;
    _markDirty();
  }

  bool get _inheritedMergeAllDescendantsIntoThisNode => _inheritedMergeAllDescendantsIntoThisNodeValue;
  bool _inheritedMergeAllDescendantsIntoThisNodeValue = false;
  set _inheritedMergeAllDescendantsIntoThisNode(bool value) {
    assert(value != null);
    if (_inheritedMergeAllDescendantsIntoThisNodeValue == value)
      return;
    _inheritedMergeAllDescendantsIntoThisNodeValue = value;
    _markDirty();
  }

  bool get _shouldMergeAllDescendantsIntoThisNode => mergeAllDescendantsIntoThisNode || _inheritedMergeAllDescendantsIntoThisNode;

  int _flags = 0;
  void _setFlag(SemanticsFlags flag, bool value) {
    final int index = flag.index;
    if (value) {
      if ((_flags & index) == 0) {
        _flags |= index;
        _markDirty();
      }
    } else {
      if ((_flags & index) != 0) {
        _flags &= ~index;
        _markDirty();
      }
    }
  }

  /// Whether this node has Boolean state that can be controlled by the user.
  bool get hasCheckedState => (_flags & SemanticsFlags.hasCheckedState.index) != 0;
  set hasCheckedState(bool value) => _setFlag(SemanticsFlags.hasCheckedState, value);

  /// If this node has Boolean state that can be controlled by the user, whether
  /// that state is on or off, corresponding to true and false, respectively.
  bool get isChecked => (_flags & SemanticsFlags.isChecked.index) != 0;
  set isChecked(bool value) => _setFlag(SemanticsFlags.isChecked, value);

  /// Whether the current node is selected (true) or not (false).
  bool get isSelected => (_flags & SemanticsFlags.isSelected.index) != 0;
  set isSelected(bool value) => _setFlag(SemanticsFlags.isSelected, value);

  /// A textual description of this node.
  ///
  /// The text's reading direction is given by [textDirection].
  String get label => _label;
  String _label = '';
  set label(String value) {
    assert(value != null);
    if (_label != value) {
      _label = value;
      _markDirty();
    }
  }

  /// The reading direction for the text in [label].
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textDirection != value) {
      _textDirection = value;
      _markDirty();
    }
  }

  final Set<SemanticsTag> _tags = new Set<SemanticsTag>();

  /// Tags the [SemanticsNode] with [tag].
  ///
  /// Tags are not sent to the engine. They can be used by a parent
  /// [SemanticsNode] to figure out how to add the node as a child.
  ///
  /// See also:
  ///
  ///  * [SemanticsTag], whose documentation discusses the purposes of tags.
  ///  * [hasTag] to check if the node has a certain tag.
  void addTag(SemanticsTag tag) {
    assert(tag != null);
    _tags.add(tag);
  }

  /// Check if the [SemanticsNode] is tagged with [tag].
  ///
  /// Tags can be added and removed with [ensureTag].
  ///
  /// See also:
  ///
  ///  * [SemanticsTag], whose documentation discusses the purposes of tags.
  bool hasTag(SemanticsTag tag) => _tags.contains(tag);

  /// Restore this node to its default state.
  void reset() {
    final bool hadInheritedMergeAllDescendantsIntoThisNode = _inheritedMergeAllDescendantsIntoThisNode;
    _actions = 0;
    _flags = 0;
    if (hadInheritedMergeAllDescendantsIntoThisNode)
      _inheritedMergeAllDescendantsIntoThisNodeValue = true;
    _label = '';
    _textDirection = null;
    _tags.clear();
    _markDirty();
  }

  List<SemanticsNode> _newChildren;

  /// Append the given children as children of this node.
  ///
  /// Children must be added in inverse hit test order (i.e. paint order).
  ///
  /// The [finalizeChildren] method must be called after all children have been
  /// added.
  void addChildren(Iterable<SemanticsNode> childrenInInverseHitTestOrder) {
    _newChildren ??= <SemanticsNode>[];
    _newChildren.addAll(childrenInInverseHitTestOrder);
    // we do the asserts afterwards because children is an Iterable
    // and doing the asserts before would mean the behavior is
    // different in checked mode vs release mode (if you walk an
    // iterator after having reached the end, it'll just start over;
    // the values are not cached).
    assert(!_newChildren.any((SemanticsNode child) => child == this));
    assert(() {
      SemanticsNode ancestor = this;
      while (ancestor.parent is SemanticsNode)
        ancestor = ancestor.parent;
      assert(!_newChildren.any((SemanticsNode child) => child == ancestor));
      return true;
    });
    assert(() {
      final Set<SemanticsNode> seenChildren = new Set<SemanticsNode>();
      for (SemanticsNode child in _newChildren)
        assert(seenChildren.add(child)); // check for duplicate adds
      return true;
    });
  }

  /// Contains the children in inverse hit test order (i.e. paint order).
  List<SemanticsNode> _children;

  /// Whether this node has a non-zero number of children.
  bool get hasChildren => _children?.isNotEmpty ?? false;
  bool _dead = false;

  /// The number of children this node has.
  int get childrenCount => hasChildren ? _children.length : 0;

  /// Visits the immediate children of this node.
  ///
  /// This function calls visitor for each child in a pre-order travseral
  /// until visitor returns false. Returns true if all the visitor calls
  /// returned true, otherwise returns false.
  void visitChildren(SemanticsNodeVisitor visitor) {
    if (_children != null) {
      for (SemanticsNode child in _children) {
        if (!visitor(child))
          return;
      }
    }
  }

  /// Called during the compilation phase after all the children of this node have been compiled.
  ///
  /// This function lets the semantic node respond to all the changes to its
  /// child list for the given frame at once instead of needing to process the
  /// changes incrementally as new children are compiled.
  void finalizeChildren() {
    // The goal of this function is updating sawChange.
    if (_children != null) {
      for (SemanticsNode child in _children)
        child._dead = true;
    }
    if (_newChildren != null) {
      for (SemanticsNode child in _newChildren)
        child._dead = false;
    }
    bool sawChange = false;
    if (_children != null) {
      for (SemanticsNode child in _children) {
        if (child._dead) {
          if (child.parent == this) {
            // we might have already had our child stolen from us by
            // another node that is deeper in the tree.
            dropChild(child);
          }
          sawChange = true;
        }
      }
    }
    if (_newChildren != null) {
      for (SemanticsNode child in _newChildren) {
        if (child.parent != this) {
          if (child.parent != null) {
            // we're rebuilding the tree from the bottom up, so it's possible
            // that our child was, in the last pass, a child of one of our
            // ancestors. In that case, we drop the child eagerly here.
            // TODO(ianh): Find a way to assert that the same node didn't
            // actually appear in the tree in two places.
            child.parent?.dropChild(child);
          }
          assert(!child.attached);
          adoptChild(child);
          sawChange = true;
        }
      }
    }
    if (!sawChange && _children != null) {
      assert(_newChildren != null);
      assert(_newChildren.length == _children.length);
      // Did the order change?
      for (int i = 0; i < _children.length; i++) {
        if (_children[i].id != _newChildren[i].id) {
          sawChange = true;
          break;
        }
      }
    }
    final List<SemanticsNode> oldChildren = _children;
    _children = _newChildren;
    oldChildren?.clear();
    _newChildren = oldChildren;
    if (sawChange)
      _markDirty();
  }

  @override
  SemanticsOwner get owner => super.owner;

  @override
  SemanticsNode get parent => super.parent;

  @override
  void redepthChildren() {
    if (_children != null) {
      for (SemanticsNode child in _children)
        redepthChild(child);
    }
  }

  /// Visit all the descendants of this node.
  ///
  /// This function calls visitor for each descendant in a pre-order travseral
  /// until visitor returns false. Returns true if all the visitor calls
  /// returned true, otherwise returns false.
  bool _visitDescendants(SemanticsNodeVisitor visitor) {
    if (_children != null) {
      for (SemanticsNode child in _children) {
        if (!visitor(child) || !child._visitDescendants(visitor))
          return false;
      }
    }
    return true;
  }

  @override
  void attach(SemanticsOwner owner) {
    super.attach(owner);
    assert(!owner._nodes.containsKey(id));
    owner._nodes[id] = this;
    owner._detachedNodes.remove(this);
    if (_dirty) {
      _dirty = false;
      _markDirty();
    }
    if (parent != null)
      _inheritedMergeAllDescendantsIntoThisNode = parent._shouldMergeAllDescendantsIntoThisNode;
    if (_children != null) {
      for (SemanticsNode child in _children)
        child.attach(owner);
    }
  }

  @override
  void detach() {
    assert(owner._nodes.containsKey(id));
    assert(!owner._detachedNodes.contains(this));
    owner._nodes.remove(id);
    owner._detachedNodes.add(this);
    super.detach();
    assert(owner == null);
    if (_children != null) {
      for (SemanticsNode child in _children) {
        // The list of children may be stale and may contain nodes that have
        // been assigned to a different parent.
        if (child.parent == this)
          child.detach();
      }
    }
    // The other side will have forgotten this node if we ever send
    // it again, so make sure to mark it dirty so that it'll get
    // sent if it is resurrected.
    _markDirty();
  }

  bool _dirty = false;
  void _markDirty() {
    if (_dirty)
      return;
    _dirty = true;
    if (attached) {
      assert(!owner._detachedNodes.contains(this));
      owner._dirtyNodes.add(this);
    }
  }

  /// Returns a summary of the semantics for this node.
  ///
  /// If this node has [mergeAllDescendantsIntoThisNode], then the returned data
  /// includes the information from this node's descendants. Otherwise, the
  /// returned data matches the data on this node.
  SemanticsData getSemanticsData() {
    int flags = _flags;
    int actions = _actions;
    String label = _label;
    TextDirection textDirection = _textDirection;
    final Set<SemanticsTag> tags = new Set<SemanticsTag>.from(_tags);

    if (mergeAllDescendantsIntoThisNode) {
      _visitDescendants((SemanticsNode node) {
        flags |= node._flags;
        actions |= node._actions;
        textDirection ??= node._textDirection;
        tags.addAll(node._tags);
        if (node.label.isNotEmpty) {
          String nestedLabel = node.label;
          if (textDirection != node.textDirection && node.textDirection != null) {
            switch (node.textDirection) {
              case TextDirection.rtl:
                nestedLabel = '${Unicode.RLE}$nestedLabel${Unicode.PDF}';
                break;
              case TextDirection.ltr:
                nestedLabel = '${Unicode.LRE}$nestedLabel${Unicode.PDF}';
                break;
            }
          }
          if (label.isEmpty)
            label = nestedLabel;
          else
            label = '$label\n$nestedLabel';
        }
        return true;
      });
    }

    return new SemanticsData(
      flags: flags,
      actions: actions,
      label: label,
      textDirection: textDirection,
      rect: rect,
      transform: transform,
      tags: tags,
    );
  }

  static Float64List _initIdentityTransform() {
    return new Matrix4.identity().storage;
  }

  static final Int32List _kEmptyChildList = new Int32List(0);
  static final Float64List _kIdentityTransform = _initIdentityTransform();

  void _addToUpdate(ui.SemanticsUpdateBuilder builder) {
    assert(_dirty);
    final SemanticsData data = getSemanticsData();
    Int32List children;
    if (!hasChildren || mergeAllDescendantsIntoThisNode) {
      children = _kEmptyChildList;
    } else {
      final int childCount = _children.length;
      children = new Int32List(childCount);
      for (int i = 0; i < childCount; ++i)
        children[i] = _children[i].id;
    }
    builder.updateNode(
      id: id,
      flags: data.flags,
      actions: data.actions,
      rect: data.rect,
      label: data.label,
      textDirection: data.textDirection,
      transform: data.transform?.storage ?? _kIdentityTransform,
      children: children,
    );
    _dirty = false;
  }

  /// Sends a [SemanticsEvent] associated with this [SemanticsNode].
  ///
  /// Semantics events should be sent to inform interested parties (like
  /// the accessibility system of the operating system) about changes to the UI.
  ///
  /// For example, if this semantics node represents a scrollable list, a
  /// [ScrollCompletedSemanticsEvent] should be sent after a scroll action is completed.
  /// That way, the operating system can give additional feedback to the user
  /// about the state of the UI (e.g. on Android a ping sound is played to
  /// indicate a successful scroll in accessibility mode).
  void sendEvent(SemanticsEvent event) {
    if (!attached)
      return;
    final Map<String, dynamic> annotatedEvent = <String, dynamic>{
      'nodeId': id,
      'type': event.type,
      'data': event.toMap(),
    };
    SystemChannels.accessibility.send(annotatedEvent);
  }

  @override
  String toString() {
    final StringBuffer buffer = new StringBuffer();
    buffer.write('$runtimeType($id');
    if (_dirty)
      buffer.write(' (${ owner != null && owner._dirtyNodes.contains(this) ? "dirty" : "STALE; owner=$owner" })');
    if (_shouldMergeAllDescendantsIntoThisNode)
      buffer.write(' (leaf merge)');
    final Offset offset = transform != null ? MatrixUtils.getAsTranslation(transform) : null;
    if (offset != null) {
      buffer.write('; ${rect.shift(offset)}');
    } else {
      final double scale = transform != null ? MatrixUtils.getAsScale(transform) : null;
      if (scale != null) {
        buffer.write('; $rect scaled by ${scale.toStringAsFixed(1)}x');
      } else if (transform != null && !MatrixUtils.isIdentity(transform)) {
        final String matrix = transform.toString().split('\n').take(4).map((String line) => line.substring(4)).join('; ');
        buffer.write('; $rect with transform [$matrix]');
      } else {
        buffer.write('; $rect');
      }
    }
    if (wasAffectedByClip)
      buffer.write(' (clipped)');
    for (SemanticsAction action in SemanticsAction.values.values) {
      if ((_actions & action.index) != 0)
        buffer.write('; $action');
    }
    for (SemanticsTag tag in _tags)
      buffer.write('; $tag');
    if (hasCheckedState) {
      if (isChecked)
        buffer.write('; checked');
      else
        buffer.write('; unchecked');
    }
    if (isSelected)
      buffer.write('; selected');
    if (label.isNotEmpty)
      buffer.write('; "$label"');
    if (textDirection != null)
      buffer.write('; $textDirection');
    buffer.write(')');
    return buffer.toString();
  }

  /// Returns a string representation of this node and its descendants.
  ///
  /// The order in which the children of the [SemanticsNode] will be printed is
  /// controlled by the [childOrder] parameter.
  String toStringDeep(DebugSemanticsDumpOrder childOrder, [
    String prefixLineOne = '',
    String prefixOtherLines = ''
  ]) {
    assert(childOrder != null);
    final StringBuffer result = new StringBuffer()
      ..write(prefixLineOne)
      ..write(this)
      ..write('\n');
    if (_children != null && _children.isNotEmpty) {
      final List<SemanticsNode> childrenInOrder = _getChildrenInOrder(childOrder);
      for (int index = 0; index < childrenInOrder.length - 1; index += 1) {
        final SemanticsNode child = childrenInOrder[index];
        result.write(child.toStringDeep(childOrder, "$prefixOtherLines \u251C", "$prefixOtherLines \u2502"));
      }
      result.write(childrenInOrder.last.toStringDeep(childOrder, "$prefixOtherLines \u2514", "$prefixOtherLines  "));
    }
    return result.toString();
  }

  Iterable<SemanticsNode> _getChildrenInOrder(DebugSemanticsDumpOrder childOrder) {
    assert(childOrder != null);
    switch(childOrder) {
      case DebugSemanticsDumpOrder.traversal:
        return new List<SemanticsNode>.from(_children)..sort(_geometryComparator);
      case DebugSemanticsDumpOrder.inverseHitTest:
        return _children;
    }
    assert(false);
    return null;
  }

  static int _geometryComparator(SemanticsNode a, SemanticsNode b) {
    final Rect rectA = a.transform == null ? a.rect : MatrixUtils.transformRect(a.transform, a.rect);
    final Rect rectB = b.transform == null ? b.rect : MatrixUtils.transformRect(b.transform, b.rect);
    final int top = rectA.top.compareTo(rectB.top);
    return top == 0 ? rectA.left.compareTo(rectB.left) : top;
  }
}

/// Owns [SemanticsNode] objects and notifies listeners of changes to the
/// render tree semantics.
///
/// To listen for semantic updates, call [PipelineOwner.ensureSemantics] to
/// obtain a [SemanticsHandle]. This will create a [SemanticsOwner] if
/// necessary.
class SemanticsOwner extends ChangeNotifier {
  final Set<SemanticsNode> _dirtyNodes = new Set<SemanticsNode>();
  final Map<int, SemanticsNode> _nodes = <int, SemanticsNode>{};
  final Set<SemanticsNode> _detachedNodes = new Set<SemanticsNode>();

  /// The root node of the semantics tree, if any.
  ///
  /// If the semantics tree is empty, returns null.
  SemanticsNode get rootSemanticsNode => _nodes[0];

  @override
  void dispose() {
    _dirtyNodes.clear();
    _nodes.clear();
    _detachedNodes.clear();
    super.dispose();
  }

  /// Update the semantics using [Window.updateSemantics].
  void sendSemanticsUpdate() {
    if (_dirtyNodes.isEmpty)
      return;
    final List<SemanticsNode> visitedNodes = <SemanticsNode>[];
    while (_dirtyNodes.isNotEmpty) {
      final List<SemanticsNode> localDirtyNodes = _dirtyNodes.where((SemanticsNode node) => !_detachedNodes.contains(node)).toList();
      _dirtyNodes.clear();
      _detachedNodes.clear();
      localDirtyNodes.sort((SemanticsNode a, SemanticsNode b) => a.depth - b.depth);
      visitedNodes.addAll(localDirtyNodes);
      for (SemanticsNode node in localDirtyNodes) {
        assert(node._dirty);
        assert(node.parent == null || !node.parent._shouldMergeAllDescendantsIntoThisNode || node._inheritedMergeAllDescendantsIntoThisNode);
        if (node._shouldMergeAllDescendantsIntoThisNode) {
          assert(node.mergeAllDescendantsIntoThisNode || node.parent != null);
          if (node.mergeAllDescendantsIntoThisNode ||
              node.parent != null && node.parent._shouldMergeAllDescendantsIntoThisNode) {
            // if we're merged into our parent, make sure our parent is added to the list
            if (node.parent != null && node.parent._shouldMergeAllDescendantsIntoThisNode)
              node.parent._markDirty(); // this can add the node to the dirty list
            // make sure all the descendants are also marked, so that if one gets marked dirty later we know to walk up then too
            if (node._children != null) {
              for (SemanticsNode child in node._children)
                child._inheritedMergeAllDescendantsIntoThisNode = true; // this can add the node to the dirty list
            }
          } else {
            // we previously were being merged but aren't any more
            // update our bits and all our descendants'
            assert(node._inheritedMergeAllDescendantsIntoThisNode);
            assert(!node.mergeAllDescendantsIntoThisNode);
            assert(node.parent == null || !node.parent._shouldMergeAllDescendantsIntoThisNode);
            node._inheritedMergeAllDescendantsIntoThisNode = false;
            if (node._children != null) {
              for (SemanticsNode child in node._children)
                child._inheritedMergeAllDescendantsIntoThisNode = false; // this can add the node to the dirty list
            }
          }
        }
      }
    }
    visitedNodes.sort((SemanticsNode a, SemanticsNode b) => a.depth - b.depth);
    final ui.SemanticsUpdateBuilder builder = new ui.SemanticsUpdateBuilder();
    for (SemanticsNode node in visitedNodes) {
      assert(node.parent?._dirty != true); // could be null (no parent) or false (not dirty)
      // The _serialize() method marks the node as not dirty, and
      // recurses through the tree to do a deep serialization of all
      // contiguous dirty nodes. This means that when we return here,
      // it's quite possible that subsequent nodes are no longer
      // dirty. We skip these here.
      // We also skip any nodes that were reset and subsequently
      // dropped entirely (RenderObject.markNeedsSemanticsUpdate()
      // calls reset() on its SemanticsNode if onlyChanges isn't set,
      // which happens e.g. when the node is no longer contributing
      // semantics).
      if (node._dirty && node.attached)
        node._addToUpdate(builder);
    }
    _dirtyNodes.clear();
    ui.window.updateSemantics(builder.build());
    notifyListeners();
  }

  SemanticsActionHandler _getSemanticsActionHandlerForId(int id, SemanticsAction action) {
    SemanticsNode result = _nodes[id];
    if (result != null && result._shouldMergeAllDescendantsIntoThisNode && !result._canPerformAction(action)) {
      result._visitDescendants((SemanticsNode node) {
        if (node._canPerformAction(action)) {
          result = node;
          return false; // found node, abort walk
        }
        return true; // continue walk
      });
    }
    if (result == null || !result._canPerformAction(action))
      return null;
    return result._actionHandler;
  }

  /// Asks the [SemanticsNode] with the given id to perform the given action.
  ///
  /// If the [SemanticsNode] has not indicated that it can perform the action,
  /// this function does nothing.
  void performAction(int id, SemanticsAction action) {
    assert(action != null);
    final SemanticsActionHandler handler = _getSemanticsActionHandlerForId(id, action);
    if (handler != null) {
      handler.performAction(action);
      return;
    }

    // Default actions if no [handler] was provided.
    if (action == SemanticsAction.showOnScreen && _nodes[id]._showOnScreen != null)
      _nodes[id]._showOnScreen();
  }

  SemanticsActionHandler _getSemanticsActionHandlerForPosition(SemanticsNode node, Offset position, SemanticsAction action) {
    if (node.transform != null) {
      final Matrix4 inverse = new Matrix4.identity();
      if (inverse.copyInverse(node.transform) == 0.0)
        return null;
      position = MatrixUtils.transformPoint(inverse, position);
    }
    if (!node.rect.contains(position))
      return null;
    if (node.mergeAllDescendantsIntoThisNode) {
      SemanticsNode result;
      node._visitDescendants((SemanticsNode child) {
        if (child._canPerformAction(action)) {
          result = child;
          return false;
        }
        return true;
      });
      return result?._actionHandler;
    }
    if (node.hasChildren) {
      for (SemanticsNode child in node._children.reversed) {
        final SemanticsActionHandler handler = _getSemanticsActionHandlerForPosition(child, position, action);
        if (handler != null)
          return handler;
      }
    }
    return node._canPerformAction(action) ? node._actionHandler : null;
  }

  /// Asks the [SemanticsNode] at the given position to perform the given action.
  ///
  /// If the [SemanticsNode] has not indicated that it can perform the action,
  /// this function does nothing.
  void performActionAt(Offset position, SemanticsAction action) {
    assert(action != null);
    final SemanticsNode node = rootSemanticsNode;
    if (node == null)
      return;
    final SemanticsActionHandler handler = _getSemanticsActionHandlerForPosition(node, position, action);
    handler?.performAction(action);
  }

  @override
  String toString() => describeIdentity(this);
}
