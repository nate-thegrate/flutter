// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'card.dart';
/// @docImport 'color_scheme.dart';
/// @docImport 'colors.dart';
/// @docImport 'ink_decoration.dart';
/// @docImport 'ink_highlight.dart';
/// @docImport 'ink_splash.dart';
/// @docImport 'ink_well.dart';
/// @docImport 'list_tile.dart';
/// @docImport 'material_button.dart';
/// @docImport 'mergeable_material.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'elevation_overlay.dart';
import 'theme.dart';

// Examples can assume:
// late BuildContext context;

/// Signature for the callback used by [Splash]es to obtain the
/// appropriate [Rect].
typedef RectCallback = Rect Function();

/// The various kinds of material in Material Design. Used to
/// configure the default behavior of [Material] widgets.
///
/// See also:
///
///  * [Material], in particular [Material.type].
///  * [kMaterialEdges]
enum MaterialType {
  /// Rectangle using default theme canvas color.
  canvas,

  /// Rounded edges, card theme color.
  card,

  /// A circle, no color by default (used for floating action buttons).
  circle,

  /// Rounded edges, no color by default (used for [MaterialButton] buttons).
  button,

  /// A transparent piece of material that draws ink splashes and highlights.
  ///
  /// A [Material] with the transparency type is similar to a [SplashBox],
  /// and includes configuration for elevation, border, and text style.
  transparency
}

/// The border radii used by the various kinds of material in Material Design.
///
/// See also:
///
///  * [MaterialType]
///  * [Material]
const Map<MaterialType, BorderRadius?> kMaterialEdges = <MaterialType, BorderRadius?>{
  MaterialType.canvas: null,
  MaterialType.card: BorderRadius.all(Radius.circular(2.0)),
  MaterialType.circle: null,
  MaterialType.button: BorderRadius.all(Radius.circular(2.0)),
  MaterialType.transparency: null,
};

/// An interface for creating ink effects on a [Material].
///
/// Typically obtained via [Material.of].
@Deprecated(
  'Use SplashController instead. '
  'Both Material and SplashBox can be used for Splash effects. '
  'This feature was deprecated after v3.24.0-0.2.pre.',
)
typedef MaterialInkController = SplashController;

/// {@template flutter.widgets.splash.SplashController}
/// An interface for creating interactive visual effects on a
/// [SplashBox].
///
/// Typically obtained via [Splash.of].
/// {@endtemplate}
///
/// The [SplashController] handles any number of splashes created
/// by descendant widgets and includes a [didChangeLayout] method
/// that can repaint each [Splash] when the [SplashBox]'s layout
/// changes.
abstract interface class SplashController implements RenderBox {
  /// The color of the surface.
  Color? get color;

  /// Used by this controller's [splashes] to drive their animations.
  TickerProvider get vsync;

  /// Add an [InkFeature], such as an [InkSplash] or an [InkHighlight].
  ///
  /// The ink feature will paint as part of this controller.
  @Deprecated(
    'Use addSplash instead. '
    '"Splash effects" no longer rely on a MaterialInkController. '
    'This feature was deprecated after v3.24.0-0.2.pre.',
  )
  void addInkFeature(Splash feature);

  /// Adds a [Splash], such as an [InkSplash] or an [InkHighlight].
  ///
  /// The splash will paint as part of this controller.
  void addSplash(Splash splash);

  /// Removes a [Splash] added by [addSplash].
  void removeSplash(Splash splash);

  /// A function called when the controller's layout changes.
  ///
  /// [RenderBox.markNeedsPaint] should be called if there are
  /// any active [Splash]es.
  void didChangeLayout();

  /// Gives access to the list of active splashes,
  /// in order to verify behavior during tests.
  @visibleForTesting
  List<Splash> get splashes;
}

