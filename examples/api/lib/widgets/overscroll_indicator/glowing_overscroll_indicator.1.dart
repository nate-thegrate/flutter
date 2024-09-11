// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Flutter code sample for [GlowingOverscrollIndicator].

void main() => runApp(const GlowingOverscrollIndicatorExampleApp());

class GlowingOverscrollIndicatorExampleApp extends StatelessWidget {
  const GlowingOverscrollIndicatorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('GlowingOverscrollIndicator Sample')),
        body: GlowingOverscrollIndicatorExample(),
      ),
    );
  }
}

class GlowingOverscrollIndicatorExample extends StatelessWidget {
  const GlowingOverscrollIndicatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return const <Widget>[
          SliverAppBar(title: Text('Custom NestedScrollViews')),
        ];
      },
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.amberAccent,
              height: 100,
              child: const Center(child: Text('Glow all day!')),
            ),
          ),
          const SliverFillRemaining(child: FlutterLogo()),
        ],
      ),
    );
  }
}
