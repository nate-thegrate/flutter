// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'data_table.dart';
/// @docImport 'elevated_button.dart';
/// @docImport 'icon_button.dart';
/// @docImport 'ink_decoration.dart';
/// @docImport 'ink_ripple.dart';
/// @docImport 'ink_splash.dart';
/// @docImport 'text_button.dart';
library;

import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'debug.dart';
import 'material.dart';
import 'no_splash.dart';
import 'theme.dart';

// Examples can assume:
// late BuildContext context;

/// An ink feature that displays a [color] "splash" in response to a user
/// gesture that can be confirmed or canceled.
///
/// Subclasses call [confirm] when an input gesture is recognized. For
/// example a press event might trigger an ink feature that's confirmed
/// when the corresponding up event is seen.
///
/// Subclasses call [cancel] when an input gesture is aborted before it
/// is recognized. For example a press event might trigger an ink feature
/// that's canceled when the pointer is dragged out of the reference
/// box.
///
/// The [InkWell] and [InkResponse] widgets generate instances of this
/// class.
@Deprecated(
  'Use Splash instead. '
  'CirclePainter can be mixed in to implement the paintInkCircle() method. '
  'This feature was deprecated after v3.26.0-0.1.pre.',
)
abstract class InteractiveInkFeature extends Splash with CirclePainter {
  /// Creates an InteractiveInkFeature.
  @Deprecated(
    'Use Splash instead. '
    'CirclePainter can be mixed in to implement the paintInkCircle() method. '
    'This feature was deprecated after v3.26.0-0.1.pre.',
  )
  InteractiveInkFeature({
    required super.controller,
    required super.referenceBox,
    super.color,
    super.customBorder,
    super.onRemoved,
  });
}

/// An encapsulation of an [InteractiveInkFeature] constructor used by
/// [InkWell], [InkResponse], and [ThemeData].
///
/// Interactive ink feature implementations should provide a static const
/// `splashFactory` value that's an instance of this class. The `splashFactory`
/// can be used to configure an [InkWell], [InkResponse] or [ThemeData].
///
/// See also:
///
///  * [InkSplash.splashFactory]
///  * [InkRipple.splashFactory]
@Deprecated(
  'Use SplashFactory instead. '
  '"Splash effects" no longer rely on a MaterialInkController. '
  'This feature was deprecated after v3.26.0-0.1.pre.',
)
abstract class InteractiveInkFeatureFactory implements SplashFactoryBase {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  ///
  /// Subclasses should provide a const constructor.
  @Deprecated(
    'Use SplashFactory instead. '
    '"Splash effects" no longer rely on a MaterialInkController. '
    'This feature was deprecated after v3.26.0-0.1.pre.',
  )
  const InteractiveInkFeatureFactory();

  /// The factory method.
  ///
  /// Subclasses should override this method to return a new instance of an
  /// [InteractiveInkFeature].
  @factory
  @override
  InteractiveInkFeature create({
    required SplashController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  });
}

/// Paints circles for ink splashes.
mixin CirclePainter on Splash {
  /// Draws a [Splash] on the provided [Canvas].
  ///
  /// The [transform] argument is the [Matrix4] transform that typically
  /// shifts the coordinate space of the canvas to the space in which
  /// the circle is to be painted.
  ///
  /// If a [customBorder] is provided, then it (along with the [textDirection])
  /// will be used to create a clipping path.
  ///
  /// Otherwise, the [clipCallback] clips the splash to a [RRect] (created by
  /// applying the [borderRadius] to its result).
  ///
  /// If both [customBorder] and [clipCallback] are null, no clipping takes place.
  ///
  /// For examples on how the function is used, see [InkSplash] and [InkRipple].
  @protected
  void paintInkCircle({
    required Canvas canvas,
    required Matrix4 transform,
    required Paint paint,
    required Offset center,
    required double radius,
    TextDirection? textDirection,
    ShapeBorder? customBorder,
    BorderRadius borderRadius = BorderRadius.zero,
    RectCallback? clipCallback,
  }) {
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    canvas.save();
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
    if (clipCallback != null) {
      final Rect rect = clipCallback();
      if (customBorder != null) {
        canvas.clipPath(customBorder.getOuterPath(rect, textDirection: textDirection));
      } else if (borderRadius != BorderRadius.zero) {
        canvas.clipRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius.topLeft, topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft, bottomRight: borderRadius.bottomRight,
        ));
      } else {
        canvas.clipRect(rect);
      }
    }
    canvas.drawCircle(center, radius, paint);
    canvas.restore();
  }
}

