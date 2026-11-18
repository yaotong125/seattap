import 'package:flutter/material.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';

/// Shown while the session loads.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.maroon,
        body: Stack(children: [
          const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AppLogo(size: 96),
              SizedBox(height: 20),
              Text('SeatTap',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.8)),
              SizedBox(height: 6),
              Text('Tap. Verify. Seat.', style: TextStyle(fontSize: 16, color: AppColors.goldSoft)),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: Column(children: [
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: AppColors.gold,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Universiti Teknologi Malaysia', style: TextStyle(fontSize: 13, color: AppColors.roseText)),
            ]),
          ),
        ]),
      );
}
