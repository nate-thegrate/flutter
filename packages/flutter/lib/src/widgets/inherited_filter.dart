// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'package:flutter/material.dart';
library;

import 'package:collection/collection.dart';

import 'framework.dart';

export 'package:collection/collection.dart' show Equality;

/// An object that specifies an [Equality].
///
/// If a selector for an [InheritedFilter] implements this interface,
/// its equality is used in place of the inherited filter's default
/// to determine whether rebuilding takes place.
abstract interface class EqualityFilter {
  /// The [Equality] to use when using this equality filter
  /// to compare two values.
  Equality<Object?>? get equality;
}

/// An `InheritedWidget` that notifies dependents based on their **selector**s
/// and a configurable [Equality] relationship.
///
/// {@template flutter.widgets.InheritedFilter}
/// [InheritedFilter] uses a **selector** as the aspect for
/// [BuildContext.dependOnInheritedWidgetOfExactType] calls.
/// Dependents are notified when the [InheritedFilter] is rebuilt, unless
/// [InheritedFilter.select] outputs a value equal to the previous one.
///
/// (For more detailed information, see [InheritedFilter.select].)
/// {@endtemplate}
///
/// {@tool dartpad}
/// This example shows an [InheritedFilter] that uses [String] as its
/// selector type. It only sends a notification when there's a change to
/// the results filtered by the search query.
///
/// ** See code in examples/api/lib/widgets/inherited_filter/inherited_filter.0.dart **
/// {@end-tool}
///
/// {@tool snippet}
/// ## Creating the `of` / `maybeOf` methods
///
/// To depend on an [InheritedFilter] widget, pass the selector as the `aspect`
/// in [BuildContext.dependOnInheritedWidgetOfExactType], and then use it in a
/// [InheritedFilter.select] call.
///
/// ```dart
/// typedef LabelSelector = String Function(Map<String, dynamic> json);
///
/// class MyLabel extends InheritedFilter<LabelSelector> {
///   const InheritedFilter({
///     super.key,
///     required this.json,
///     required super.child,
///   });
///
///   final Map<String, dynamic> json;
///
///   static String of(BuildContext context, LabelSelector selector) {
///     final MyLabel label = context.dependOnInheritedWidgetOfExactType<MyLabel>(aspect: selector)!;
///     return label.select(selector);
///   }
///
///   @override
///   String select(LabelSelector selector) => selector(json);
/// }
/// ```
/// {@end-tool}
///
/// {@macro flutter.widgets.InheritedWidget.subtypes}
abstract class InheritedFilter<Selector> extends ProxyWidget implements InheritedWidget, EqualityFilter {
  /// Creates an `InheritedWidget` that notifies dependents
  /// based on their [Selector]s.
  const InheritedFilter({super.key, required super.child});

  /// [InheritedFilter] subclasses override this method so that dependents
  /// are notified when there's a change to the output of any of their [Selector]s.
  ///
  /// {@tool snippet}
  /// Often, the [selector] is a [Function], and [select] simply returns its output.
  /// Example:
  ///
  /// ```dart
  /// typedef LabelSelector = String Function(Map<String, dynamic> json);
  ///
  /// class MyLabel extends InheritedFilter<LabelSelector> {
  ///   const InheritedFilter({
  ///     super.key,
  ///     required this.json,
  ///     required super.child,
  ///   });
  ///
  ///   final Map<String, dynamic> json;
  ///
  ///   static String of(BuildContext context, LabelSelector selector) {
  ///     final MyLabel label = context.dependOnInheritedWidgetOfExactType<MyLabel>(aspect: selector)!;
  ///     return label.select(selector);
  ///   }
  ///
  ///   @override
  ///   String select(LabelSelector selector) => selector(json);
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// There are a few ways for the [InheritedFilter.select] method to engender
  /// useful equality checks, so dependents are notified to rebuild only when
  /// there's a relevant change:
  ///
  ///  1. Return a `const` value, such as [Brightness.dark],
  ///     [MouseCursor.defer], or `const SawTooth(3)`.
  ///  2. Return an object that supports stable equality checks, e.g.
  ///     an instance of [num], [EdgeInsets], [TextStyle], or [BoxDecoration].
  ///     A custom class declaration can be set up the same way, by overriding
  ///     the [Object.operator==] and [Object.hashCode] fields. Alternatively,
  ///     [Record] types support stable equality without additional setup.
  ///  3. Override the [EqualityFilter.equality] getter to define a custom
  ///     relationship, such as [MapEquality] or [CaseInsensitiveEquality].
  ///     This can be done with the [InheritedFilter] class, or alternatively,
  ///     any selector object that implements the [EqualityFilter] interface
  ///     can individually customize the [Equality] relationship for its results.
  //
  // TODO(nate-thegrate): example app!
  Object? select(Selector selector);

  /// Compares the result of [select] with the previous result to determine
  /// whether the dependent should rebuild.
  ///
  /// The default implementation, [DefaultEquality], uses the existing
  /// [Object.operator==] to determine equality.
  @override
  Equality<Object?> get equality => const DefaultEquality<Object?>();

  /// Whether the [InheritedFilterElement] should begin the work of notifying
  /// dependents when its widget is rebuilt. If the result is `false`,
  /// [InheritedFilterElement.notifyClients] is skipped entirely.
  ///
  /// Overriding this method can boost performance if the widget typically
  /// has a large number of dependents.
  /// (Or better yet—the widget that builds this [InheritedFilter] could be
  /// structured to only rebuild when there's a relevant change.)
  @override
  bool updateShouldNotify(covariant InheritedFilter<Selector> oldWidget) => true;

  @override
  InheritedFilterElement<Selector> createElement() => InheritedFilterElement<Selector>(this);
}