/// {@template flutter.widgets.splash.SplashBox}
/// Defines an area for descendant [Splash]es to paint on.
///
/// Used by the [Material] widget to enable button ink effects.
///
/// There are a few reasons that using a `SplashBox` directly might be
/// preferred over a `Material`:
///
/// * A [Decoration] can be added without the [downsides of the `Ink` widget](https://api.flutter.dev/flutter/widgets/Ink-class.html#limitations).
/// * `SplashBox` doesn't use [implicit animations](https://docs.flutter.dev/codelabs/implicit-animations),
///   offering more granular control over UI properties.
///   (This is especially helpful when its properties come from values that
///   are already being animated, such as when `Theme.of(context).colorScheme`
///   inherits from a `MaterialApp`'s `AnimatedTheme`.)
/// * If a Flutter app isn't using the [Material design system](https://m3.material.io/),
///   `SplashBox` is the easiest way to add [Splash]es.
/// {@endtemplate}
///
/// Splashes are shown using a [SplashController], a render object that
/// re-paints each [Splash] when the widget's layout changes.
///
/// {@tool snippet}
/// Generally, a [SplashBox] should be set as the child of widgets that
/// perform clipping and decoration, and it should be the parent of widgets
/// that create [Splash]es.
///
/// Example:
///
/// ```dart
/// ClipRRect(
///   borderRadius: BorderRadius.circular(8),
///   child: ColoredBox(
///     color: color,
///     child: const SplashBox(
///       // add an InkWell here,
///       // or a different child that creates Splash effects
///     ),
///   ),
/// );
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to make a button using a [SplashBox].
///
/// ** See code in examples/api/lib/widgets/splash_box/splash_box.0.dart **
/// {@end-tool}
///
/// See also:
/// * [SplashController], used by this widget to enable splash effects.
/// * [Splash], the class that holds splash effect data.
class SplashBox extends StatefulWidget {
  /// {@macro flutter.widgets.splash.SplashBox}
  const SplashBox({super.key, this.color, this.child});

  /// The value assigned to [SplashController.color].
  ///
  /// The [SplashBox] widget doesn't paint this color, but the [child]
  /// and its descendants can access its value using [Splash.of].
  ///
  /// If non-null, the widget will absorb hit tests.
  final Color? color;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  State<SplashBox> createState() => _SplashBoxState();
}

class _SplashBoxState extends State<SplashBox> with TickerProviderStateMixin {
  final GlobalKey _inkFeatureRenderer = GlobalKey(debugLabel: 'ink renderer');

  @override
  Widget build(BuildContext context) {
    final Color? color = widget.color;
    return NotificationListener<LayoutChangedNotification>(
      onNotification: (LayoutChangedNotification notification) {
        final SplashController controller = _inkFeatureRenderer.currentContext!.findRenderObject()! as SplashController;
        controller.didChangeLayout();
        return false;
      },
      child: _InkFeatures(
        key: _inkFeatureRenderer,
        color: color,
        vsync: this,
        child: widget.child,
      ),
    );
  }
}

