import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../painters/mood_face_painter.dart';

/// A large, tappable mood selector button displayed in the mood picker grid.
class MoodButton extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodButton({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MoodButton> createState() => _MoodButtonState();
}

class _MoodButtonState extends State<MoodButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _hoverScale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool hovering) {
    setState(() => _hovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  String get _label {
    switch (widget.mood) {
      case MoodType.ecstatic:
        return 'Ecstatic';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.awful:
        return 'Awful';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = MoodEntry(
      id: '',
      mood: widget.mood,
      timestamp: DateTime.now(),
    ).color;

    return AnimatedBuilder(
      animation: _hoverScale,
      builder: (context, child) => Transform.scale(
        scale: _hoverScale.value,
        child: child,
      ),
      child: MouseRegion(
        onEnter: (_) => _onHoverChange(true),
        onExit: (_) => _onHoverChange(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? color.withAlpha(38)
                  : (_hovered ? color.withAlpha(18) : Colors.white.withAlpha(200)),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected ? color : color.withAlpha(60),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MoodFaceWidget(mood: widget.mood, size: 68),
                const SizedBox(height: 8),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected ? color : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
