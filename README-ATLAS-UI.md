# ATLAS — Spatial Intelligence UI v6

A complete visual refactor of the ATLAS iPhone experience.

## Design direction
- Obsidian / graphite foundation instead of conventional SaaS navy.
- Warm porcelain typography and controls for a luxury-instrument feel.
- Electric blue, aqua and amber used only as signal colors.
- Native Apple typography only: New York-style system serif for editorial display, SF Pro system sans for UI/body, SF Mono system monospaced for technical metadata.
- SF Symbols exclusively for interface iconography.
- A single spatial “World Lens” is the visual hero rather than a dashboard grid.
- Floating capsule dock with a dedicated capture action.
- No external packages, fonts or remote image dependencies.

## Integration points
The current `ScanSheet` is intentionally UI-only. Connect its primary action to ARKit / RoomPlan / Vision when the capture pipeline is implemented.

The `AskAtlasSheet` is ready to connect to your agent / backend layer.

## Conventional Commit

```bash
git add . && git commit -m "feat(ui): reconstruir ATLAS con experiencia spatial intelligence premium"
```