/// A piece of material.
///
/// The Material widget is responsible for:
///
/// 1. Clipping: If [clipBehavior] is not [Clip.none], Material clips its widget
///    sub-tree to the shape specified by [shape], [type], and [borderRadius].
///    By default, [clipBehavior] is [Clip.none] for performance considerations.
///    See [Ink] for an example of how this affects clipping [Ink] widgets.
/// 2. Elevation: Material elevates its widget sub-tree on the Z axis by
///    [elevation] pixels, and draws the appropriate shadow.
/// 3. Ink effects: Material shows ink effects implemented by [InkFeature]s
///    like [InkSplash] and [InkHighlight] below its children.
///
/// ## The Material Metaphor
///
/// Material is the central metaphor in Material Design. Each piece of material
/// exists at a given elevation, which influences how that piece of material
/// visually relates to other pieces of material and how that material casts
/// shadows.
///
/// Most user interface elements are either conceptually printed on a piece of
/// material or themselves made of material. Material reacts to user input using
/// [InkSplash] and [InkHighlight] effects. To trigger a reaction on the
/// material, use a [SplashController] obtained via [Material.of].
///
/// In general, the features of a [Material] should not change over time (e.g. a
/// [Material] should not change its [color], [shadowColor] or [type]).
/// Changes to [elevation], [shadowColor] and [surfaceTintColor] are animated
/// for [animationDuration]. Changes to [shape] are animated if [type] is
/// not [MaterialType.transparency] and [ShapeBorder.lerp] between the previous
/// and next [shape] values is supported. Shape changes are also animated
/// for [animationDuration].
///
/// ## Shape
///
/// The shape for material is determined by [shape], [type], and [borderRadius].
///
///  - If [shape] is non null, it determines the shape.
///  - If [shape] is null and [borderRadius] is non null, the shape is a
///    rounded rectangle, with corners specified by [borderRadius].
///  - If [shape] and [borderRadius] are null, [type] determines the
///    shape as follows:
///    - [MaterialType.canvas]: the default material shape is a rectangle.
///    - [MaterialType.card]: the default material shape is a rectangle with
///      rounded edges. The edge radii is specified by [kMaterialEdges].
///    - [MaterialType.circle]: the default material shape is a circle.
///    - [MaterialType.button]: the default material shape is a rectangle with
///      rounded edges. The edge radii is specified by [kMaterialEdges].
///    - [MaterialType.transparency]: the default material shape is a rectangle.
///
/// ## Border
///
/// If [shape] is not null, then its border will also be painted (if any).
///
/// ## Layout change notifications
///
/// If the layout changes (e.g. because there's a list on the material, and it's
/// been scrolled), a [LayoutChangedNotification] must be dispatched at the
/// relevant subtree. This in particular means that transitions (e.g.
/// [SlideTransition]) should not be placed inside [Material] widgets so as to
/// move subtrees that contain [InkResponse]s, [InkWell]s, [Ink]s, or other
/// widgets that use the [InkFeature] mechanism. Otherwise, in-progress ink
/// features (e.g., ink splashes and ink highlights) won't move to account for
/// the new layout.
///
/// ## Painting over the material
///
/// Material widgets will often trigger reactions on their nearest material
/// ancestor. For example, [ListTile.hoverColor] triggers a reaction on the
/// tile's material when a pointer is hovering over it. These reactions will be
/// obscured if any widget in between them and the material paints in such a
/// way as to obscure the material (such as setting a [BoxDecoration.color] on
/// a [DecoratedBox]). To avoid this behavior, use [InkDecoration] to decorate
/// the material itself.
///
/// See also:
///
///  * [MergeableMaterial], a piece of material that can split and re-merge.
///  * [Card], a wrapper for a [Material] of [type] [MaterialType.card].
///  * <https://material.io/design/>
///  * <https://m3.material.io/styles/color/the-color-system/color-roles>
class Material extends StatelessWidget {
  /// Creates a piece of material.
  ///
  /// The [elevation] must be non-negative.
  ///
  /// If a [shape] is specified, then the [borderRadius] property must be
  /// null and the [type] property must not be [MaterialType.circle]. If the
  /// [borderRadius] is specified, then the [type] property must not be
  /// [MaterialType.circle]. In both cases, these restrictions are intended to
  /// catch likely errors.
  const Material({
    super.key,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.animationDuration = kThemeChangeDuration,
    this.child,
  }) : assert(elevation >= 0.0),
       assert(!(shape != null && borderRadius != null)),
       assert(!(identical(type, MaterialType.circle) && (borderRadius != null || shape != null)));

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The kind of material to show (e.g., card or canvas). This
  /// affects the shape of the widget, the roundness of its corners if
  /// the shape is rectangular, and the default color.
  final MaterialType type;

  /// {@template flutter.material.material.elevation}
  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material and the opacity
  /// of the elevation overlay color if it is applied.
  ///
  /// If this is non-zero, the contents of the material are clipped, because the
  /// widget conceptually defines an independent printed piece of material.
  ///
  /// Defaults to 0. Changing this value will cause the shadow and the elevation
  /// overlay or surface tint to animate over [Material.animationDuration].
  ///
  /// The value is non-negative.
  ///
  /// See also:
  ///
  ///  * [ThemeData.useMaterial3] which defines whether a surface tint or
  ///    elevation overlay is used to indicate elevation.
  ///  * [ThemeData.applyElevationOverlayColor] which controls the whether
  ///    an overlay color will be applied to indicate elevation.
  ///  * [Material.color] which may have an elevation overlay applied.
  ///  * [Material.shadowColor] which will be used for the color of a drop shadow.
  ///  * [Material.surfaceTintColor] which will be used as the overlay tint to
  ///    show elevation.
  /// {@endtemplate}
  final double elevation;

  /// The color to paint the material.
  ///
  /// Must be opaque. To create a transparent piece of material, use
  /// [MaterialType.transparency].
  ///
  /// If [ThemeData.useMaterial3] is true then an optional [surfaceTintColor]
  /// overlay may be applied on top of this color to indicate elevation.
  ///
  /// If [ThemeData.useMaterial3] is false and [ThemeData.applyElevationOverlayColor]
  /// is true and [ThemeData.brightness] is [Brightness.dark] then a
  /// semi-transparent overlay color will be composited on top of this
  /// color to indicate the elevation. This is no longer needed for Material
  /// Design 3, which uses [surfaceTintColor].
  ///
  /// By default, the color is derived from the [type] of material.
  final Color? color;

