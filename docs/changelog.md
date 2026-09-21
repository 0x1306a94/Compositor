# Changelog

## Unreleased

### Fixed
- **Layer Effects Persistence and Export (Issue #50)**:
  - Passed `effects: layer.effects` through `EditorSession.projectSnapshot()` so that layer effects (`StrokeEffect`, `ShadowEffect`, `ColorOverlayEffect`, `InnerShadowEffect`) are preserved in `ProjectLayerRecord` during project save and export operations.
  - Restored `effects: $0.effects` in `EditorSession.installProject(_:from:)` so that layer effects are properly reconstructed on `ImageLayer` when reopening saved projects.
  - Added regression test `projectRoundTripPreservesAllLayerEffects()` in `ProjectTests.swift` covering save/load round-trips for stroke, drop shadow, color overlay, and inner shadow.
  - Added deterministic rendering regression test `layerEffectsAreRenderedInExport()` in `ProjectTests.swift` verifying that layer effects are rendered into exported images.
