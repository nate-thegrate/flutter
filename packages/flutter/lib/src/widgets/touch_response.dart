// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'package:flutter/material.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const Duration _kDefaultHighlightFadeDuration = Duration(milliseconds: 200);

/// A [Splash] that fills a certain area, rather than changing in size.
///
/// This object is rarely created directly. Instead of creating an ink highlight
/// directly, consider using an [TouchResponse] or [InkWell] widget, which uses
/// gestures (such as tap and long-press) to trigger ink highlights.
///
/// See also:
///
///  * [TouchResponse], which uses gestures to trigger ink highlights and ink
///    splashes in the parent [Material].
///  * [InkWell], which is a rectangular [TouchResponse] (the most common type of
///    ink response).
///  * [Material], which is the widget on which the ink highlight is painted.
///  * [InkSplash], which is an ink feature that shows a reaction to user input
///    on a [Material].
///  * [Ink], a convenience widget for drawing images and other decorations on
///    Material widgets.
class SplashFill extends Splash {
  /// Begin a highlight animation.
  ///
  /// The [controller] argument is typically obtained via
  /// `Material.of(context)`.
  ///
  /// If a `rectCallback` is given, then it provides the highlight rectangle,
  /// otherwise, the highlight rectangle is coincident with the [referenceBox].
  ///
  /// When the highlight is removed, `onRemoved` will be called.
  SplashFill({
    required super.controller,
    required super.referenceBox,
    required super.color,
    required TextDirection textDirection,
    BoxShape shape = BoxShape.rectangle,
    double? radius,
    BorderRadius? borderRadius,
    super.customBorder,
    RectCallback? rectCallback,
    super.onRemoved,
    Duration fadeDuration = _kDefaultHighlightFadeDuration,
  }) : _shape = shape,
       _radius = radius ?? 35.0,
       _borderRadius = borderRadius ?? BorderRadius.zero,

       _textDirection = textDirection,
       _rectCallback = rectCallback {
    _alphaController = AnimationController(duration: fadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged)
      ..forward();
    _alpha = _alphaController.drive(IntTween(
      begin: 0,
      end: color.alpha,
    ));

    controller.addInkFeature(this);
  }

  final BoxShape _shape;
  final double _radius;
  final BorderRadius _borderRadius;
  final RectCallback? _rectCallback;
  final TextDirection _textDirection;

  late Animation<int> _alpha;
  late AnimationController _alphaController;

  /// Whether this part of the material is being visually emphasized.
  bool get active => _active;
  bool _active = true;

  /// Start visually emphasizing this part of the material.
  void activate() {
    _active = true;
    _alphaController.forward();
  }

  /// Stop visually emphasizing this part of the material.
  void deactivate() {
    _active = false;
    _alphaController.reverse();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status.isDismissed && !_active) {
      dispose();
    }
  }

  @override
  void dispose() {
    _alphaController.dispose();
    super.dispose();
  }

  void _paintHighlight(Canvas canvas, Rect rect, Paint paint) {
    canvas.save();
    if (customBorder != null) {
      canvas.clipPath(customBorder!.getOuterPath(rect, textDirection: _textDirection));
    }
    switch (_shape) {
      case BoxShape.circle:
        canvas.drawCircle(rect.center, _radius, paint);
      case BoxShape.rectangle:
        if (_borderRadius != BorderRadius.zero) {
          final RRect clipRRect = RRect.fromRectAndCorners(
            rect,
            topLeft: _borderRadius.topLeft, topRight: _borderRadius.topRight,
            bottomLeft: _borderRadius.bottomLeft, bottomRight: _borderRadius.bottomRight,
          );
          canvas.drawRRect(clipRRect, paint);
        } else {
          canvas.drawRect(rect, paint);
        }
    }
    canvas.restore();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = color.withAlpha(_alpha.value);
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    final Rect rect = _rectCallback != null ? _rectCallback() : Offset.zero & referenceBox.size;
    if (originOffset == null) {
      canvas.save();
      canvas.transform(transform.storage);
      _paintHighlight(canvas, rect, paint);
      canvas.restore();
    } else {
      _paintHighlight(canvas, rect.shift(originOffset), paint);
    }
  }
}