  /// The color to paint the shadow below the material.
  ///
  /// {@template flutter.material.material.shadowColor}
  /// If null and [ThemeData.useMaterial3] is true then [ThemeData]'s
  /// [ColorScheme.shadow] will be used. If [ThemeData.useMaterial3] is false
  /// then [ThemeData.shadowColor] will be used.
  ///
  /// To remove the drop shadow when [elevation] is greater than 0, set
  /// [shadowColor] to [Colors.transparent].
  ///
  /// See also:
  ///  * [ThemeData.useMaterial3], which determines the default value for this
  ///    property if it is null.
  ///  * [ThemeData.applyElevationOverlayColor], which turns elevation overlay
  /// on or off for dark themes.
  /// {@endtemplate}
  final Color? shadowColor;

  /// The color of the surface tint overlay applied to the material color
  /// to indicate elevation.
  ///
  /// {@template flutter.material.material.surfaceTintColor}
  /// Material Design 3 introduced a new way for some components to indicate
  /// their elevation by using a surface tint color overlay on top of the
  /// base material [color]. This overlay is painted with an opacity that is
  /// related to the [elevation] of the material.
  ///
  /// If [ThemeData.useMaterial3] is false, then this property is not used.
  ///
  /// If [ThemeData.useMaterial3] is true and [surfaceTintColor] is not null and
  /// not [Colors.transparent], then it will be used to overlay the base [color]
  /// with an opacity based on the [elevation].
  ///
  /// Otherwise, no surface tint will be applied.
  ///
  /// See also:
  ///
  ///   * [ThemeData.useMaterial3], which turns this feature on.
  ///   * [ElevationOverlay.applySurfaceTint], which is used to implement the
  ///     tint.
  ///   * https://m3.material.io/styles/color/the-color-system/color-roles
  ///     which specifies how the overlay is applied.
  /// {@endtemplate}
  final Color? surfaceTintColor;

  /// The typographical style to use for text within this material.
  final TextStyle? textStyle;

  /// Defines the material's shape as well its shadow.
  ///
  /// {@template flutter.material.material.shape}
  /// If shape is non null, the [borderRadius] is ignored and the material's
  /// clip boundary and shadow are defined by the shape.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@template flutter.material.Material.clipBehavior}
  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  /// {@endtemplate}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// Defines the duration of animated changes for [shape], [elevation],
  /// [shadowColor], [surfaceTintColor] and the elevation overlay if it is applied.
  ///
  /// The default value is [kThemeChangeDuration].
  final Duration animationDuration;

  /// If non-null, the corners of this box are rounded by this
  /// [BorderRadiusGeometry] value.
  ///
  /// Otherwise, the corners specified for the current [type] of material are
  /// used.
  ///
  /// If [shape] is non null then the border radius is ignored.
  ///
  /// Must be null if [type] is [MaterialType.circle].
  final BorderRadiusGeometry? borderRadius;

  /// The ink controller from the closest instance of this class that
  /// encloses the given context within the closest [LookupBoundary].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SplashController? splashController = Material.maybeOf(context);
  /// ```
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  /// * [Splash.maybeOf], which is identical to this method.
  /// * [Material.of], which is similar to this method, but asserts if
  ///   no [SplashController] ancestor is found.
  static SplashController? maybeOf(BuildContext context) => Splash.maybeOf(context);

  /// The ink controller from the closest instance of [Material] that encloses
  /// the given context within the closest [LookupBoundary].
  ///
  /// If no [Material] widget ancestor can be found then this method will assert
  /// in debug mode, and throw an exception in release mode.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SplashController splashController = Material.of(context);
  /// ```
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  /// * [Splash.of], which is identical to this method.
  /// * [Material.maybeOf], which is similar to this method, but returns null if
  ///   no [Material] ancestor is found.
  static SplashController of(BuildContext context) {
    final SplashController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        if (LookupBoundary.debugIsHidingAncestorRenderObjectOfType<SplashController>(context)) {
          throw FlutterError(
            'Material.of() was called with a context that does not have access to a Material widget.\n'
            'The context provided to Material.of() does have a Material widget ancestor, but it is '
            'hidden by a LookupBoundary. This can happen because you are using a widget that looks '
            'for a Material ancestor, but no such ancestor exists within the closest LookupBoundary.\n'
            'The context used was:\n'
            '  $context',
          );
        }
        throw FlutterError(
          'Material.of() was called with a context that does not contain a Material widget.\n'
          'No Material widget ancestor could be found starting from the context that was passed to '
          'Material.of(). This can happen because you are using a widget that looks for a Material '
          'ancestor, but no such ancestor exists.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return controller!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<MaterialType>('type', type));
    properties.add(DoubleProperty('elevation', elevation, defaultValue: 0.0));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    properties.add(ColorProperty('surfaceTintColor', surfaceTintColor, defaultValue: null));
    textStyle?.debugFillProperties(properties, prefix: 'textStyle.');
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>('borderOnForeground', borderOnForeground, defaultValue: true));
    properties.add(DiagnosticsProperty<BorderRadiusGeometry>('borderRadius', borderRadius, defaultValue: null));
  }

