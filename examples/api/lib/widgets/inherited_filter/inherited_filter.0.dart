// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [InheritedFilter].

void main() => runApp(const InheritedFilterExampleApp());

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum Poem {
  oCaptainMyCaptain(
    title: 'O Captain! My Captain!',
    author: 'Walt Whitman',
  ),
  sonnet18(
    title: 'Sonnet 18',
    author: 'William Shakespeare',
  ),
  theRoadNotTaken(
    title: 'The Road Not Taken',
    author: 'Robert Frost',
  ),
  inheritedWidgetHaiku(
    title: 'Inherited Widget Haiku',
    author: '(anonymous)',
  );

  const Poem({required this.title, required this.author});

  final String title;
  final String author;

  String get content => poems[this]!;

  void view() {
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (BuildContext context) => _PoemPage(this)),
    );
  }
}

class Poems extends InheritedWidget {
  Poems({
    super.key,
    required Iterable<Poem> enabledPoems,
    required super.child,
  }) : enabled = UnmodifiableSetView<Poem>(enabledPoems.toSet());

  final Set<Poem> enabled;

  static Set<Poem> of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Poems>()!.enabled;
  }

  static Iterable<Poem> inOrder(BuildContext context) {
    return Poem.values.where(Poems.of(context).contains);
  }

  static void modify(Poem poem, bool enabled) {
    final BuildContext context = navigatorKey.currentContext!;
    context.findAncestorStateOfType<_InheritedFilterExampleAppState>()!.togglePoem(poem, enabled);
  }

  /// Using [Iterable.toSet] in the constructor
  /// ensures that the two sets being compared are unique instances.
  @override
  bool updateShouldNotify(Poems oldWidget) {
    return !const SetEquality<Poem>().equals(enabled, oldWidget.enabled);
  }
}

typedef Line = (String text, Poem source);

class InheritedPoemFilter extends InheritedFilter<String> {
  const InheritedPoemFilter({
    super.key,
    required this.allLines,
    required super.child,
  });

  final List<Line> allLines;

  static Iterable<Line> of(BuildContext context, String selector) {
    return context
      .dependOnInheritedWidgetOfExactType<InheritedPoemFilter>(aspect: selector)!
      .select(selector);
  }

  /// [InheritedPoemFilter.select] outputs each line of text that contains
  /// the search query stored in [selector].
  @override
  Iterable<Line> select(String selector) {
    return allLines.where(
      (Line line) => line.$1.toLowerCase().contains(selector.toLowerCase()),
    );
  }

  /// By default, an [Iterable] object is only equal to itself,
  /// so without this [equality], the widget would notify dependents every time
  /// a new iterable is passed.
  @override
  Equality<Iterable<Line>> get equality => const IterableEquality<Line>();

  @override
  InheritedFilterElement<String> createElement() => _InheritedPoemFilterElement(this);
}

class _InheritedPoemFilterElement extends InheritedFilterElement<String> {
  _InheritedPoemFilterElement(super.widget);

  @override
  void notifyDependent(InheritedFilter<String> oldWidget, Element dependent) {
    NotifyCount.increment();
    super.notifyDependent(oldWidget, dependent);
  }
}

class NotifyCount extends InheritedNotifier<ValueNotifier<int>> {
  const NotifyCount({super.key, super.notifier, required super.child});

  static void increment() {
    final BuildContext context = navigatorKey.currentContext!;
    final NotifyCount widget = context.getInheritedWidgetOfExactType<NotifyCount>()!;
    final ValueNotifier<int> counter = widget.notifier!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      counter.value += 1;
    });
  }

  static int of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NotifyCount>()!.notifier!.value;
  }
}

class InheritedFilterExampleApp extends StatefulWidget {
  const InheritedFilterExampleApp({super.key});