/// An area of a [Material] that responds to touch. Has a configurable shape and
/// can be configured to clip splashes that extend outside its bounds or not.
///
/// For a variant of this widget that is specialized for rectangular areas that
/// always clip splashes, see [InkWell].
///
/// An [InkResponse] widget does two things when responding to a tap:
///
///  * It starts to animate a _highlight_. The shape of the highlight is
///    determined by [highlightShape]. If it is a [BoxShape.circle], the
///    default, then the highlight is a circle of fixed size centered in the
///    [InkResponse]. If it is [BoxShape.rectangle], then the highlight is a box
///    the size of the [InkResponse] itself, unless [getRectCallback] is
///    provided, in which case that callback defines the rectangle. The color of
///    the highlight is set by [highlightColor].
///
///  * Simultaneously, it starts to animate a _splash_. This is a growing circle
///    initially centered on the tap location. If this is a [containedInkWell],
///    the splash grows to the [radius] while remaining centered at the tap
///    location. Otherwise, the splash migrates to the center of the box as it
///    grows.
///
/// The following two diagrams show how [InkResponse] looks when tapped if the
/// [highlightShape] is [BoxShape.circle] (the default) and [containedInkWell]
/// is false (also the default).
///
/// The first diagram shows how it looks if the [InkResponse] is relatively
/// large:
///
/// ![The highlight is a disc centered in the box, smaller than the child widget.](https://flutter.github.io/assets-for-api-docs/assets/material/ink_response_large.png)
///
/// The second diagram shows how it looks if the [InkResponse] is small:
///
/// ![The highlight is a disc overflowing the box, centered on the child.](https://flutter.github.io/assets-for-api-docs/assets/material/ink_response_small.png)
///
/// The main thing to notice from these diagrams is that the splashes happily
/// exceed the bounds of the widget (because [containedInkWell] is false).
///
/// The following diagram shows the effect when the [InkResponse] has a
/// [highlightShape] of [BoxShape.rectangle] with [containedInkWell] set to
/// true. These are the values used by [InkWell].
///
/// ![The highlight is a rectangle the size of the box.](https://flutter.github.io/assets-for-api-docs/assets/material/ink_well.png)
///
/// The [InkResponse] widget must have a [Material] widget as an ancestor. The
/// [Material] widget is where the ink reactions are actually painted. This
/// matches the Material Design premise wherein the [Material] is what is
/// actually reacting to touches by spreading ink.
///
/// If a Widget uses this class directly, it should include the following line
/// at the top of its build function to call [debugCheckHasMaterial]:
///
/// ```dart
/// assert(debugCheckHasMaterial(context));
/// ```
///
/// ## Troubleshooting
///
/// ### The ink splashes aren't visible!
///
/// If there is an opaque graphic, e.g. painted using a [Container], [Image], or
/// [DecoratedBox], between the [Material] widget and the [InkResponse] widget,
/// then the splash won't be visible because it will be under the opaque graphic.
/// This is because ink splashes draw on the underlying [Material] itself, as
/// if the ink was spreading inside the material.
///
/// The [Ink] widget can be used as a replacement for [Image], [Container], or
/// [DecoratedBox] to ensure that the image or decoration also paints in the
/// [Material] itself, below the ink.
///
/// If this is not possible for some reason, e.g. because you are using an
/// opaque [CustomPaint] widget, alternatively consider using a second
/// [Material] above the opaque widget but below the [InkResponse] (as an
/// ancestor to the ink response). The [MaterialType.transparency] material
/// kind can be used for this purpose.
///
/// See also:
///
///  * [GestureDetector], for listening for gestures without ink splashes.
///  * [ElevatedButton] and [TextButton], two kinds of buttons in Material Design.
///  * [IconButton], which combines [TouchResponse] with an [Icon].
class InkResponse extends TouchResponse {
  /// Creates an area of a [Material] that responds to touch.
  ///
  /// Must have an ancestor [Material] widget in which to cause ink reactions.
  const InkResponse({
    super.key,
    super.child,
    super.onTap,
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onDoubleTap,
    super.onLongPress,
    super.onSecondaryTap,
    super.onSecondaryTapUp,
    super.onSecondaryTapDown,
    super.onSecondaryTapCancel,
    super.onHighlightChanged,
    super.onHover,
    super.mouseCursor,
    super.containedInkWell = false,
    super.highlightShape = BoxShape.circle,
    super.radius,
    super.borderRadius,
    super.customBorder,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.overlayColor,
    Color? splashColor,
    SplashFactory? splashFactory,
    super.enableFeedback = true,
    super.excludeFromSemantics = false,
    super.focusNode,
    super.canRequestFocus = true,
    super.onFocusChange,
    super.autofocus = false,
    super.statesController,
    super.hoverDuration,
  }) : _splashFactory = splashFactory,
       _splashColor = splashColor,
       super(
         splashColor: splashColor ?? Colors.transparent,
         splashFactory: splashFactory ?? NoSplash.splashFactory,
       );