  /// The default radius of an ink splash in logical pixels.
  static const double defaultSplashRadius = 35.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? backgroundColor = color ?? switch (type) {
      MaterialType.canvas => theme.canvasColor,
      MaterialType.card => theme.cardColor,
      MaterialType.button || MaterialType.circle || MaterialType.transparency => null,
    };
    final Color modelShadowColor = shadowColor
        ?? (theme.useMaterial3 ? theme.colorScheme.shadow : theme.shadowColor);
    final bool isTransparent = type == MaterialType.transparency;
    assert(
      backgroundColor != null || isTransparent,
      'If Material type is not MaterialType.transparency, a color must '
      'either be passed in through the `color` property, or be defined '
      'in the theme (ex. canvasColor != null if type is set to '
      'MaterialType.canvas)',
    );

    Widget? contents = child;
    if (contents != null) {
      contents = AnimatedDefaultTextStyle(
        style: textStyle ?? theme.textTheme.bodyMedium!,
        duration: animationDuration,
        child: contents,
      );
    }
    contents = SplashBox(
      color: isTransparent ? null : backgroundColor,
      child: contents,
    );

    ShapeBorder? shape = borderRadius != null
        ? RoundedRectangleBorder(borderRadius: borderRadius!)
        : this.shape;

    // PhysicalModel has a temporary workaround for a performance issue that
    // speeds up rectangular non transparent material (the workaround is to
    // skip the call to ui.Canvas.saveLayer if the border radius is 0).
    // Until the saveLayer performance issue is resolved, we're keeping this
    // special case here for canvas material type that is using the default
    // shape (rectangle). We could go down this fast path for explicitly
    // specified rectangles (e.g shape RoundedRectangleBorder with radius 0, but
    // we choose not to as we want the change from the fast-path to the
    // slow-path to be noticeable in the construction site of Material.
    if (type == MaterialType.canvas && shape == null) {
      final Color color = theme.useMaterial3
        ? ElevationOverlay.applySurfaceTint(backgroundColor!, surfaceTintColor, elevation)
        : ElevationOverlay.applyOverlay(context, backgroundColor!, elevation);

      return AnimatedPhysicalModel(
        curve: Curves.fastOutSlowIn,
        duration: animationDuration,
        clipBehavior: clipBehavior,
        elevation: elevation,
        color: color,
        shadowColor: modelShadowColor,
        animateColor: false,
        child: contents,
      );
    }

    shape ??= switch (type) {
      MaterialType.circle => const CircleBorder(),
      MaterialType.canvas || MaterialType.transparency => const RoundedRectangleBorder(),
      MaterialType.card || MaterialType.button => const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
    };

    if (isTransparent) {
      return ClipPath(
        clipper: ShapeBorderClipper(
          shape: shape,
          textDirection: Directionality.maybeOf(context),
        ),
        clipBehavior: clipBehavior,
        child: _ShapeBorderPaint(shape: shape, child: contents),
      );
    }

    return _MaterialInterior(
      curve: Curves.fastOutSlowIn,
      duration: animationDuration,
      shape: shape,
      borderOnForeground: borderOnForeground,
      clipBehavior: clipBehavior,
      elevation: elevation,
      color: backgroundColor!,
      shadowColor: modelShadowColor,
      surfaceTintColor: surfaceTintColor,
      child: contents,
    );
  }
}

class _RenderInkFeatures extends RenderProxyBox implements SplashController {
  _RenderInkFeatures({this.color, required this.vsync}) : super(null);

  /// Enables [InkFeature] animations.
  ///
  /// This class should exist in a 1:1 relationship with a [_SplashBoxState]
  /// object, since there's no current support for dynamically changing
  /// the ticker provider.
  @override
  final TickerProvider vsync;