  @override
  State<InheritedFilterExampleApp> createState() => _InheritedFilterExampleAppState();
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Inherited Filter example'),
      surfaceTintColor: ColorScheme.of(context).surface,
      actions: <Widget>[
        Tooltip(
          message: 'Total number of notifications the InheritedFilter has sent.',
          child: Text('filter notifications: ${NotifyCount.of(context)}'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _InheritedFilterExampleAppState extends State<InheritedFilterExampleApp> {
  final Set<Poem> enabled = <Poem>{Poem.oCaptainMyCaptain};

  void togglePoem(Poem poem, bool active) {
    setState(() {
      if (active) {
        enabled.add(poem);
      } else {
        enabled.remove(poem);
      }
    });
  }

  final ValueNotifier<int> _notifyCount = ValueNotifier<int>(0);

  @override
  void dispose() {
    _notifyCount.dispose();
    super.dispose();
  }

  static final ColorScheme colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFF408060),
    dynamicSchemeVariant: DynamicSchemeVariant.neutral,
  );

  /// Style for the button at the bottom-center of the screen.
  static final ButtonStyle semicircle = ElevatedButton.styleFrom(
    backgroundColor: colors.primaryFixed,
    foregroundColor: colors.onPrimaryFixed,
    overlayColor: colors.onPrimaryFixedVariant,
    padding: EdgeInsets.zero,
    shape: const CircleBorder(),
  );

  static final ThemeData theme = ThemeData(
    colorScheme: colors,
    elevatedButtonTheme: ElevatedButtonThemeData(style: semicircle),
  );

  @override
  Widget build(BuildContext context) {
    const Widget button = FractionalTranslation(
      translation: Offset(0, 0.5),
      child: SizedBox.square(
        dimension: 96,
        child: Tooltip(
          message: 'choose which poems are shown',
          child: ElevatedButton(
            clipBehavior: Clip.antiAlias,
            onPressed: PoemCheckboxes.show,
            child: Align(
              alignment: Alignment(0, -2 / 3),
              child: Icon(Icons.expand_less, size: 36),
            ),
          ),
        ),
      ),
    );

    return Poems(
      enabledPoems: enabled,
      child: NotifyCount(
        notifier: _notifyCount,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            appBar: _AppBar(),
            body: Center(child: InheritedFilterExample()),
            floatingActionButton: button,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        ),
      ),
    );
  }
}

class InheritedFilterExample extends StatelessWidget {
  const InheritedFilterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedPoemFilter(
      allLines: <Line>[
        for (final Poem poem in Poems.inOrder(context))
          if (poem.content case final String text)
            for (final String line in text.split('\n')) (line, poem),
      ],
      child: const FilteredPoems(),
    );
  }
}

class FilteredPoems extends StatefulWidget {
  const FilteredPoems({super.key});

  @override
  State<FilteredPoems> createState() => _FilteredPoemsState();
}

class _FilteredPoemsState extends State<FilteredPoems> {
  String text = '';
  void updateText(String? newText) {
    if (newText == null || newText == text) {
      return;
    }

    setState(() {
      text = newText;
    });
  }

  Widget parseText(String line) {
    final int textLength = text.length;
    final int lineLength = line.length;

    int index = 0;
    final List<InlineSpan> result = <InlineSpan>[];
    for (final String snippet in line.toLowerCase().split(text.toLowerCase())) {
      result.add(
        TextSpan(text: line.substring(index, index + snippet.length)),
      );
      index += snippet.length;
      if (index + textLength < lineLength) {
        result.add(
          TextSpan(
            text: line.substring(index, index + textLength),
            style: const TextStyle(backgroundColor: Color(0xFFF8FF80)),
          ),
        );
        index += textLength;
      }
    }
    return Text.rich(TextSpan(children: result));
  }

  @override
  Widget build(BuildContext context) {
    final bool usingFilter = text.isNotEmpty;

    final Widget textField = ColoredBox(
      color: ColorScheme.of(context).surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          onChanged: updateText,
          decoration: const InputDecoration(
            hintText: 'Filter poem text…',
          ),
        ),
      ),
    );

    final Widget listView = Expanded(
      child: Builder(
        key: ValueKey<bool>(usingFilter),
        builder: (BuildContext context) => ListView(
          children: <Widget>[
            if (usingFilter)
              for (final (String line, Poem poem) in InheritedPoemFilter.of(context, text))
                ListTile(
                  title: parseText(line),
                  trailing: Text(poem.title),
                  onTap: poem.view,
                )
            else
              for (final Poem poem in Poems.inOrder(context))
                ListTile(
                  title: Text(poem.title),
                  subtitle: Text(poem.author),
                  onTap: poem.view,
                ),
          ],
        ),
      ),
    );

    return Column(children: <Widget>[textField, listView]);
  }
}

