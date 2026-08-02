import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app.dart';
import 'package:flutter_najwafth_driver/core/core.dart';

Future<void> main() async {
  final app = await AppBootstrap.createProviderScope(
    child: const NajwafthDriverApp(),
  );

  runApp(app);
}