  // This is here to satisfy the SplashController contract.
  // The actual painting of this color is usually done by the SplashBox's
  // parent.
  @override
  Color? color;

  bool get absorbHitTest => color != null;

  @override
  @visibleForTesting
  final List<Splash> splashes = <Splash>[];

  @visibleForTesting
  @Deprecated(
    'Use debugSplashes instead. '
    'Splash effects are no longer exclusive to Material design. '
    'This feature was deprecated after v3.24.0-0.2.pre.',
  )
  List<Splash> get debugInkFeatures => splashes;

  @override
  void addSplash(Splash splash) {
    assert(!splash.debugDisposed);
    assert(splash.controller == this);
    assert(!splashes.contains(splash));
    splashes.add(splash);
    markNeedsPaint();
  }

  @override
  void addInkFeature(Splash feature) => addSplash(feature);

  @override
  void removeSplash(Splash splash) {
    splashes.remove(splash);
    markNeedsPaint();
  }

  @override
  void didChangeLayout() {
    if (splashes.isNotEmpty) {
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => absorbHitTest;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (splashes.isNotEmpty) {
      final Canvas canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.clipRect(Offset.zero & size);
      for (final Splash splash in splashes) {
        splash.paint(canvas);
      }
      canvas.restore();
    }
    super.paint(context, offset);
  }
}

class _InkFeatures extends SingleChildRenderObjectWidget {
  const _InkFeatures({
    super.key,
    this.color,
    required this.vsync,
    super.child,
  });

  final Color? color;

  /// This [TickerProvider] will always be a [_SplashBoxState] object.
  ///
  /// This relationship is 1:1 and cannot change for the lifetime of the
  /// widget's state.
  final TickerProvider vsync;

