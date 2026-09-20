# ATLAS v11 — Crafted Motion System

ATLAS v11 treats motion as product feedback, not decoration.

## Principles

- No permanent decorative neon/glow loops.
- Screen motion is short, directional and tied to hierarchy.
- Data changes animate only when their state changes.
- Camera motion communicates capture and processing.
- Buttons provide tactile press feedback and haptics where useful.
- Navigation uses native iOS movement plus ATLAS content reveals.
- `Reduce Motion` is respected across the custom motion layer.

## Motion language

| Token | Duration | Use |
|---|---:|---|
| micro | 140 ms | taps, compact controls |
| fast | 200 ms | selection, state changes |
| standard | 340 ms | screen/section transitions |
| deliberate | 480 ms | splash and major reveals |

The project centralizes these values in `Core/MotionSystem.swift`.

## Screen behavior

### Splash
- ATLAS mark settles into place.
- Wordmark and tagline reveal progressively.
- No looping animation.

### Onboarding
- Native horizontal paging.
- Matched progress indicator.
- Haptic selection feedback.
- Content hierarchy remains static enough to read comfortably.

### Authentication
- Logo, heading, fields, primary action, Sign in with Apple and secondary actions enter in sequence.

### Mundo
- Header, hero, metrics, attention, world states, changes and upcoming actions reveal in editorial order.
- Offline state enters from the top only when connectivity changes.

### Tab navigation
- Compact matched selection marker.
- Soft spring between selected tabs.
- Scan action uses a stronger tactile response.

### Assets and lists
- Reusable rows reveal as they enter the viewport.
- Press states use a subtle scale/opacity response.
- Status does not pulse or animate continuously.

### Change / Compare
- Before/after comparison re-enters only when the selected states change.
- Menu selections provide light haptic feedback.

### Inspections
- Current inspection step expands progressively.
- Step transitions are animated and reversible.
- Completion uses success haptic feedback.

### Camera
- Real camera preview remains visually dominant.
- Viewfinder corners draw once when the camera becomes ready.
- Capture button provides tactile feedback.
- Shutter produces a brief real-camera-style white flash.

### Processing
- Processing sources activate sequentially.
- Active source uses a processing indicator.
- Completed sources resolve to a checkmark.
- The sequence stops when analysis is complete; it is not decorative looping content.

### Scan result
- Successful asset creation enters with a state transition and success haptic.

### Ask ATLAS
- Suggested prompt to answer is a deliberate content transition, not a generic chat bubble animation.
- Evidence and insight remain visually anchored after the response appears.

### Loading / empty / error / permission
- Each state uses a dedicated entrance pattern.
- Loading-only indicators may animate; static states do not loop.

## Accessibility

Custom motion checks `accessibilityReduceMotion`.

When Reduce Motion is enabled:

- positional entrances resolve immediately;
- matched/tab selection still changes state without unnecessary motion;
- shimmer and continuous processing rotation are suppressed where possible;
- content remains fully functional.

## Haptics

`AtlasHaptics` provides:

- selection feedback for navigation and state pickers;
- light/medium impacts for primary physical actions;
- success feedback for completed actions.

Haptics are intentionally sparse and are not emitted for passive scrolling or decorative events.
