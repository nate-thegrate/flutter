// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'constants.dart';
import 'text_button.dart';
import 'theme.dart';

const TextStyle _kToolbarButtonFontStyle = TextStyle(
  inherit: false,
  fontSize: 14.0,
  letterSpacing: -0.15,
  fontWeight: FontWeight.w400,
);

const EdgeInsets _kToolbarButtonPadding = EdgeInsets.fromLTRB(
  20.0,
  0.0,
  20.0,
  3.0,
);

/// A [TextButton] for the Material desktop text selection toolbar.
class DesktopTextSelectionToolbarButton extends StatelessWidget {
  /// Creates an instance of DesktopTextSelectionToolbarButton.
  const DesktopTextSelectionToolbarButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  /// Create an instance of [DesktopTextSelectionToolbarButton] whose child is
  /// a [Text] widget in the style of the Material text selection toolbar.
  DesktopTextSelectionToolbarButton.text({
    super.key,
    required BuildContext context,
    required this.onPressed,
    required String text,
  }) : child = Text(
         text,
         overflow: TextOverflow.ellipsis,
         style: _kToolbarButtonFontStyle.copyWith(
           color: switch (Theme.of(context).colorScheme.brightness) {
            Brightness.light => Colors.black87,
            Brightness.dark  => Colors.white,
           },
         ),
       );

  /// {@macro flutter.material.TextSelectionToolbarTextButton.onPressed}
  final VoidCallback? onPressed;

  /// {@macro flutter.material.TextSelectionToolbarTextButton.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          enabledMouseCursor: SystemMouseCursors.basic,
          disabledMouseCursor: SystemMouseCursors.basic,
          // TODO(hansmuller): Should be colorScheme.onSurface
          foregroundColor: switch (Theme.of(context).colorScheme.brightness) {
            Brightness.light => Colors.black87,
            Brightness.dark  => Colors.white,
          },
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(kMinInteractiveDimension, 36.0),
          padding: _kToolbarButtonPadding,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
