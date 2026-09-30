# Changelog

Format: `## [Unreleased]` / `## [x.y.z] - YYYY-MM-DD` with Added, Changed, Fixed, Removed, Known Issues.

## [Unreleased] — 0.1.0
### Added
- Control panel: one line per installed PaTi addon (from `PaTiSuiteWindows`) to show or hide its window,
  Show all / Hide all. Uses each addon's own show/hide rules; windows that cannot change in combat are named
  in one short message and left alone.
- Settings: language, scale, lock, panel opacity, snapping; ••• menu with Settings, Lock, Reset position, Hide;
  `/psuite`, `/patisuite`. English texts, German translation. MIT license.
- Icon (the owner-approved PaTiSuite emblem): `Media/icon.tga` for the AddOns list, platform images in `assets/`.
### Known Issues
- Not tested in game yet.
### Fixed
- Hovering a line made it unreadable (owner test 2026-09-30): the hover texture sat in the HIGHLIGHT layer above the
  text. It is now a background shown on mouse-over, the text stays light.
### Changed
- Shown windows are marked green (dot and "Shown"), hidden ones grey; PaTi blue is no longer an on/off colour.
- Settings: snapping removed (see PaTiShared).