abstract class _ParentTouchResponseState {
  void markChildTouchResponsePressed(_ParentTouchResponseState childState, bool value);
}

class _ParentTouchResponseProvider extends InheritedWidget {
  const _ParentTouchResponseProvider({
    required this.state,
    required super.child,
  });

  final _ParentTouchResponseState state;

  @override
  bool updateShouldNotify(_ParentTouchResponseProvider oldWidget) => state != oldWidget.state;

  static _ParentTouchResponseState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ParentTouchResponseProvider>()?.state;
  }
}

typedef _GetRectCallback = RectCallback? Function(RenderBox referenceBox);
typedef _CheckContext = bool Function(BuildContext context);


class TouchResponse extends StatelessWidget {
  /// Creates an area that visually responds to touch.
  ///
  /// Must have an ancestor [SplashBox] widget in which to create [Splash]es.
  const TouchResponse({
    super.key,
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.highlightShape = BoxShape.circle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    required this.splashColor,
    required this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.statesController,
    this.hoverDuration,
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback? onTapDown;

  /// Called when the user releases a tap that was started on this part of the
  /// material. [onTap] is called immediately after.
  final GestureTapUpCallback? onTapUp;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final GestureTapCallback? onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  /// Called when the user taps this part of the material with a secondary button.
  final GestureTapCallback? onSecondaryTap;

  /// Called when the user taps down on this part of the material with a
  /// secondary button.
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Called when the user releases a secondary button tap that was started on
  /// this part of the material. [onSecondaryTap] is called immediately after.
  final GestureTapUpCallback? onSecondaryTapUp;

  /// Called when the user cancels a secondary button tap that was started on
  /// this part of the material.
  final GestureTapCallback? onSecondaryTapCancel;

  /// Called when this part of the material either becomes highlighted or stops
  /// being highlighted.
  ///
  /// The value passed to the callback is true if this part of the material has
  /// become highlighted and false if this part of the material has stopped
  /// being highlighted.
  ///
  /// If all of [onTap], [onDoubleTap], and [onLongPress] become null while a
  /// gesture is ongoing, then [onTapCancel] will be fired and
  /// [onHighlightChanged] will be fired with the value false _during the
  /// build_. This means, for instance, that in that scenario [State.setState]
  /// cannot be called.
  final ValueChanged<bool>? onHighlightChanged;

  /// Called when a pointer enters or exits the ink response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this
  /// part of the material and false if a pointer has exited this part of the
  /// material.
  final ValueChanged<bool>? onHover;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateProperty<MouseCursor>],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If this property is null, [WidgetStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// Whether this ink response should be clipped its bounds.
  ///
  /// This flag also controls whether the splash migrates to the center of the
  /// [TouchResponse] or not. If [containedInkWell] is true, the splash remains
  /// centered around the tap location. If it is false, the splash migrates to
  /// the center of the [TouchResponse] as it grows.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [borderRadius], which controls the corners when the box is a rectangle.
  ///  * [getRectCallback], which controls the size and position of the box when
  ///    it is a rectangle.
  final bool containedInkWell;

  /// The shape (e.g., circle, rectangle) to use for the highlight drawn around
  /// this part of the material when pressed, hovered over, or focused.
  ///
  /// The same shape is used for the pressed highlight (see [highlightColor]),
  /// the focus highlight (see [focusColor]), and the hover highlight (see
  /// [hoverColor]).
  ///
  /// If the shape is [BoxShape.circle], then the highlight is centered on the
  /// [TouchResponse]. If the shape is [BoxShape.rectangle], then the highlight
  /// fills the [TouchResponse], or the rectangle provided by [getRectCallback] if
  /// the callback is specified.
  ///
  /// See also:
  ///
  ///  * [containedInkWell], which controls clipping behavior.
  ///  * [borderRadius], which controls the corners when the box is a rectangle.
  ///  * [highlightColor], the color of the highlight.
  ///  * [getRectCallback], which controls the size and position of the box when
  ///    it is a rectangle.
  final BoxShape highlightShape;

  /// The radius of the ink splash.
  ///
  /// Splashes grow up to this size. By default, this size is determined from
  /// the size of the rectangle provided by [getRectCallback], or the size of
  /// the [TouchResponse] itself.
  ///
  /// See also:
  ///
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final double? radius;

  /// The border radius of the containing rectangle. This is effective only if
  /// [highlightShape] is [BoxShape.rectangle].
  ///
  /// If this is null, it is interpreted as [BorderRadius.zero].
  final BorderRadius? borderRadius;

  /// The custom clip border.
  ///
  /// If this is null, the ink response will not clip its content.
  final ShapeBorder? customBorder;

  /// The color of the ink response when the parent widget is focused. If this
  /// property is null then the focus color of the theme,
  /// [ThemeData.focusColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? focusColor;

  /// The color of the ink response when a pointer is hovering over it. If this
  /// property is null then the hover color of the theme,
  /// [ThemeData.hoverColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [highlightColor], the color of the pressed highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? hoverColor;

  /// The highlight color of the ink response when pressed. If this property is
  /// null then the highlight color of the theme, [ThemeData.highlightColor],
  /// will be used.
  ///
  /// See also:
  ///
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? highlightColor;

  /// Defines the ink response focus, hover, and splash colors.
  ///
  /// This default null property can be used as an alternative to
  /// [focusColor], [hoverColor], [highlightColor], and
  /// [splashColor]. If non-null, it is resolved against one of
  /// [WidgetState.focused], [WidgetState.hovered], and
  /// [WidgetState.pressed]. It's convenient to use when the parent
  /// widget can pass along its own WidgetStateProperty value for
  /// the overlay color.
  ///
  /// [WidgetState.pressed] triggers a ripple (an ink splash), per
  /// the current Material Design spec. The [overlayColor] doesn't map
  /// a state to [highlightColor] because a separate highlight is not
  /// used by the current design guidelines. See
  /// https://material.io/design/interaction/states.html#pressed
  ///
  /// If the overlay color is null or resolves to null, then [focusColor],
  /// [hoverColor], [splashColor] and their defaults are used instead.
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The splash color of the ink response. If this property is null then the
  /// splash color of the theme, [ThemeData.splashColor], will be used.
  ///
  /// See also:
  ///
  ///  * [splashFactory], which defines the appearance of the splash.
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [highlightColor], the color of the highlight.
  final Color splashColor;

  /// Defines the appearance of the splash.
  ///
  /// Defaults to the value of the theme's splash factory: [ThemeData.splashFactory].
  ///
  /// See also:
  ///
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [splashColor], the color of the splash.
  ///  * [highlightColor], the color of the highlight.
  ///  * [InkSplash.splashFactory], which defines the default splash.
  ///  * [InkRipple.splashFactory], which defines a splash that spreads out
  ///    more aggressively than the default.
  final SplashFactory splashFactory;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  /// Whether to exclude the gestures introduced by this widget from the
  /// semantics tree.
  ///
  /// For example, a long-press gesture for showing a tooltip is usually
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// {@template flutter.material.inkwell.onFocusChange}
  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  /// The rectangle to use for the highlight effect and for clipping
  /// the splash effects if [containedInkWell] is true.
  ///
  /// This method is intended to be overridden by descendants that
  /// specialize [TouchResponse] for unusual cases. For example,
  /// [TableRowInkWell] implements this method to return the rectangle
  /// corresponding to the row that the widget is in.
  ///
  /// The default behavior returns null, which is equivalent to
  /// returning the referenceBox argument's bounding box (though
  /// slightly more efficient).
  RectCallback? getRectCallback(RenderBox referenceBox) => null;

  /// {@template flutter.material.inkwell.statesController}
  /// Represents the interactive "state" of this widget in terms of
  /// a set of [WidgetState]s, like [WidgetState.pressed] and
  /// [WidgetState.focused].
  ///
  /// Classes based on this one can provide their own
  /// [WidgetStatesController] to which they've added listeners.
  /// They can also update the controller's [WidgetStatesController.value]
  /// however, this may only be done when it's safe to call
  /// [State.setState], like in an event handler.
  /// {@endtemplate}
  final WidgetStatesController? statesController;

  /// The duration of the animation that animates the hover effect.
  ///
  /// The default is 50ms.
  final Duration? hoverDuration;

  @override
  Widget build(BuildContext context) {
    final _ParentTouchResponseState? parentState = _ParentTouchResponseProvider.maybeOf(context);
    return _TouchResponseStateWidget(
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
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      overlayColor: overlayColor,
      splashColor: splashColor,
      splashFactory: splashFactory,
      enableFeedback: enableFeedback,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      parentState: parentState,
      getRectCallback: getRectCallback,
      debugCheckContext: debugCheckContext,
      statesController: statesController,
      hoverDuration: hoverDuration,
      child: child,
    );
  }

  /// Asserts that the given context satisfies the prerequisites for
  /// this class.
  ///
  /// This method is intended to be overridden by descendants that
  /// specialize [TouchResponse] for unusual cases. For example,
  /// [TableRowInkWell] implements this method to verify that the widget is
  /// in a table.
  @mustCallSuper
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckSplash(context));
    assert(debugCheckHasDirectionality(context));
    return true;
  }
}