  @override
  SplashController createRenderObject(BuildContext context) {
    return _RenderInkFeatures(color: color, vsync: vsync);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderInkFeatures renderObject) {
    renderObject.color = color;
    assert(vsync == renderObject.vsync);
  }
}

/// A visual reaction on a piece of [Material].
///
/// To add an ink feature to a piece of [Material], obtain the
/// [MaterialInkController] via [Material.of] and call
/// [MaterialInkController.addInkFeature].
@Deprecated(
  'Use Splash instead. '
  'Splash effects no longer rely on a MaterialInkController. '
  'This feature was deprecated after v3.24.0-0.2.pre.',
)
typedef InkFeature = Splash;

/// An animation projected onto a [SplashBox] in response to a
/// user gesture.
///
/// Subclasses call [confirm] when an input gesture is recognized. For
/// example, a tap event might trigger a splash that's confirmed
/// when the corresponding [GestureDetector.onTapUp] event is seen.
///
/// Subclasses call [cancel] when an input gesture is aborted before it
/// is recognized. For example, a tap event might trigger a splash
/// that's canceled when the pointer is dragged out of the reference
/// box.
///
/// See also:
///
/// * [SplashBox], the widget that paints splashes. This widget uses
///   a [SplashController] to repaint splashes when the layout of the
///   widget changes.
/// * [SplashFactory], a class that creates splashes using a specific
///   function signature.
/// * [InkResponse], which creates splashes using a [SplashFactory].
abstract class Splash {
  /// Creates a splash effect.
  Splash({
    required this.controller,
    required this.referenceBox,
    Color? color,
    ShapeBorder? customBorder,
    this.onRemoved,
  }) : _color = color,
       _customBorder = customBorder {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:flutter/widgets.dart',
        className: '$Splash',
        object: this,
      );
    }
  }

  /// The closest ancestor [SplashController] found within the closest
  /// [LookupBoundary].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SplashController? splashController = Splash.maybeOf(context);
  /// ```
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  /// * [Splash.of], which is similar to this method, but asserts if
  ///   no [SplashController] ancestor is found.
  static SplashController? maybeOf(BuildContext context) {
    return LookupBoundary.findAncestorRenderObjectOfType<SplashController>(context);
  }

  /// The closest ancestor [SplashController] found within the closest
  /// [LookupBoundary].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SplashController splashController = Splash.of(context);
  /// ```
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  /// * [Splash.maybeOf], which is similar to this method, but returns `null` if
  ///   no [SplashController] ancestor is found.
  static SplashController of(BuildContext context) {
    final SplashController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        if (LookupBoundary.debugIsHidingAncestorRenderObjectOfType<SplashController>(context)) {
          throw FlutterError(
            'Splash.of() was called with a context that does not have access to a SplashController.\n'
            'The context provided to Splash.of() does have a SplashController ancestor, but it is '
            'hidden by a LookupBoundary. This can happen because you are using a widget that looks '
            'for an SplashController ancestor, but no such ancestor exists within the closest LookupBoundary.\n'
            'The context used was:\n'
            '  $context',
          );
        }
        throw FlutterError(
          'Splash.of() was called with a context that does not contain a SplashController.\n'
          'No SplashController ancestor could be found starting from the context that was passed to '
          'Splash.of(). This can happen because you are using a widget that looks for a SplashController '
          'ancestor, but no such ancestor exists.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return controller!;
  }

  /// Computes the [Matrix4] that allows [fromRenderObject] to perform paint
  /// in [toRenderObject]'s coordinate space.
  ///
  /// Typically, this is used to find the transformation to apply to the [controller]
  /// so it matches the [referenceBox].
  ///
  /// Returns null if either [fromRenderObject] or [toRenderObject] is not
  /// in the same render tree, or either of them is in an offscreen subtree
  /// (see [RenderObject.paintsChild]).
  static Matrix4? getPaintTransform(
    RenderObject fromRenderObject,
    RenderObject toRenderObject,
  ) {
    // The paths to fromRenderObject and toRenderObject's common ancestor.
    final List<RenderObject> fromPath = <RenderObject>[fromRenderObject];
    final List<RenderObject> toPath = <RenderObject>[toRenderObject];

    RenderObject from = fromRenderObject;
    RenderObject to = toRenderObject;

    while (!identical(from, to)) {
      final int fromDepth = from.depth;
      final int toDepth = to.depth;

      if (fromDepth >= toDepth) {
        final RenderObject? fromParent = from.parent;
        // Return early if the 2 render objects are not in the same render tree,
        // or either of them is offscreen and thus won't get painted.
        if (fromParent is! RenderObject || !fromParent.paintsChild(from)) {
          return null;
        }
        fromPath.add(fromParent);
        from = fromParent;
      }

      if (fromDepth <= toDepth) {
        final RenderObject? toParent = to.parent;
        if (toParent is! RenderObject || !toParent.paintsChild(to)) {
          return null;
        }
        toPath.add(toParent);
        to = toParent;
      }
    }
    assert(identical(from, to));

    final Matrix4 transform = Matrix4.identity();
    final Matrix4 inverseTransform = Matrix4.identity();

    for (int index = toPath.length - 1; index > 0; index -= 1) {
      toPath[index].applyPaintTransform(toPath[index - 1], transform);
    }
    for (int index = fromPath.length - 1; index > 0; index -= 1) {
      fromPath[index].applyPaintTransform(fromPath[index - 1], inverseTransform);
    }

    final double det = inverseTransform.invert();
    return det != 0 ? (inverseTransform..multiply(transform)) : null;
  }

  /// Called when the user input that triggered this feature's appearance was confirmed.
  ///
  /// Typically causes the [Splash] to propagate faster across the surface.
  /// By default this method does nothing.
  void confirm() {}

  /// Called when the user input that triggered this feature's appearance was canceled.
  ///
  /// Typically causes the [Splash] to gradually disappear.
  /// By default this method does nothing.
  void cancel() {}

  /// {@macro flutter.widgets.splash.SplashController}
  final SplashController controller;

  /// The render box whose visual position defines the splash effect's
  /// frame of reference.
  final RenderBox referenceBox;

  /// Called when the splash is no longer visible on the material.
  final VoidCallback? onRemoved;

  /// If asserts are enabled, this value tracks whether the feature has been disposed.
  ///
  /// Ensures that [dispose] is only called once, and [paint] is not called afterward.
  bool debugDisposed = false;

  /// A (typically translucent) color used for this [Splash].
  Color get color {
    assert(
      _color != null,
      'The type "$runtimeType" inherits from Splash but did not set a color value.\n'
      'Consider setting the Splash.color in its constructor, '
      'or using the Splash in a context that does not need access to it.',
    );
    return _color!;
  }
  Color? _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    controller.markNeedsPaint();
  }

  /// A [ShapeBorder] that may optionally be applied to the [Splash].
  ShapeBorder? get customBorder => _customBorder;
  ShapeBorder? _customBorder;
  set customBorder(ShapeBorder? value) {
    if (value == _customBorder) {
      return;
    }
    _customBorder = value;
    controller.markNeedsPaint();
  }

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

  /// Determines the appropriate transformation using [getPaintTransform].
  ///
  /// Then, [paintFeature] creates the [Splash] within the [referenceBox].
  void paint(Canvas canvas) {
    assert(referenceBox.attached);
    assert(!debugDisposed);
    final Matrix4? transform = getPaintTransform(controller, referenceBox);
    if (transform != null) {
      paintFeature(canvas, transform);
    }
  }

  /// Override this method to paint the splash.
  ///
  /// The [transform] argument gives the conversion from the canvas's
  /// coordinate system to the coordinate system of the [referenceBox].
  @protected
  void paintFeature(Canvas canvas, Matrix4 transform);

  /// Frees up the splash effect's associated resources.
  @mustCallSuper
  void dispose() {
    assert(!debugDisposed);
    assert((() => debugDisposed = true)());
    // TODO(polina-c): stop duplicating code across disposables
    // https://github.com/flutter/flutter/issues/137435
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    controller.removeSplash(this);
    onRemoved?.call();
  }

  @override
  String toString() => describeIdentity(this);
}

