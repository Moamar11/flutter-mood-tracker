import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/mood_controller.dart';
import '../models/mood_entry.dart';
import '../painters/mood_face_painter.dart';
import '../widgets/mood_button.dart';
import '../widgets/timeline_card.dart';

/// The single-screen home page of the mood tracker.
class MoodTrackerScreen extends StatefulWidget {
  final MoodController controller;

  const MoodTrackerScreen({super.key, required this.controller});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  MoodType? _selectedMood;
  bool _isLogging = false;

  // Entry detail overlay state.
  MoodEntry? _detailEntry;

  // Header animation.
  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  // Log button pulse animation.
  late final AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Interactions
  // ---------------------------------------------------------------------------

  Future<void> _logMood() async {
    if (_selectedMood == null || _isLogging) return;
    setState(() => _isLogging = true);
    await widget.controller.logMood(_selectedMood!);
    if (mounted) {
      setState(() {
        _isLogging = false;
        _selectedMood = null;
      });
      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Mood logged! Keep it up ✨'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetail(MoodEntry entry) {
    setState(() => _detailEntry = entry);
  }

  void _dismissDetail() {
    setState(() => _detailEntry = null);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FF),
          body: Stack(
            children: [
              // Background decorative blobs.
              _buildBackground(),

              // Main content.
              SafeArea(
                child: widget.controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
              ),

              // Detail overlay.
              if (_detailEntry != null) _buildDetailOverlay(_detailEntry!),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF7C4DFF).withAlpha(40),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF00BCD4).withAlpha(35),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Main content
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildMoodPicker(),
            const SizedBox(height: 20),
            _buildLogButton(),
            const SizedBox(height: 36),
            _buildTimelineSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withAlpha(22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✦ Mood Tracker',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C4DFF),
                    ),
                  ),
                ),
                const Spacer(),
                _buildClearButton(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '$greeting 👋',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'How are you feeling right now?',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    if (widget.controller.entries.isEmpty) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => _confirmClear(),
      icon: const Icon(Icons.delete_outline_rounded, size: 16),
      label: const Text('Clear'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade500,
        textStyle: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear all entries?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('This cannot be undone.',
            style: GoogleFonts.inter(color: Colors.grey.shade600)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.clearAll();
    }
  }

  // ---------------------------------------------------------------------------
  // Mood picker
  // ---------------------------------------------------------------------------

  Widget _buildMoodPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick your mood',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 14),
        // First row: ecstatic + happy + neutral.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MoodType.ecstatic,
            MoodType.happy,
            MoodType.neutral,
          ]
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MoodButton(
                        mood: m,
                        isSelected: _selectedMood == m,
                        onTap: () => setState(() => _selectedMood = m),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        // Second row: sad + awful (centred).
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MoodType.sad,
            MoodType.awful,
          ]
              .map((m) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 56) / 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MoodButton(
                        mood: m,
                        isSelected: _selectedMood == m,
                        onTap: () => setState(() => _selectedMood = m),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Log button
  // ---------------------------------------------------------------------------

  Widget _buildLogButton() {
    final canLog = _selectedMood != null && !_isLogging;
    final color = _selectedMood != null
        ? MoodEntry(
            id: '', mood: _selectedMood!, timestamp: DateTime.now()).color
        : const Color(0xFF7C4DFF);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final pulse = canLog ? (1.0 + _pulseAnim.value * 0.015) : 1.0;
        return Transform.scale(scale: pulse, child: child);
      },
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: canLog
                ? LinearGradient(
                    colors: [color, Color.lerp(color, Colors.white, 0.2)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade300],
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: canLog
                ? [
                    BoxShadow(
                      color: color.withAlpha(90),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canLog ? _logMood : null,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: _isLogging
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: canLog
                                ? Colors.white
                                : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            canLog ? 'Log Mood' : 'Select a mood above',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: canLog
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Timeline section
  // ---------------------------------------------------------------------------

  Widget _buildTimelineSection() {
    final recent = widget.controller.recentEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Timeline',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withAlpha(22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${recent.length}/7',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C4DFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap any entry to animate it',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 14),

        if (recent.isEmpty)
          _buildEmptyTimeline()
        else
          _buildTimeline(recent),
      ],
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_rounded, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'No entries yet.\nLog your first mood!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<MoodEntry> entries) {
    return SizedBox(
      height: 186,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          return TimelineCard(
            entry: entries[index],
            onTap: () => _showDetail(entries[index]),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Detail overlay
  // ---------------------------------------------------------------------------

  Widget _buildDetailOverlay(MoodEntry entry) {
    return GestureDetector(
      onTap: _dismissDetail,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withAlpha(120),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap-through.
              child: _buildDetailCard(entry),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(MoodEntry entry) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mood face.
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.color.withAlpha(22),
            ),
            padding: const EdgeInsets.all(12),
            child: MoodFaceWidget(mood: entry.mood, size: 86),
          ),
          const SizedBox(height: 18),

          // Mood label.
          Text(
            entry.label,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: entry.color,
            ),
          ),
          const SizedBox(height: 8),

          // Timestamp.
          Text(
            DateFormat('EEEE, MMMM d, y').format(entry.timestamp),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            DateFormat('h:mm a').format(entry.timestamp),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 22),

          // Close button.
          TextButton(
            onPressed: _dismissDetail,
            style: TextButton.styleFrom(
              backgroundColor: entry.color.withAlpha(22),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: entry.color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
