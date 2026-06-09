import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An animated "reactor" visualization for the Daily Momentum widget.
///
/// Displays a spinning sweep-gradient ring whose speed scales with
/// [points]. At zero activity the ring is static; reaching [target]
/// triggers a pulse animation on the core icon.
class CyberReactor extends StatefulWidget {
  final int points;
  final int target;

  const CyberReactor({super.key, required this.points, required this.target});

  @override
  State<CyberReactor> createState() => _CyberReactorState();
}

class _CyberReactorState extends State<CyberReactor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(CyberReactor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _updateAnimation();
    }
  }

  /// Adjusts the ring spin speed based on the current point count.
  void _updateAnimation() {
    if (widget.points == 0) {
      _controller.stop();
    } else if (widget.points == 1) {
      _controller.duration = const Duration(seconds: 8); // Slow spin
      _controller.repeat();
    } else if (widget.points == 2) {
      _controller.duration = const Duration(seconds: 4); // Medium spin
      _controller.repeat();
    } else {
      _controller.duration = const Duration(seconds: 1); // Fast spin (Overload!)
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (widget.points / widget.target).clamp(0.0, 1.0);
    final isMax = widget.points >= widget.target;

    final glowColor = AppColors.primary.withValues(alpha: 0.2 + (0.4 * ratio));
    final blurRadius = widget.points == 0 ? 0.0 : 15.0 + (15.0 * ratio);

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (widget.points > 0)
            BoxShadow(
              color: glowColor,
              blurRadius: blurRadius,
              spreadRadius: blurRadius / 2,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Spinning ring (sweep gradient)
          if (widget.points > 0)
            RotationTransition(
              turns: _controller,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

          // Layer 2: Center cover (creates the ring appearance)
          Container(
            width: 125,
            height: 125,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
          ),

          // Layer 3: Core icon with pulse effect at max
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: isMax ? 1.2 : 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  isMax ? Icons.local_fire_department : Icons.bolt,
                  size: 56,
                  color: widget.points == 0
                      ? Colors.white24
                      : AppColors.primary
                          .withValues(alpha: 0.5 + (0.5 * ratio)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
