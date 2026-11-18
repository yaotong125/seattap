import 'package:flutter/material.dart';

import 'package:seattap/core/widgets/common.dart';

/// Placeholder for features that arrive in later sprints.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Expanded(
                child: Center(
                  child: StatusHero(
                    icon: Icons.construction_outlined,
                    title: 'Coming soon',
                    body: 'This part of SeatTap is on its way. You’ll be able to use it in an upcoming update.',
                  ),
                ),
              ),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to Home')),
            ]),
          ),
        ),
      );
}