/// An interpolation between two [ShapeBorder]s.
///
/// This class specializes the interpolation of [Tween] to use [ShapeBorder.lerp].
class ShapeBorderTween extends Tween<ShapeBorder?> {
  /// Creates a [ShapeBorder] tween.
  ///
  /// the [begin] and [end] properties may be null; see [ShapeBorder.lerp] for
  /// the null handling semantics.
  ShapeBorderTween({super.begin, super.end});

  /// Returns the value this tween has at the given animation clock value.
  @override
  ShapeBorder? lerp(double t) {
    return ShapeBorder.lerp(begin, end, t);
  }
}

/// The interior of non-transparent material.
///
/// Animates [elevation], [shadowColor], and [shape].
class _MaterialInterior extends ImplicitlyAnimatedWidget {
  /// Creates a const instance of [_MaterialInterior].
  ///
  /// The [elevation] must be specified and greater than or equal to zero.
  const _MaterialInterior({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    required this.elevation,
    required this.color,
    required this.shadowColor,
    required this.surfaceTintColor,
    super.curve,
    required super.duration,
  }) : assert(elevation >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder shape;

  /// Whether to paint the border in front of the child.
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the child.
  final bool borderOnForeground;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The target z-coordinate at which to place this physical object relative
  /// to its parent.
  ///
  /// The value is non-negative.
  final double elevation;

  /// The target background color.
  final Color color;

  /// The target shadow color.
  final Color shadowColor;

  /// The target surface tint color.
  final Color? surfaceTintColor;

  @override
  _MaterialInteriorState createState() => _MaterialInteriorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    description.add(DoubleProperty('elevation', elevation));
    description.add(ColorProperty('color', color));
    description.add(ColorProperty('shadowColor', shadowColor));
  }
}

class _MaterialInteriorState extends AnimatedWidgetBaseState<_MaterialInterior> {
  Tween<double>? _elevation;
  ColorTween? _surfaceTintColor;
  ColorTween? _shadowColor;
  ShapeBorderTween? _border;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _elevation = visitor(
      _elevation,
      widget.elevation,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _shadowColor = visitor(
      _shadowColor,
      widget.shadowColor,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
    _surfaceTintColor = widget.surfaceTintColor != null
      ? visitor(
          _surfaceTintColor,
          widget.surfaceTintColor,
              (dynamic value) => ColorTween(begin: value as Color),
        ) as ColorTween?
      : null;
    _border = visitor(
      _border,
      widget.shape,
      (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder),
    ) as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = _border!.evaluate(animation)!;
    final double elevation = _elevation!.evaluate(animation);
    final Color color = Theme.of(context).useMaterial3
      ? ElevationOverlay.applySurfaceTint(widget.color, _surfaceTintColor?.evaluate(animation), elevation)
      : ElevationOverlay.applyOverlay(context, widget.color, elevation);
    final Color shadowColor = _shadowColor!.evaluate(animation)!;

    return PhysicalShape(
      clipper: ShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      clipBehavior: widget.clipBehavior,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      child: _ShapeBorderPaint(
        shape: shape,
        borderOnForeground: widget.borderOnForeground,
        child: widget.child,
      ),
    );
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
  });

  final Widget child;
  final ShapeBorder shape;
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: borderOnForeground ? null : _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
      foregroundPainter: borderOnForeground ? _ShapeBorderPainter(shape, Directionality.maybeOf(context)) : null,
      child: child,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}
