# PaTiSuite

<img src="assets/icon-128.png" width="96" alt="PaTiSuite icon">

A tiny, optional control panel for World of Warcraft: Forever (Interface 16001): one line per installed PaTi addon
to show or hide its window, plus **Show all** / **Hide all**. It is a remote control, nothing more — every PaTi addon
works exactly the same without it.

> Status: 0.1.0, in development, not yet released. Not yet tested in game.

## Features
- Lists the PaTi addons that are installed and running (Heal, Auras, Tank, Group, Quest, Dungeon, Alerts); a green
  dot and "Shown" or a grey dot and "Hidden" show the state, a click on the line shows or hides that window
- One button for all windows: "Hide all" while every window is shown, otherwise "Show all"; the control panel
  itself stays visible
- Respects each addon's rules: windows with secure buttons (Heal, Auras, Group) cannot be shown or hidden in combat —
  PaTiSuite then says so (e.g. "Heal: not possible in combat") and changes nothing
- ••• menu: Settings, Lock, Reset position, Hide. Settings: language, scale, lock, panel opacity

No test mode: the panel only shows your real windows, there is nothing to simulate.

## Installation
1. Download the release zip (`PaTiSuite-<version>.zip`).
2. Unpack it and copy the folder `PaTiSuite` into `World of Warcraft/<client>/Interface/AddOns/`.
3. Start WoW and enable PaTiSuite together with your PaTi addons.

## Commands
`/psuite` or `/patisuite` — alone: show/hide the panel · `showall` · `hideall` · `show` · `hide` · `lock` · `unlock` ·
`reset` (position) · `settings` · `debug` · `version`

## How it finds the windows
Every PaTi addon's window registers itself in a small shared list (`PaTiSuiteWindows`: addon name → window frame,
nothing else). PaTiSuite reads that list; it never reads settings or game data of other addons.

## Known limitations
- In-game test status: [`INGAME_TESTING.md`](INGAME_TESTING.md) (the single "all" button is not tested yet).

## License
MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Patrick Koch.
