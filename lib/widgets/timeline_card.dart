import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/mood_entry.dart';
import '../painters/mood_face_painter.dart';

/// A single card in the horizontal timeline.
///
/// When tapped it runs a quick bounce + scale animation and calls
/// [onTap] so the parent can show a detail overlay.
class TimelineCard extends StatefulWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;

  const TimelineCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  State<TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale: 1.0 → 1.22 → 0.95 → 1.0
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.22)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: 1.22, end: 0.95)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.95, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 35),
    ]).animate(_controller);

    // Face animation value: 0 → 1 over the whole duration.
    _bounceAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final dateLabel = DateFormat('E\nd MMM').format(entry.timestamp);
    final timeLabel = DateFormat('h:mm a').format(entry.timestamp);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 110,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.entry.color.withAlpha(120),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.entry.color.withAlpha(50),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Colored accent header strip.
              Container(
                decoration: BoxDecoration(
                  color: widget.entry.color.withAlpha(30),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Center(
                  child: Text(
                    dateLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: widget.entry.color.withAlpha(220),
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              // Face.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (context, _) => MoodFaceWidget(
                    mood: entry.mood,
                    size: 58,
                    animationValue: _bounceAnim.value,
                  ),
                ),
              ),

              // Mood label.
              Text(
                entry.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.entry.color,
                ),
              ),
              const SizedBox(height: 4),

              // Time.
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
