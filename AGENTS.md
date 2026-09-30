# AGENTS.md — PaTiSuite

**Read the suite rules first: [`../../PaTiAdmin/AGENTS.md`](../../PaTiAdmin/AGENTS.md).** They apply here in full.
Addon facts: `../../PaTiAdmin/docs/ARCHITECTURE.md` · open issues: `../../PaTiAdmin/docs/FOLLOW_UPS.md`.

## This addon
- Purpose: optional remote control — show/hide the main windows of the installed PaTi addons. **No gameplay logic,
  no runtime core**: no addon may depend on PaTiSuite, and PaTiSuite reads nothing but `PaTiSuiteWindows`.
- Files: `Logic.lua` (settings, window list, show/hide rules; pure, tested) · `PaTiSuite.lua` (panel, settings,
  commands, events) · `Locales/` · `Shared/` (PaTiShared, synced — never edit).
- Window list: `_G.PaTiSuiteWindows[addonName] = frame`, written by each addon's embedded PaTiShared (`UI.CreateWindow`).
  Show/hide goes through `frame:SetSuiteShown(shown)` (the addon's own rules, e.g. blocked in combat) — never call
  `Show`/`Hide` on another addon's protected frame in combat. Only post-hooks (`HookScript` OnShow/OnHide) to follow state.
- SavedVariables: `PaTiSuiteDB` (per character), schema 1: position, locked, scale, language, opacity, snapWindows.
- Secure / combat-sensitive: none of its own. No test mode (nothing to simulate), no collapse (the panel is small).
- Slash commands: `/psuite`, `/patisuite`.

## Checks
`bash ../../PaTiAdmin/tools/check.sh .` before every commit. Manual WoW tests: `../../PaTiAdmin/docs/TESTING.md`.
