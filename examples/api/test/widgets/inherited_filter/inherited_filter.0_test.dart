// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_api_samples/widgets/inherited_filter/inherited_filter.0.dart' as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tapping buttons produces the intended behavior', (WidgetTester tester) async {
    await tester.pumpWidget(const example.InheritedFilterExampleApp());

    final Finder captainFinder = find.byKey(
      Key(example.Poem.oCaptainMyCaptain.title),
    );
    await tester.tap(find.text('O Captain! My Captain!'));
    await tester.pumpAndSettle();
    expect(captainFinder, findsOneWidget);

    await tester.tap(find.backButton());
    await tester.pumpAndSettle();
    expect(captainFinder, findsNothing); // fallen cold and dead :(

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();
    expect(find.byType(example.PoemCheckboxes), findsOneWidget);
  });

  testWidgets('InheritedFilter notifies only when filtered results change', (WidgetTester tester) async {
    await tester.pumpWidget(const example.InheritedFilterExampleApp());

    await tester.enterText(find.byType(TextField), 'O Captain! My Captain!');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    Future<void> tapPoemCheckbox(example.Poem poem) {
      final Finder checkboxFinder = find.descendant(
        of: find.byType(example.PoemCheckboxes),
        matching: find.text(poem.title),
      );
      return tester.tap(checkboxFinder);
    }

    int getNotifyCount() {
      final example.NotifyCount widget = tester.widget(
        find.byType(example.NotifyCount),
      );
      return widget.notifier!.value;
    }
    final int notifyCount = getNotifyCount();


    await tapPoemCheckbox(example.Poem.inheritedWidgetHaiku);
    await tester.pumpAndSettle();
    expect(getNotifyCount(), notifyCount);

    await tapPoemCheckbox(example.Poem.oCaptainMyCaptain);
    await tester.pumpAndSettle();
    expect(getNotifyCount(), notifyCount + 1);
  });
}
