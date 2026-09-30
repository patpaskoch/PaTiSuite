# Ingame Testing – PaTiSuite

World of Warcraft: Forever
Interface: 16001

Diese Datei dokumentiert ausschließlich Tests im echten WoW-Client.

Automatisierte Tests, CI und Code Review zählen NICHT als Ingame-Verifikation.
Regeln und Eintragen von Ergebnissen: [PaTiAdmin/docs/TESTING.md](https://github.com/patpaskoch/PaTiAdmin/blob/main/docs/TESTING.md#in-game-test-files).

## Legende

- [ ] offen / noch nicht bestätigt
- [x] vom Owner im echten Client bestätigt
- ❌ FAIL = im echten Client fehlgeschlagen
- 🔧 FIX IMPLEMENTED = Codefix vorhanden, Retest noch offen
- ✅ VERIFIED = erfolgreich im echten Client bestätigt
- MANUAL RETEST REQUIRED = erneuter Test notwendig

## Installation / Laden

- [ ] PT-SUITE-001 Fresh Install aus dem Release-ZIP: genau ein Ordner `PaTiSuite/`, Addon lädt allein
- [ ] PT-SUITE-002 PaTiSuite erscheint in der AddOn-Liste mit Beschreibung
- [ ] PT-SUITE-003 Icon (Zahnrad-Emblem) in der AddOn-Liste korrekt, keine weiße oder fehlende Textur
- [ ] PT-SUITE-004 Login ohne Lua-Fehler
- [ ] PT-SUITE-005 `/reload` ohne Lua-Fehler

## Grundfunktion / Fenster

- [ ] PT-SUITE-010 `/psuite` blendet das Steuerfenster ein und aus
- [ ] PT-SUITE-011 `/patisuite` funktioniert genauso
- [ ] PT-SUITE-012 `/psuite show` und `/psuite hide`
- [ ] PT-SUITE-013 Fenster am Header verschieben (entsperrt)
- [ ] PT-SUITE-014 Position bleibt nach `/reload`
- [ ] PT-SUITE-015 Lock/Unlock (••• und `/psuite lock` / `unlock`): gesperrt nicht verschiebbar
- [ ] PT-SUITE-016 ••• → Position zurücksetzen bzw. `/psuite reset`
- [ ] PT-SUITE-017 Einstellungen öffnen (`/psuite settings` und •••): Sprache, Größe, Sperren, Deckkraft
- [ ] PT-SUITE-018 Größe (Scale) wirkt sofort
- [ ] PT-SUITE-019 Panel-Deckkraft 30–100 %: nur der Hintergrund ändert sich, Header und Texte bleiben lesbar
- [ ] PT-SUITE-020 Keine Einrast-Einstellung mehr, Fenster frei verschiebbar

## Fensterliste

- [ ] PT-SUITE-030 Nur installierte und geladene PaTi-Addons erscheinen (getestet mit einem, zwei und allen sieben)
- [ ] PT-SUITE-031 Sichtbare Fenster werden als „Angezeigt“ erkannt
- [ ] PT-SUITE-032 Ausgeblendete Fenster werden als „Ausgeblendet“ erkannt, auch wenn sie im Addon selbst
  (z. B. `/pt hide`) ausgeblendet wurden

## Show / Hide

- [x] PT-SUITE-040 Klick auf eine Zeile blendet ein einzelnes ausgeblendetes Fenster ein
  - ✅ VERIFIED 2026-09-30
- [x] PT-SUITE-041 Klick auf eine Zeile blendet ein einzelnes sichtbares Fenster aus
  - ✅ VERIFIED 2026-09-30
- [x] PT-SUITE-042 „Alle anzeigen“ blendet alle PaTi-Fenster ein
  - ✅ VERIFIED 2026-09-30
- [x] PT-SUITE-043 „Alle ausblenden“ blendet alle PaTi-Fenster aus, das Steuerfenster selbst bleibt sichtbar
  - ✅ VERIFIED 2026-09-30
- [ ] PT-SUITE-044 `/psuite showall` und `/psuite hideall` wie die Buttons
- [ ] PT-SUITE-045 Im Kampf „Alle ausblenden“: Heal, Auras, Group bleiben und werden genannt
  („Heal: im Kampf nicht möglich“), Tank/Quest/Dungeon/Alerts werden ausgeblendet
- [ ] PT-SUITE-046 Im Kampf Klick auf die Heal-, Auras- oder Group-Zeile ändert nichts und nennt den Grund
- [ ] PT-SUITE-047 Ohne PaTiSuite verhalten sich alle anderen Addons unverändert

## UI

- [ ] PT-SUITE-050 Hover über einer Zeile: Hintergrund dunkler, Text hell und lesbar
  - ❌ FAIL 2026-09-30
  - Hover-Fläche verdeckte den Text (unlesbar).
  - 🔧 FIX IMPLEMENTED 2026-09-30
  - Hover-Fläche liegt jetzt hinter dem Text.
  - MANUAL RETEST REQUIRED
- [ ] PT-SUITE-051 Angezeigtes Fenster: grüner Punkt und „Angezeigt“
- [ ] PT-SUITE-052 Ausgeblendetes Fenster: grauer Punkt und „Ausgeblendet“, Name grau
- [ ] PT-SUITE-053 Tooltip der Zeile lesbar: Addon-Name und „Klicken, um dieses Fenster auszublenden/anzuzeigen.“

## SavedVariables

- [ ] PT-SUITE-060 Einstellungen (Sprache, Größe, Sperre, Deckkraft) bleiben nach `/reload`
- [ ] PT-SUITE-061 Einstellungen bleiben nach Relog
- [ ] PT-SUITE-062 „Standard wiederherstellen“ setzt die Einstellungen zurück

## Sprachen

- [ ] PT-SUITE-070 deDE: alle Texte deutsch
- [ ] PT-SUITE-071 Sprache enUS in den Einstellungen: nach `/reload` englisch
- [ ] PT-SUITE-072 zhCN/zhTW/koKR: Englisch als Rückfall, keine Schlüsselnamen oder Kästchen
- [ ] PT-SUITE-073 Keine abgeschnittenen wichtigen Texte (deDE)

## Combat / Sicherheit

- [ ] PT-SUITE-080 Kein Lua-Fehler bei Benutzung im Kampf
- [ ] PT-SUITE-081 Keine `ADDON_ACTION_BLOCKED` / `ADDON_ACTION_FORBIDDEN`
- [ ] PT-SUITE-082 `taint.log` (`/console taintLog 1`) ohne PaTiSuite-Eintrag

## Combined

- [ ] PT-SUITE-090 Zusammen mit allen PaTi-Addons geladen: kein Lua-Fehler
- [ ] PT-SUITE-091 Keine Slash-Command-Kollision: `/psuite` antwortet nur PaTiSuite
- [ ] PT-SUITE-092 Eigene Einstellungen speichern nur PaTiSuite-Werte

## Entfernt

- ~~PT-SUITE-900 Fenster rasten beim Verschieben an anderen PaTi-Fenstern ein~~
  - ❌ FAIL 2026-09-30 – Einrasten funktionierte nicht.
  - RETIRED 2026-09-30 – Feature entfernt (PaTiShared).
