import 'package:flutter/material.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(children: [
          Icon(icon, size: 36, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.muted)),
        ]),
      );
}