class PoemCheckboxes extends StatelessWidget {
  const PoemCheckboxes({super.key});

  static void show() {
    showModalBottomSheet<void>(
      barrierColor: Colors.black26,
      context: navigatorKey.currentContext!,
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 570),
      builder: (BuildContext context) => const FittedBox(
        child: SizedBox(width: 420, height: 570, child: PoemCheckboxes()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<Poem> enabledPoems = Poems.of(context);

    return ListView(children: <Widget>[
      const SizedBox(height: 16),
      Text(
        'Poems to include\n',
        style: TextTheme.of(context).titleMedium,
        textAlign: TextAlign.center,
      ),
      for (final Poem poem in Poem.values)
        CheckboxListTile(
          title: Text(poem.title),
          subtitle: Text('by ${poem.author}'),
          value: enabledPoems.contains(poem),
          onChanged: (bool? enabled) => Poems.modify(poem, enabled!),
        ),
      const Divider(indent: 16, endIndent: 16),
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'The value stored in the inherited filter changes '
          'each time a checkbox is tapped, but it only sends '
          "a notification when there's a change to the results "
          'filtered by the search query.',
        ),
      ),
    ]);
  }
}

class _PoemPage extends StatelessWidget {
  const _PoemPage(this.poem);

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.of(context);
    final TextSpan textSpan = TextSpan(
      children: <InlineSpan>[
        TextSpan(text: poem.title, style: textTheme.titleLarge),
        const TextSpan(text: '\n\n'),
        TextSpan(text: poem.author, style: textTheme.labelLarge),
        const TextSpan(text: '\n\n\n\n'),
        TextSpan(text: poem.content),
      ],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Center(
          widthFactor: 1,
          child: SingleChildScrollView(
            key: Key(poem.title),
            child: Center(
              child: Text.rich(textSpan),
            ),
          ),
        ),
      ),
    );
  }
}

const Map<Poem, String> poems = <Poem, String>{
  Poem.oCaptainMyCaptain: '''
O Captain! my Captain! Our fearful trip is done,
The ship has weathered every rack, the prize we sought is won,
The port is near, the bells I hear, the people all exulting,
While follow eyes the steady keel, the vessel grim and daring;
But O heart! heart! heart!
    O the bleeding drops of red,
        Where on the deck my Captain lies,
            Fallen cold and dead.

O Captain! my Captain! rise up and hear the bells;
Rise up - for you the flag is flung - for you the bugle trills,
For you bouquets and ribboned wreaths - for you the shores acrowding,
For you they call, the swaying mass, their eager faces turning;
Here Captain! dear father!
    The arm beneath your head!
        It is some dream that on the deck,
            You've fallen cold and dead.

My Captain does not answer, his lips are pale and still,
My father does not feel my arm, he has no pulse nor will,
The ship is anchored safe and sound, its voyage closed and done,
From fearful trip the victor ship comes in with object won;
Exult O shores, and ring O bells!
    But I with mournful tread,
        Walk the deck my Captain lies,
            Fallen cold and dead.
''',
  Poem.sonnet18: '''
Shall I compare thee to a summer's day?
Thou art more lovely and more temperate:
Rough winds do shake the darling buds of May,
And summer's lease hath all too short a date:
Sometime too hot the eye of heaven shines,
And often is his gold complexion dimm'd;
And every fair from fair sometime declines,
By chance or nature's changing course untrimm'd;
But thy eternal summer shall not fade
Nor lose possession of that fair thou owest;
Nor shall Death brag thou wander'st in his shade,
When in eternal lines to time thou growest:
So long as men can breathe or eyes can see,
So long lives this and this gives life to thee.
''',
  Poem.theRoadNotTaken: '''
Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as I could
To where it bent in the undergrowth;
Then took the other, as just as fair,
And having perhaps the better claim,
Because it was grassy and wanted wear;
Though as for that the passing there
Had worn them really about the same,
And both that morning equally lay
In leaves no step had trodden black.
Oh, I kept the first for another day!
Yet knowing how way leads on to way,
I doubted if I should ever come back.
I shall be telling this with a sigh
Somewhere ages and ages hence:
Two roads diverged in a wood, and I-
I took the one less traveled by,
And that has made all the difference.
''',
  Poem.inheritedWidgetHaiku: '''
It's fun to create
Widget dependencies that
Are inherited
''',
};
