// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Flutter code sample for [DropdownMenu].

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

void main() => runApp(const DropdownMenuApp());

class DropdownMenuApp extends StatelessWidget {
  const DropdownMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('DropdownMenu Sample')),
        body: Center(
          child: DropdownMenuExample(),
        ),
      ),
    );
  }
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: <Widget>[
        ListTile(
          tileColor: colorScheme.primaryContainer,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('enabled: true'),
              Text('requestFocusOnTap: true'),
            ],
          ),
          subtitle: Column(
            children: <Widget>[
              DropdownMenu<String>(
                requestFocusOnTap: true,
                initialSelection: list.first,
                expandedInsets: EdgeInsets.zero,
                onSelected: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              const Text('Text cursor is shown when hovering over the DropdownMenu.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          tileColor: colorScheme.primaryContainer,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('enabled: true'),
              Text('requestFocusOnTap: false'),
            ],
          ),
          subtitle: Column(
            children: <Widget>[
              DropdownMenu<String>(
                requestFocusOnTap: false,
                initialSelection: list.first,
                expandedInsets: EdgeInsets.zero,
                onSelected: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              const Text('Clickable cursor is shown when hovering over the DropdownMenu.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          tileColor: colorScheme.onInverseSurface,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('enabled: false'),
              Text('requestFocusOnTap: true'),
            ],
          ),
          subtitle: Column(
            children: <Widget>[
              DropdownMenu<String>(
                enabled: false,
                requestFocusOnTap: true,
                initialSelection: list.first,
                expandedInsets: EdgeInsets.zero,
                onSelected: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              const Text('Default cursor is shown when hovering over the DropdownMenu.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          tileColor: colorScheme.onInverseSurface,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('enabled: false'),
              Text('requestFocusOnTap: false'),
            ],
          ),
          subtitle: Column(
            children: <Widget>[
              DropdownMenu<String>(
                enabled: false,
                requestFocusOnTap: false,
                initialSelection: list.first,
                expandedInsets: EdgeInsets.zero,
                onSelected: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              const Text('Default cursor is shown when hovering over the DropdownMenu.'),
            ],
          ),
        ),
      ],
    );
  }
}