class _TouchResponseStateWidget extends StatefulWidget {
  const _TouchResponseStateWidget({
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.highlightShape = BoxShape.circle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    required this.splashColor,
    required this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.parentState,
    this.getRectCallback,
    required this.debugCheckContext,
    this.statesController,
    this.hoverDuration,
  });

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapCallback? onSecondaryTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final MouseCursor? mouseCursor;
  final bool containedInkWell;
  final BoxShape highlightShape;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color splashColor;
  final SplashFactory splashFactory;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final _ParentTouchResponseState? parentState;
  final _GetRectCallback? getRectCallback;
  final _CheckContext debugCheckContext;
  final WidgetStatesController? statesController;
  final Duration? hoverDuration;

  @override
  _TouchResponseState createState() => _TouchResponseState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapUp != null) 'tap up',
      if (onTapCancel != null) 'tap cancel',
      if (onSecondaryTap != null) 'secondary tap',
      if (onSecondaryTapUp != null) 'secondary tap up',
      if (onSecondaryTapDown != null) 'secondary tap down',
      if (onSecondaryTapCancel != null) 'secondary tap cancel'
    ];
    properties.add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties.add(DiagnosticsProperty<MouseCursor>('mouseCursor', mouseCursor));
    properties.add(DiagnosticsProperty<bool>('containedInkWell', containedInkWell, level: DiagnosticLevel.fine));
    properties.add(DiagnosticsProperty<BoxShape>(
      'highlightShape',
      highlightShape,
      description: '${containedInkWell ? "clipped to " : ""}$highlightShape',
      showName: false,
    ));
  }
}

