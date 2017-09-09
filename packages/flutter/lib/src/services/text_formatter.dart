// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'text_editing.dart';
import 'text_input.dart';

/// A [TextInputFormatter] can be optionally injected into an [EditableText]
/// to provide as-you-type validation and formatting of the text being edited.
///
/// Text modification should only be applied when text is being committed by the
/// IME and not on text under composition (i.e., only when
/// [TextEditingValue.composing] is collapsed).
///
/// Concrete implementations [BlacklistingTextInputFormatter], which removes
/// blacklisted characters upon edit commit, and
/// [WhitelistingTextInputFormatter], which only allows entries of whitelisted
/// characters, are provided.
///
/// To create custom formatters, extend the [TextInputFormatter] class and
/// implement the [formatEditUpdate] method.
///
/// See also:
///
///  * [EditableText] on which the formatting apply.
///  * [BlacklistingTextInputFormatter], a provided formatter for blacklisting
///    characters.
///  * [WhitelistingTextInputFormatter], a provided formatter for whitelisting
///    characters.
abstract class TextInputFormatter {
  /// Called when text is being typed or cut/copy/pasted in the [EditableText].
  ///
  /// You can override the resulting text based on the previous text value and
  /// the incoming new text value.
  ///
  /// When formatters are chained, `oldValue` reflects the initial value of
  /// [TextEditingValue] at the beginning of the chain.
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue
  );

  /// A shorthand to creating a custom [TextInputFormatter] which formats
  /// incoming text input changes with the given function.
  static TextInputFormatter withFunction(
    TextInputFormatFunction formatFunction
  ) {
    return new _SimpleTextInputFormatter(formatFunction);
  }
}

/// Function signature expected for creating custom [TextInputFormatter]
/// shorthands via [TextInputFormatter.withFunction];
typedef TextEditingValue TextInputFormatFunction(
    TextEditingValue oldValue,
    TextEditingValue newValue,
);

/// Wiring for [TextInputFormatter.withFunction].
class _SimpleTextInputFormatter extends TextInputFormatter {
  _SimpleTextInputFormatter(this.formatFunction) :
    assert(formatFunction != null);

  final TextInputFormatFunction formatFunction;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue
  ) {
    return formatFunction(oldValue, newValue);
  }
}

/// A [TextInputFormatter] that prevents the insertion of blacklisted
/// characters patterns.
///
/// Instances of blacklisted characters found in the new [TextEditingValue]s
/// will be replaced with the [replacementString] which defaults to the empty
/// string.
///
/// Since this formatter only removes characters from the text, it attempts to
/// preserve the existing [TextEditingValue.selection] to values it would now
/// fall at with the removed characters.
///
/// See also:
///
///  * [WhitelistingTextInputFormatter], which uses a whitelist instead of a
///    blacklist.
class BlacklistingTextInputFormatter extends TextInputFormatter {
  /// Creates a formatter that prevents the insertion of blacklisted characters patterns.
  ///
  /// The [blacklistedPattern] must not be null.
  BlacklistingTextInputFormatter(
    this.blacklistedPattern, {
    this.replacementString: '',
  }) : assert(blacklistedPattern != null);

  /// A [Pattern] to match and replace incoming [TextEditingValue]s.
  final Pattern blacklistedPattern;

  /// String used to replace found patterns.
  final String replacementString;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    return _selectionAwareTextManipulation(
      newValue,
      (String substring) {
        return substring.replaceAll(blacklistedPattern, replacementString);
      },
    );
  }

  /// A [BlacklistingTextInputFormatter] that forces input to be a single line.
  static final BlacklistingTextInputFormatter singleLineFormatter
      = new BlacklistingTextInputFormatter(new RegExp(r'\n'));
}

/// A [TextInputFormatter] that allows only the insertion of whitelisted
/// characters patterns.
///
/// Since this formatter only removes characters from the text, it attempts to
/// preserve the existing [TextEditingValue.selection] to values it would now
/// fall at with the removed characters.
///
/// See also:
///
///  * [BlacklistingTextInputFormatter], which uses a blacklist instead of a
///    whitelist.
class WhitelistingTextInputFormatter extends TextInputFormatter {
  /// Creates a formatter that allows only the insertion of whitelisted characters patterns.
  ///
  /// The [whitelistedPattern] must not be null.
  WhitelistingTextInputFormatter(this.whitelistedPattern) :
    assert(whitelistedPattern != null);

  /// A [Pattern] to extract all instances of allowed characters.
  ///
  /// [RegExp] with multiple groups is not supported.
  final Pattern whitelistedPattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    return _selectionAwareTextManipulation(
      newValue,
      (String substring) {
        return whitelistedPattern
            .allMatches(substring)
            .map((Match match) => match.group(0))
            .join();
      } ,
    );
  }

  /// A [WhitelistingTextInputFormatter] that takes in digits `[0-9]` only.
  static final WhitelistingTextInputFormatter digitsOnly
      = new WhitelistingTextInputFormatter(new RegExp(r'\d+'));
}

TextEditingValue _selectionAwareTextManipulation(
  TextEditingValue value,
  String substringManipulation(String substring),
) {
  final int selectionStartIndex = value.selection.start;
  final int selectionEndIndex = value.selection.end;
  String manipulatedText;
  TextSelection manipulatedSelection;
  if (selectionStartIndex < 0 || selectionEndIndex < 0) {
    manipulatedText = substringManipulation(value.text);
  } else {
    final String beforeSelection = substringManipulation(
      value.text.substring(0, selectionStartIndex)
    );
    final String inSelection = substringManipulation(
      value.text.substring(selectionStartIndex, selectionEndIndex)
    );
    final String afterSelection = substringManipulation(
      value.text.substring(selectionEndIndex)
    );
    manipulatedText = beforeSelection + inSelection + afterSelection;
    manipulatedSelection = value.selection.copyWith(
      baseOffset: beforeSelection.length,
      extentOffset: beforeSelection.length + inSelection.length,
    );
  }
  return new TextEditingValue(
    text: manipulatedText,
    selection: manipulatedSelection ?? const TextSelection.collapsed(offset: -1),
    composing: manipulatedText == value.text
        ? value.composing
        : TextRange.empty,
  );
}
