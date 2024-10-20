import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// class SearchResult extends InheritedFilter<String> {
//
// }

class AutoDispose extends InheritedFilter<Object?> {
  const AutoDispose({super.key, required super.child});

  @override
  Object? select(Object? selector) => selector;

  @override
  InheritedFilterElement<Object?> createElement() => _AutoDisposeElement(this);
}

class _AutoDisposeElement extends InheritedFilterElement<Object?> {
  _AutoDisposeElement(super.widget);

  String status = "Just chuggin' along";

  void handleEmptyDependents() {
    status = 'I have no active dependents!';
  }

  @override
  void clearSelectors(Element dependent) {
    _markNeedsEvaluation();
    super.clearSelectors(dependent);
  }

  bool _needsEvaluation = false;

  void _markNeedsEvaluation() {
    if (_needsEvaluation) {
      return;
    }
    _needsEvaluation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _needsEvaluation = false;

      if (getDependencies().isEmpty) {
        handleEmptyDependents();
      }
    });
  }
}

void main() {
  testWidgets('InheritedFilter can react to inactive dependents', (WidgetTester tester) async {
    bool activelyDepending = true;
    late StateSetter setState;

    String inheritedStatus() {
      final _AutoDisposeElement element = tester.element(find.byType(AutoDispose));
      return element.status;
    }

    await tester.pumpWidget(
      AutoDispose(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            if (activelyDepending) {
              context.dependOnInheritedWidgetOfExactType<AutoDispose>();
            }

            setState = stateSetter;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(inheritedStatus(), "Just chuggin' along");

    setState(() {
      // Trigger a rebuild while still maintaining the dependency.
    });
    await tester.pump();
    expect(inheritedStatus(), "Just chuggin' along");

    setState(() {
      activelyDepending = false;
    });
    await tester.pump();
    expect(inheritedStatus(), 'I have no active dependents!');
  });
}
