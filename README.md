# Mood Tracker 🎭

A Flutter **web** app that lets you log how you feel, see your past 7 entries in a horizontal animated timeline, and tap any past entry to see a bounce animation.

## Live Demo

> 🌐 **[mood-tracker.web.app](https://mood-tracker.web.app)** *(deploy link after Firebase Hosting setup)*

## Features

- **5 custom-painted mood faces** drawn entirely with Flutter's `CustomPainter` using `drawCircle`, `drawArc`, `drawPath`, `drawLine`
  - Ecstatic (★) — crescent eyes, wide open smile with teeth, rosy cheeks, raised eyebrows
  - Happy (♥) — round eyes with glints, medium smile, slightly raised eyebrows
  - Neutral (●) — round eyes, flat mouth line, level eyebrows
  - Sad (◆) — round eyes, downward frown, angled inner-raised eyebrows
  - Awful (▼) — X eyes, strong deep frown, steep inner-raised eyebrows, tear drop
- **Tap to log** your current mood with a loading indicator and success toast
- **Horizontal scrollable timeline** — last 7 entries showing the drawn face, date, mood label, and color accent
- **Tap a timeline card** — triggers a smooth bounce-scale animation (`TweenSequence`)
- **Detail overlay** — tapping a card opens a centered modal with the large face and full timestamp
- **Persistence** — entries survive page refreshes via `shared_preferences`

## Architecture & State Management

```
lib/
├── main.dart                     # App entry point, MaterialApp + theme
├── models/
│   └── mood_entry.dart           # MoodEntry + MoodType enum (color, label, JSON)
├── controllers/
│   └── mood_controller.dart      # ChangeNotifier state + SharedPreferences persistence
├── painters/
│   └── mood_face_painter.dart    # CustomPainter — all drawing logic
├── screens/
│   └── mood_tracker_screen.dart  # Single screen, ListenableBuilder
└── widgets/
    ├── mood_button.dart          # Hover-scale animated mood selector
    └── timeline_card.dart        # Bounce-scale animated timeline card
```

**State management:** Plain `ChangeNotifier` + `ListenableBuilder`. No third-party state management library needed for a single-screen app — `ChangeNotifier` is lightweight, testable, and Flutter-idiomatic. The `MoodController` owns the list of entries and persists them to `SharedPreferences`.

## CustomPainter Breakdown

Each face is drawn in `MoodFacePainter.paint()`:

1. **Face circle** — `drawCircle` with a `RadialGradient` shader for depth + a blurred shadow circle for glow
2. **Eyes** — `drawCircle` (regular), `drawArc` (crescent for ecstatic), `drawLine` pairs (X for awful)
3. **Mouth** — `Path` with `quadraticBezierTo` for curves (happy/sad/ecstatic/awful) or a straight `lineTo` (neutral)
4. **Eyebrows** — `drawPath` with angled lines; `angleOffset` controls the inner/outer tilt to convey emotion
5. **Cheeks** — blurred `drawCircle` with pink tint (ecstatic only)
6. **Tear drop** — `cubicTo` path (awful only)

## One Thing I'd Improve

With more time I'd add a **mood statistics panel** — a small bar chart (using `CustomPainter`) showing the distribution of moods over the past 30 days, so users can spot patterns like "I'm sad more often on Mondays."

## Running Locally

```bash
flutter pub get
flutter run -d chrome
```

## Building for Web

```bash
flutter build web --release
firebase deploy --only hosting
```

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.x |
| State | ChangeNotifier + ListenableBuilder |
| Persistence | shared_preferences |
| Fonts | google_fonts (Inter) |
| Hosting | Firebase Hosting |
