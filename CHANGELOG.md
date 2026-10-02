# Changelog

Format: `## [Unreleased]` / `## [x.y.z] - YYYY-MM-DD` with Added, Changed, Fixed, Removed, Known Issues.

## [Unreleased] — 0.1.0
### Added
- New windows in the list (2026-10-02): PaTiRota and the new PaTiGroup (party awareness); the former PaTiGroup is now
  PaTiLead. Order: Heal, Auras, Tank, Rota, Group, Lead, Quest, Dungeon, Social, Alerts. Group and Lead are separate
  entries. `PaTiSuiteDB` schema 4: a remembered `visibility.PaTiGroup` belonged to the old marker addon and moves to
  `PaTiLead` (an own PaTiLead entry wins); the new PaTiGroup starts without an old override.
- Shown/hidden is remembered over `/reload` (owner 2026-10-02): every successful show/hide done in PaTiSuite (row
  click, Show all, Hide all, `/psuite showall|hideall`) is saved in PaTiSuiteDB.visibility; at the first
  PLAYER_ENTERING_WORLD each window goes back to it through the addon's own rules. No entry = the window starts as
  its addon starts it. Blocked in combat = nothing saved (after a `/reload` in combat: applied after combat). Shows
  and hides by other means are not saved. SavedVariables schema 3 (visibility; every other value kept);
  Restore Defaults forgets it.
- Control panel: one line per installed PaTi addon (from `PaTiSuiteWindows`) to show or hide its window,
  Show all / Hide all. Uses each addon's own show/hide rules; windows that cannot change in combat are named
  in one short message and left alone.
- Settings: language, scale, lock, panel opacity, snapping; ••• menu with Settings, Lock, Reset position, Hide;
  `/psuite`, `/patisuite`. English texts, German translation. MIT license.
- Icon (the owner-approved PaTiSuite emblem): `Media/icon.tga` for the AddOns list, platform images in `assets/`.
- Layout setting: vertical (default) or horizontal, applied at once (Settings → Display → Layout).
- Collapse/Expand in the ••• menu: only the header stays; saved in PaTiSuiteDB.collapsed (also in combat — the
  panel has no secure buttons). SavedVariables schema 2 adds layout and collapsed; old values and the position
  stay, an unknown layout becomes vertical; Restore Defaults sets vertical and expanded.
### Known Issues
- Visibility over `/reload`, the inline button and the new tooltip placement are not tested in game yet.
- The compact layout, horizontal layout and collapse (2026-10-02) are not tested in game yet.
- The single "Show all / Hide all" button is not tested in game yet. Owner-confirmed 2026-09-30: single show/hide,
  the former Show all / Hide all buttons, green/grey states, readable hover (`INGAME_TESTING.md`).
### Fixed
- Hardening: a broken SavedVariables save (not a table, a broken schema or scale) no longer breaks the login; only the broken value is replaced, every valid setting (also `false`) stays, and the migration is idempotent (tests/robustness_spec.lua).
- Settings: the "General" section heading had no translation and showed its key "GENERAL" (found in the code).
- Hovering a line made it unreadable (owner test 2026-09-30): the hover texture sat in the HIGHLIGHT layer above the
  text. It is now a background shown on mouse-over, the text stays light.
### Changed
- The window can also be moved in combat (it has no secure buttons; PaTiShared `SetCombatMovable`, hardening 2026-10-02). A broken saved position falls back to the default instead of breaking the login.
- PaTiSocial ("Party Social") joins the suite order, between Dungeon and Alerts.
- Horizontal layout: the Show all / Hide all button is the last element of the row instead of a line below; the
  row may use up to 90 % of the screen width before it wraps.
- Tooltips sit beside the hovered line (PaTiShared).
- Compact panel: each entry is only a coloured dot and the short name (green = shown, grey = hidden), the
  "Shown"/"Hidden" text is gone; the window is as wide as its content, the entries or the header need.
- Shown windows are marked green (dot and "Shown"), hidden ones grey; PaTi blue is no longer an on/off colour.
- Settings: snapping removed (see PaTiShared).
- One button instead of "Show all" and "Hide all" (owner wish 2026-09-30): "Hide all" while every window is shown,
  otherwise "Show all" (German "Alle einblenden"); the label follows every change. `/psuite showall` and
  `/psuite hideall` stay; combat rules unchanged.
