// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Flutter code sample for [ScaffoldMessenger].

void main() => runApp(const ScaffoldMessengerExampleApp());

class ScaffoldMessengerExampleApp extends StatelessWidget {
  const ScaffoldMessengerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ScaffoldMessenger Sample')),
        body: Center(
          child: ScaffoldMessengerExample(),
        ),
      ),
    );
  }
}

class ScaffoldMessengerExample extends StatelessWidget {
  const ScaffoldMessengerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A SnackBar has been shown.'),
          ),
        );
      },
      child: const Text('Show SnackBar'),
    );
  }
}
