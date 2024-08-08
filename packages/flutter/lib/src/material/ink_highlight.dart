// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'ink_decoration.dart';
/// @docImport 'ink_splash.dart';
/// @docImport 'ink_well.dart';
/// @docImport 'material.dart';
library;

import 'package:flutter/widgets.dart';

/// A visual emphasis on a part of a [Material] receiving user interaction.
///
/// This object is rarely created directly. Instead of creating an ink highlight
/// directly, consider using an [InkResponse] or [InkWell] widget, which uses
/// gestures (such as tap and long-press) to trigger ink highlights.
///
/// See also:
///
///  * [InkResponse], which uses gestures to trigger ink highlights and ink
///    splashes in the parent [Material].
///  * [InkWell], which is a rectangular [InkResponse] (the most common type of
///    ink response).
///  * [Material], which is the widget on which the ink highlight is painted.
///  * [InkSplash], which is an ink feature that shows a reaction to user input
///    on a [Material].
///  * [Ink], a convenience widget for drawing images and other decorations on
///    Material widgets.
typedef InkHighlight = SplashFill;
