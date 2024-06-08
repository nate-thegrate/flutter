// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'material.dart';
import 'material_localizations.dart';
import 'scaffold.dart' show Scaffold, ScaffoldMessenger;

// Examples can assume:
// late BuildContext context;

/// Asserts that the given context has a [Material] ancestor within the closest
/// [LookupBoundary].
///
/// Used by many Material Design widgets to make sure that they are
/// only used in contexts where they can print ink onto some material.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterial(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This method can be expensive (it walks the element tree).
///
/// Does nothing if asserts are disabled. Always returns true.
@Deprecated(
  'Use debugCheckSplash instead. '
  'With the addition of SplashBox, a Material widget is no longer required. '
  'This feature was deprecated after v3.24.0-0.2.pre.',
)
bool debugCheckHasMaterial(BuildContext context) => debugCheckSplash(context);

/// Asserts that the given context has a [SplashBox] ancestor within the closest
/// [LookupBoundary].
///
/// Used by many widgets to make sure that they are only used in contexts where
/// they have a [SplashBox] or other widget that enables [Splash] effects.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckSplash(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This method can be expensive (it walks the element tree).
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckSplash(BuildContext context) {
  assert(() {
    if (Splash.maybeOf(context) == null) {
      final bool hiddenByBoundary = LookupBoundary.debugIsHidingAncestorRenderObjectOfType<SplashController>(context);
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No SplashController found${hiddenByBoundary ? ' within the closest LookupBoundary' : ''}.'),
        if (hiddenByBoundary)
          ErrorDescription(
            "There is an ancestor SplashController, but it's hidden by a LookupBoundary.",
          ),
        ErrorDescription(
          '${context.widget.runtimeType} widgets use a SplashController to show '
          'Splash effects, and no SplashController ancestor was found within '
          'the closest LookupBoundary.\n',
        ),
        ErrorHint(
          'A SplashController can be provided by an ancestor SplashBox; alternatively, '
          'there are several viable options from the Material libary, including '
          'Material, Card, Dialog, Drawer, and Scaffold.',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: SplashController),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [Localizations] ancestor that contains
/// a [MaterialLocalizations] delegate.
///
/// Used by many Material Design widgets to make sure that they are
/// only used in contexts where they have access to localizations.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterialLocalizations(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This function has the side-effect of establishing an inheritance
/// relationship with the nearest [Localizations] widget (see
/// [BuildContext.dependOnInheritedWidgetOfExactType]). This is ok if the caller
/// always also calls [Localizations.of] or [Localizations.localeOf].
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasMaterialLocalizations(BuildContext context) {
  assert(() {
    if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No MaterialLocalizations found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require MaterialLocalizations '
          'to be provided by a Localizations widget ancestor.',
        ),
        ErrorDescription(
          'The material library uses Localizations to generate messages, '
          'labels, and abbreviations.',
        ),
        ErrorHint(
          'To introduce a MaterialLocalizations, either use a '
          'MaterialApp at the root of your application to include them '
          'automatically, or add a Localization widget with a '
          'MaterialLocalizations delegate.',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: MaterialLocalizations),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [Scaffold] ancestor.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasScaffold(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This method can be expensive (it walks the element tree).
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasScaffold(BuildContext context) {
  assert(() {
    if (context.widget is! Scaffold && context.findAncestorWidgetOfExactType<Scaffold>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No Scaffold widget found.'),
        ErrorDescription('${context.widget.runtimeType} widgets require a Scaffold widget ancestor.'),
        ...context.describeMissingAncestor(expectedAncestorType: Scaffold),
        ErrorHint(
          'Typically, the Scaffold widget is introduced by the MaterialApp or '
          'WidgetsApp widget at the top of your application widget tree.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [ScaffoldMessenger] ancestor.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasScaffoldMessenger(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This method can be expensive (it walks the element tree).
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasScaffoldMessenger(BuildContext context) {
  assert(() {
    if (context.findAncestorWidgetOfExactType<ScaffoldMessenger>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No ScaffoldMessenger widget found.'),
        ErrorDescription('${context.widget.runtimeType} widgets require a ScaffoldMessenger widget ancestor.'),
        ...context.describeMissingAncestor(expectedAncestorType: ScaffoldMessenger),
        ErrorHint(
          'Typically, the ScaffoldMessenger widget is introduced by the MaterialApp '
          'at the top of your application widget tree.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}