/// Used to index the allocated highlights for the different types of highlights
/// in [_TouchResponseState].
enum _HighlightType {
  pressed,
  hover,
  focus,
}

class _TouchResponseState extends State<_TouchResponseStateWidget>
  with AutomaticKeepAliveClientMixin<_TouchResponseStateWidget>
  implements _ParentTouchResponseState
{
  Set<Splash>? _splashes;
  Splash? _currentSplash;
  bool _hovering = false;
  final Map<_HighlightType, SplashFill?> _highlights = <_HighlightType, SplashFill?>{};
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: activateOnIntent),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: activateOnIntent),
  };
  WidgetStatesController? internalStatesController;

  bool get highlightsExist => _highlights.values.where((SplashFill? highlight) => highlight != null).isNotEmpty;

  final ObserverList<_ParentTouchResponseState> _activeChildren = ObserverList<_ParentTouchResponseState>();

  static const Duration _activationDuration = Duration(milliseconds: 100);
  Timer? _activationTimer;

  @override
  void markChildTouchResponsePressed(_ParentTouchResponseState childState, bool value) {
    final bool lastAnyPressed = _anyChildTouchResponsePressed;
    if (value) {
      _activeChildren.add(childState);
    } else {
      _activeChildren.remove(childState);
    }
    final bool nowAnyPressed = _anyChildTouchResponsePressed;
    if (nowAnyPressed != lastAnyPressed) {
      widget.parentState?.markChildTouchResponsePressed(this, nowAnyPressed);
    }
  }
  bool get _anyChildTouchResponsePressed => _activeChildren.isNotEmpty;

  void activateOnIntent(Intent? intent) {
    _activationTimer?.cancel();
    _activationTimer = null;
    _startNewSplash(context: context);
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onTap != null) {
      if (widget.enableFeedback) {
        Feedback.forTap(context);
      }
      widget.onTap?.call();
    }
    // Delay the call to `updateHighlight` to simulate a pressed delay
    // and give WidgetStatesController listeners a chance to react.
    _activationTimer = Timer(_activationDuration, () {
      updateHighlight(_HighlightType.pressed, value: false);
    });
  }

  void simulateTap([Intent? intent]) {
    _startNewSplash(context: context);
    handleTap();
  }

  void simulateLongPress() {
    _startNewSplash(context: context);
    handleLongPress();
  }

  void handleStatesControllerChange() {
    // Force a rebuild to resolve widget.overlayColor, widget.mouseCursor
    setState(() { });
  }

  WidgetStatesController get statesController => widget.statesController ?? internalStatesController!;

  void initStatesController() {
    if (widget.statesController == null) {
      internalStatesController = WidgetStatesController();
    }
    statesController.update(WidgetState.disabled, !enabled);
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
    FocusManager.instance.addHighlightModeListener(handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(_TouchResponseStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      oldWidget.statesController?.removeListener(handleStatesControllerChange);
      if (widget.statesController != null) {
        internalStatesController?.dispose();
        internalStatesController = null;
      }
      initStatesController();
    }
    if (widget.radius != oldWidget.radius ||
        widget.highlightShape != oldWidget.highlightShape ||
        widget.borderRadius != oldWidget.borderRadius) {
      final SplashFill? hoverHighlight = _highlights[_HighlightType.hover];
      if (hoverHighlight != null) {
        hoverHighlight.dispose();
        updateHighlight(_HighlightType.hover, value: _hovering, callOnHover: false);
      }
      final SplashFill? focusHighlight = _highlights[_HighlightType.focus];
      if (focusHighlight != null) {
        focusHighlight.dispose();
        // Do not call updateFocusHighlights() here because it is called below
      }
    }
    if (widget.customBorder != oldWidget.customBorder) {
      _updateHighlightsAndSplashes();
    }
    if (enabled != isWidgetEnabled(oldWidget)) {
      statesController.update(WidgetState.disabled, !enabled);
      if (!enabled) {
        statesController.update(WidgetState.pressed, false);
        // Remove the existing hover highlight immediately when enabled is false.
        // Do not rely on updateHighlight or SplashFill.deactivate to not break
        // the expected lifecycle which is updating _hovering when the mouse exit.
        // Manually updating _hovering here or calling SplashFill.deactivate
        // will lead to onHover not being called or call when it is not allowed.
        final SplashFill? hoverHighlight = _highlights[_HighlightType.hover];
        hoverHighlight?.dispose();
      }
      // Don't call widget.onHover because many widgets, including the button
      // widgets, apply setState to an ancestor context from onHover.
      updateHighlight(_HighlightType.hover, value: _hovering, callOnHover: false);
    }
    updateFocusHighlights();
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(handleFocusHighlightModeChange);
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();
    _activationTimer?.cancel();
    _activationTimer = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => highlightsExist || (_splashes != null && _splashes!.isNotEmpty);

  Duration getFadeDurationForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return const Duration(milliseconds: 200);
      case _HighlightType.hover:
      case _HighlightType.focus:
        return widget.hoverDuration ?? const Duration(milliseconds: 50);
    }
  }

  void updateHighlight(_HighlightType type, { required bool value, bool callOnHover = true }) {
    final SplashFill? highlight = _highlights[type];
    void handleInkRemoval() {
      assert(_highlights[type] != null);
      _highlights[type] = null;
      updateKeepAlive();
    }

    switch (type) {
      case _HighlightType.pressed:
        statesController.update(WidgetState.pressed, value);
      case _HighlightType.hover:
        if (callOnHover) {
          statesController.update(WidgetState.hovered, value);
        }
      case _HighlightType.focus:
        // see handleFocusUpdate()
        break;
    }

    if (type == _HighlightType.pressed) {
      widget.parentState?.markChildTouchResponsePressed(this, value);
    }
    if (value == (highlight != null && highlight.active)) {
      return;
    }

    if (value) {
      if (highlight == null) {
        final Color resolvedOverlayColor = widget.overlayColor?.resolve(statesController.value)
          ?? switch (type) {
            // Use the backwards compatible defaults
            _HighlightType.pressed => widget.highlightColor,
            _HighlightType.focus => widget.focusColor,
            _HighlightType.hover => widget.hoverColor,
          }!;
        final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
        _highlights[type] = SplashFill(
          controller: Splash.of(context),
          referenceBox: referenceBox,
          color: enabled ? resolvedOverlayColor : resolvedOverlayColor.withAlpha(0),
          shape: widget.highlightShape,
          radius: widget.radius,
          borderRadius: widget.borderRadius,
          customBorder: widget.customBorder,
          rectCallback: widget.getRectCallback!(referenceBox),
          onRemoved: handleInkRemoval,
          textDirection: Directionality.of(context),
          fadeDuration: getFadeDurationForType(type),
        );
        updateKeepAlive();
      } else {
        highlight.activate();
      }
    } else {
      highlight!.deactivate();
    }
    assert(value == (_highlights[type] != null && _highlights[type]!.active));

    switch (type) {
      case _HighlightType.pressed:
        widget.onHighlightChanged?.call(value);
      case _HighlightType.hover:
        if (callOnHover) {
          widget.onHover?.call(value);
        }
      case _HighlightType.focus:
        break;
    }
  }

  void _updateHighlightsAndSplashes() {
    for (final SplashFill? highlight in _highlights.values) {
      highlight?.customBorder = widget.customBorder;
    }
    _currentSplash?.customBorder = widget.customBorder;

    if (_splashes != null && _splashes!.isNotEmpty) {
      for (final Splash inkFeature in _splashes!) {
        inkFeature.customBorder = widget.customBorder;
      }
    }
  }

  Splash _createSplash(Offset globalPosition) {
    final SplashController inkController = Splash.of(context);
    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final Offset position = referenceBox.globalToLocal(globalPosition);
    final Color color =  widget.overlayColor?.resolve(statesController.value) ?? widget.splashColor;
    final RectCallback? rectCallback = widget.containedInkWell ? widget.getRectCallback!(referenceBox) : null;
    final BorderRadius? borderRadius = widget.borderRadius;
    final ShapeBorder? customBorder = widget.customBorder;

    Splash? splash;
    void onRemoved() {
      if (_splashes != null) {
        assert(_splashes!.contains(splash));
        _splashes!.remove(splash);
        if (_currentSplash == splash) {
          _currentSplash = null;
        }
        updateKeepAlive();
      } // else we're probably in deactivate()
    }

    splash = widget.splashFactory.create(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: widget.containedInkWell,
      rectCallback: rectCallback,
      radius: widget.radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  void handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      updateFocusHighlights();
    });
  }

  bool get _shouldShowFocus {
    return switch (MediaQuery.maybeNavigationModeOf(context)) {
      NavigationMode.traditional || null => enabled && _hasFocus,
      NavigationMode.directional => _hasFocus,
    };
  }

  void updateFocusHighlights() {
    final bool showFocus = switch (FocusManager.instance.highlightMode) {
      FocusHighlightMode.touch => false,
      FocusHighlightMode.traditional => _shouldShowFocus,
    };
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool _hasFocus = false;
  void handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    // Set here rather than updateHighlight because this widget's
    // (WidgetState) states include WidgetState.focused if
    // the InkWell _has_ the focus, rather than if it's showing
    // the focus per FocusManager.instance.highlightMode.
    statesController.update(WidgetState.focused, hasFocus);
    updateFocusHighlights();
    widget.onFocusChange?.call(hasFocus);
  }

  void handleAnyTapDown(TapDownDetails details) {
    if (_anyChildTouchResponsePressed) {
      return;
    }
    _startNewSplash(details: details);
  }

  void handleTapDown(TapDownDetails details) {
    handleAnyTapDown(details);
    widget.onTapDown?.call(details);
  }

  void handleTapUp(TapUpDetails details) {
    widget.onTapUp?.call(details);
  }

  void handleSecondaryTapDown(TapDownDetails details) {
    handleAnyTapDown(details);
    widget.onSecondaryTapDown?.call(details);
  }

  void handleSecondaryTapUp(TapUpDetails details) {
    widget.onSecondaryTapUp?.call(details);
  }

  void _startNewSplash({TapDownDetails? details, BuildContext? context}) {
    assert(details != null || context != null);

    final Offset globalPosition;
    if (context != null) {
      final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
      assert(referenceBox.hasSize, 'TouchResponse must be done with layout before starting a splash.');
      globalPosition = referenceBox.localToGlobal(referenceBox.paintBounds.center);
    } else {
      globalPosition = details!.globalPosition;
    }
    statesController.update(WidgetState.pressed, true); // ... before creating the splash
    final Splash splash = _createSplash(globalPosition);
    _splashes ??= HashSet<Splash>();
    _splashes!.add(splash);
    _currentSplash?.cancel();
    _currentSplash = splash;
    updateKeepAlive();
    updateHighlight(_HighlightType.pressed, value: true);
  }

  void handleTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    if (widget.onTap != null) {
      if (widget.enableFeedback) {
        Feedback.forTap(context);
      }
      widget.onTap?.call();
    }
  }

  void handleTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;
    widget.onTapCancel?.call();
    updateHighlight(_HighlightType.pressed, value: false);
  }

  void handleDoubleTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    widget.onDoubleTap?.call();
  }

  void handleLongPress() {
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onLongPress != null) {
      if (widget.enableFeedback) {
        Feedback.forLongPress(context);
      }
      widget.onLongPress!();
    }
  }

  void handleSecondaryTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    widget.onSecondaryTap?.call();
  }

  void handleSecondaryTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;
    widget.onSecondaryTapCancel?.call();
    updateHighlight(_HighlightType.pressed, value: false);
  }

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<Splash> splashes = _splashes!;
      _splashes = null;
      for (final Splash splash in splashes) {
        splash.dispose();
      }
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    for (final _HighlightType highlight in _highlights.keys) {
      _highlights[highlight]?.dispose();
      _highlights[highlight] = null;
    }
    widget.parentState?.markChildTouchResponsePressed(this, false);
    super.deactivate();
  }

  bool isWidgetEnabled(_TouchResponseStateWidget widget) {
    return _primaryButtonEnabled(widget) || _secondaryButtonEnabled(widget);
  }

  bool _primaryButtonEnabled(_TouchResponseStateWidget widget) {
    return widget.onTap != null
      || widget.onDoubleTap != null
      || widget.onLongPress != null
      || widget.onTapUp != null
      || widget.onTapDown != null;
  }

  bool _secondaryButtonEnabled(_TouchResponseStateWidget widget) {
    return widget.onSecondaryTap != null
      || widget.onSecondaryTapUp != null
      || widget.onSecondaryTapDown != null;
  }

  bool get enabled => isWidgetEnabled(widget);
  bool get _primaryEnabled => _primaryButtonEnabled(widget);
  bool get _secondaryEnabled => _secondaryButtonEnabled(widget);

  void handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    if (enabled) {
      handleHoverChange();
    }
  }

  void handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    // If the exit occurs after we've been disabled, we still
    // want to take down the highlights and run widget.onHover.
    handleHoverChange();
  }

  void handleHoverChange() {
    updateHighlight(_HighlightType.hover, value: _hovering);
  }

  bool get _canRequestFocus {
    return switch (MediaQuery.maybeNavigationModeOf(context)) {
      NavigationMode.traditional || null => enabled && widget.canRequestFocus,
      NavigationMode.directional => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.debugCheckContext(context));
    super.build(context); // See AutomaticKeepAliveClientMixin.

    Color getHighlightColorForType(_HighlightType type) {
      const Set<WidgetState> pressed = <WidgetState>{WidgetState.pressed};
      const Set<WidgetState> focused = <WidgetState>{WidgetState.focused};
      const Set<WidgetState> hovered = <WidgetState>{WidgetState.hovered};

      return switch (type) {
        // The pressed state triggers a ripple (ink splash), per the current
        // Material Design spec. A separate highlight is no longer used.
        // See https://material.io/design/interaction/states.html#pressed
        _HighlightType.pressed => widget.overlayColor?.resolve(pressed) ?? widget.highlightColor,
        _HighlightType.focus   => widget.overlayColor?.resolve(focused) ?? widget.focusColor,
        _HighlightType.hover   => widget.overlayColor?.resolve(hovered) ?? widget.hoverColor,
      }!;
    }
    for (final _HighlightType type in _highlights.keys) {
      _highlights[type]?.color = getHighlightColorForType(type);
    }

    _currentSplash?.color = widget.overlayColor?.resolve(statesController.value) ?? widget.splashColor;

    final MouseCursor effectiveMouseCursor = WidgetStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? WidgetStateMouseCursor.clickable,
      statesController.value,
    );

    return _ParentTouchResponseProvider(
      state: this,
      child: Actions(
        actions: _actionMap,
        child: Focus(
          focusNode: widget.focusNode,
          canRequestFocus: _canRequestFocus,
          onFocusChange: handleFocusUpdate,
          autofocus: widget.autofocus,
          child: MouseRegion(
            cursor: effectiveMouseCursor,
            onEnter: handleMouseEnter,
            onExit: handleMouseExit,
            child: DefaultSelectionStyle.merge(
              mouseCursor: effectiveMouseCursor,
              child: Semantics(
                onTap: widget.excludeFromSemantics || widget.onTap == null ? null : simulateTap,
                onLongPress: widget.excludeFromSemantics || widget.onLongPress == null ? null : simulateLongPress,
                child: GestureDetector(
                  onTapDown: _primaryEnabled ? handleTapDown : null,
                  onTapUp: _primaryEnabled ? handleTapUp : null,
                  onTap: _primaryEnabled ? handleTap : null,
                  onTapCancel: _primaryEnabled ? handleTapCancel : null,
                  onDoubleTap: widget.onDoubleTap != null ? handleDoubleTap : null,
                  onLongPress: widget.onLongPress != null ? handleLongPress : null,
                  onSecondaryTapDown: _secondaryEnabled ? handleSecondaryTapDown : null,
                  onSecondaryTapUp: _secondaryEnabled ? handleSecondaryTapUp: null,
                  onSecondaryTap: _secondaryEnabled ? handleSecondaryTap : null,
                  onSecondaryTapCancel: _secondaryEnabled ? handleSecondaryTapCancel : null,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
