// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_api_samples/widgets/transitions/rotation_transition.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows flutter logo in rotation transition', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.RotationTransitionExampleApp());
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RotationTransition &&
            widget.turns is CurvedAnimation &&
            (widget.turns as CurvedAnimation).curve == Curves.elasticOut,
      ),
      findsOneWidget,
    );
    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.byType(Padding), findsAtLeast(1));
    expect(
      find.descendant(
        of: find.byType(Center),
        matching: find.byType(FlutterLogo),
      ),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate((Widget widget) {
        return switch (widget) {
          RotationTransition(turns: CurvedAnimation(value: 0.0, status: AnimationStatus.forward)) =>
            true,
          _ => false,
        };
      }),
      findsOneWidget,
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(
      find.byWidgetPredicate((Widget widget) {
        return switch (widget) {
          RotationTransition(
            turns: CurvedAnimation(
              parent: AnimationController(value: 0.5),
              status: AnimationStatus.reverse,
            ),
          ) =>
            true,
          _ => false,
        };
      }),
      findsOneWidget,
    );
  });
}
