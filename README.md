# PaTiSuite

<img src="assets/icon-128.png" width="96" alt="PaTiSuite icon">

A tiny, optional control panel for World of Warcraft: Forever (Interface 16001): one line per installed PaTi addon
to show or hide its window, plus **Show all** / **Hide all**. It is a remote control, nothing more — every PaTi addon
works exactly the same without it.

> Status: 0.1.0, in development, not yet released. Partly tested in game ([`INGAME_TESTING.md`](INGAME_TESTING.md)).

## Features
- Lists the PaTi addons that are installed and running (Heal, Auras, Tank, Rota, Group, Lead, Quest, Dungeon, Social,
  Alerts) in a compact panel: a coloured dot and the short name — green = window shown, grey = hidden. A click on an entry
  shows or hides that window
- One button for all windows: "Hide all" while every window is shown, otherwise "Show all"; the control panel
  itself stays visible
- Respects each addon's rules: windows with secure buttons (Heal, Auras, Rota, Lead) cannot be shown or hidden in combat —
  PaTiSuite then says so (e.g. "Heal: not possible in combat") and changes nothing
- Layout: vertical (one entry per line, button below, default) or horizontal (side by side, the button as the
  last element of the row; wraps only when the screen is too narrow) — Settings → Display → Layout, at once
- Remembers what you show or hide here: after `/reload` every window you switched in PaTiSuite is as you left it.
  Windows you never switched here start as their addon starts them. Restore Defaults forgets this
- ••• menu: Settings, Lock, Collapse/Expand (only the header stays), Reset position, Hide. Settings: language,
  scale, lock, panel opacity, layout

No test mode: the panel only shows your real windows, there is nothing to simulate.

## Supported PaTi addons

PaTiSuite is optional and only a control panel. No other addon needs it; every PaTi addon works on its own, with or without it. It lists whichever of these are installed:

- **PaTiSuite** – optional control panel to show and hide the PaTi windows *(this addon)*
- [PaTiHeal](https://github.com/patpaskoch/PaTiHeal) – healing: party frames, heal target, click casting, HoTs, dispels
- [PaTiAuras](https://github.com/patpaskoch/PaTiAuras) – buffs, procs, tracking, group buffs and weapon imbues
- [PaTiTank](https://github.com/patpaskoch/PaTiTank) – tank HUD and aggro monitor
- [PaTiRota](https://github.com/patpaskoch/PaTiRota) – your own skill priority with cooldowns and fixed cast buttons
- [PaTiGroup](https://github.com/patpaskoch/PaTiGroup) – party awareness: tank, healer, roles and the tank's target
- [PaTiLead](https://github.com/patpaskoch/PaTiLead) – lead the group: raid markers, ready check and pull timer
- [PaTiQuest](https://github.com/patpaskoch/PaTiQuest) – selected quest and its objectives
- [PaTiDungeon](https://github.com/patpaskoch/PaTiDungeon) – instance, group and combat status
- [PaTiSocial](https://github.com/patpaskoch/PaTiSocial) – "Party Social": quick emote and message buttons
- [PaTiAlerts](https://github.com/patpaskoch/PaTiAlerts) – one window for open problems

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

## Development

Architecture, tests and engineering rules of the suite: [PaTiAdmin](https://github.com/patpaskoch/PaTiAdmin). PaTiAdmin is not a WoW addon — players do not install it. The shared UI code (PaTiShared) is already embedded in this addon's `Shared/` folder; there is nothing extra to install.

## License
MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Patrick Koch.