  final SplashFactory? _splashFactory;
  final Color? _splashColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TouchResponse(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      containedInkWell: containedInkWell,
      highlightShape: highlightShape,
      radius: radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusColor: focusColor ?? theme.focusColor,
      hoverColor: hoverColor ?? theme.hoverColor,
      highlightColor: highlightColor ?? theme.highlightColor,
      overlayColor: overlayColor,
      splashColor: _splashColor ?? theme.splashColor,
      splashFactory: _splashFactory ?? theme.splashFactory,
      enableFeedback: enableFeedback,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      statesController: statesController,
      hoverDuration: hoverDuration,
      child: child,
    );
  }
}

/// A rectangular area of a [Material] that responds to touch.
///
/// For a variant of this widget that does not clip splashes, see [InkResponse].
///
/// The following diagram shows how an [InkWell] looks when tapped, when using
/// default values.
///
/// ![The highlight is a rectangle the size of the box.](https://flutter.github.io/assets-for-api-docs/assets/material/ink_well.png)
///
/// The [InkWell] widget must have a [Material] widget as an ancestor. The
/// [Material] widget is where the ink reactions are actually painted. This
/// matches the Material Design premise wherein the [Material] is what is
/// actually reacting to touches by spreading ink.
///
/// If a Widget uses this class directly, it should include the following line
/// at the top of its build function to call [debugCheckHasMaterial]:
///
/// ```dart
/// assert(debugCheckHasMaterial(context));
/// ```
///
/// ## Troubleshooting
///
/// ### The ink splashes aren't visible!
///
/// If there is an opaque graphic, e.g. painted using a [Container], [Image], or
/// [DecoratedBox], between the [Material] widget and the [InkWell] widget, then
/// the splash won't be visible because it will be under the opaque graphic.
/// This is because ink splashes draw on the underlying [Material] itself, as
/// if the ink was spreading inside the material.
///
/// The [Ink] widget can be used as a replacement for [Image], [Container], or
/// [DecoratedBox] to ensure that the image or decoration also paints in the
/// [Material] itself, below the ink.
///
/// If this is not possible for some reason, e.g. because you are using an
/// opaque [CustomPaint] widget, alternatively consider using a second
/// [Material] above the opaque widget but below the [InkWell] (as an
/// ancestor to the ink well). The [MaterialType.transparency] material
/// kind can be used for this purpose.
///
/// ### InkWell isn't clipping properly
///
/// If you want to clip an InkWell or any [Ink] widgets you need to keep in mind
/// that the [Material] that the Ink will be printed on is responsible for clipping.
/// This means you can't wrap the [Ink] widget in a clipping widget directly,
/// since this will leave the [Material] not clipped (and by extension the printed
/// [Ink] widgets as well).
///
/// An easy solution is to deliberately wrap the [Ink] widgets you want to clip
/// in a [Material], and wrap that in a clipping widget instead. See [Ink] for
/// an example.
///
/// ### The ink splashes don't track the size of an animated container
/// If the size of an InkWell's [Material] ancestor changes while the InkWell's
/// splashes are expanding, you may notice that the splashes aren't clipped
/// correctly. This can't be avoided.
///
/// An example of this situation is as follows:
///
/// {@tool dartpad}
/// Tap the container to cause it to grow. Then, tap it again and hold before
/// the widget reaches its maximum size to observe the clipped ink splash.
///
/// ** See code in examples/api/lib/material/ink_well/ink_well.0.dart **
/// {@end-tool}
///
/// An InkWell's splashes will not properly update to conform to changes if the
/// size of its underlying [Material], where the splashes are rendered, changes
/// during animation. You should avoid using InkWells within [Material] widgets
/// that are changing size.
///
/// See also:
///
///  * [GestureDetector], for listening for gestures without ink splashes.
///  * [ElevatedButton] and [TextButton], two kinds of buttons in Material Design.
///  * [InkResponse], a variant of [InkWell] that doesn't force a rectangular
///    shape on the ink reaction.
class InkWell extends InkResponse {
  /// Creates an ink well.
  ///
  /// Must have an ancestor [Material] widget in which to cause ink reactions.
  const InkWell({
    super.key,
    super.child,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onSecondaryTap,
    super.onSecondaryTapUp,
    super.onSecondaryTapDown,
    super.onSecondaryTapCancel,
    super.onHighlightChanged,
    super.onHover,
    super.mouseCursor,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.overlayColor,
    super.splashColor,
    super.splashFactory,
    super.radius,
    super.borderRadius,
    super.customBorder,
    bool? enableFeedback = true,
    super.excludeFromSemantics,
    super.focusNode,
    super.canRequestFocus,
    super.onFocusChange,
    super.autofocus,
    super.statesController,
    super.hoverDuration,
  }) : super(
    containedInkWell: true,
    highlightShape: BoxShape.rectangle,
    enableFeedback: enableFeedback ?? true,
  );
}
