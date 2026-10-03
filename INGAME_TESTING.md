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
- [x] PT-SUITE-003 Icon (Zahnrad-Emblem) in der AddOn-Liste korrekt, keine weiße oder fehlende Textur
  - ✅ VERIFIED 2026-10-02
  - Owner: die Icons erscheinen im Spiel in der AddOn-Liste korrekt.
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

- [ ] PT-SUITE-030 Nur installierte und geladene PaTi-Addons erscheinen (getestet mit einem, zwei und allen zehn)
- ~~PT-SUITE-031 Sichtbare Fenster werden als „Angezeigt“ erkannt~~
  - RETIRED 2026-10-02 – ausgeschriebener Status entfernt; Status nur noch per Farbpunkt (PT-SUITE-033).
- ~~PT-SUITE-032 Ausgeblendete Fenster werden als „Ausgeblendet“ erkannt (auch nach `/pt hide`)~~
  - RETIRED 2026-10-02 – ausgeschriebener Status entfernt; Status nur noch per Farbpunkt (PT-SUITE-034).
- [ ] PT-SUITE-033 Sichtbares Fenster: grüner Punkt, Name hell, kein „Angezeigt“-Text
- [ ] PT-SUITE-034 Ausgeblendetes Fenster: grauer Punkt, Name grau, kein „Ausgeblendet“-Text — auch wenn es im Addon
  selbst (z. B. `/pt hide`) ausgeblendet wurde
- [ ] PT-SUITE-035 Reihenfolge: Heal, Auras, Tank, Rota, Group, Lead, Quest, Dungeon, Social, Alerts (nur die installierten)
- [ ] PT-SUITE-036 „Group“ (neue Gruppenübersicht) und „Lead“ (Marker, Ready Check) sind zwei getrennte Einträge;
  jeder blendet nur sein eigenes Fenster ein/aus
- [ ] PT-SUITE-037 Update von der alten Installation: war „Group“ (altes Marker-Addon) in PaTiSuite ausgeblendet, ist
  danach „Lead“ ausgeblendet und das neue „Group“ startet normal sichtbar

## Show / Hide

- [x] PT-SUITE-040 Klick auf eine Zeile blendet ein einzelnes ausgeblendetes Fenster ein
  - ✅ VERIFIED 2026-09-30
- [x] PT-SUITE-041 Klick auf eine Zeile blendet ein einzelnes sichtbares Fenster aus
  - ✅ VERIFIED 2026-09-30
- ~~PT-SUITE-042 „Alle anzeigen“ blendet alle PaTi-Fenster ein~~
  - ✅ VERIFIED 2026-09-30
  - RETIRED 2026-09-30 – die zwei Buttons wurden durch einen dynamischen Button ersetzt (PT-SUITE-048).
- ~~PT-SUITE-043 „Alle ausblenden“ blendet alle PaTi-Fenster aus, das Steuerfenster selbst bleibt sichtbar~~
  - ✅ VERIFIED 2026-09-30
  - RETIRED 2026-09-30 – ersetzt durch PT-SUITE-048.
- [ ] PT-SUITE-044 `/psuite showall` und `/psuite hideall` wie die Buttons
- [ ] PT-SUITE-045 Im Kampf „Alle ausblenden“ (Button oder `/psuite hideall`): Heal, Auras, Rota, Lead bleiben und werden genannt
  („Heal: im Kampf nicht möglich“), Tank/Quest/Dungeon/Alerts werden ausgeblendet
- [ ] PT-SUITE-046 Im Kampf Klick auf die Heal-, Auras-, Rota- oder Lead-Zeile ändert nichts und nennt den Grund (Group geht auch im Kampf)
- [ ] PT-SUITE-047 Ohne PaTiSuite verhalten sich alle anderen Addons unverändert
- [ ] PT-SUITE-048 Ein Button für alle: sind alle Fenster sichtbar, heißt er „Alle ausblenden“ und blendet alle aus
  (das Steuerfenster bleibt); ist mindestens eines ausgeblendet, heißt er „Alle einblenden“ und blendet alle ein;
  die Beschriftung wechselt nach jedem Klick und nach einzelnem Ein-/Ausblenden
  - Owner 2026-10-02 (Teilbefund): „Alle ausblenden“ blendet alle Fenster korrekt aus; Rest offen.
- [ ] PT-SUITE-049 Einzelnes Ein-/Ausblenden (PT-SUITE-040/041) funktioniert nach dem Umbau weiter

## UI

- [x] PT-SUITE-050 Hover über einer Zeile: Hintergrund dunkler, Text hell und lesbar
  - ❌ FAIL 2026-09-30
  - Hover-Fläche verdeckte den Text (unlesbar).
  - 🔧 FIX IMPLEMENTED 2026-09-30
  - Hover-Fläche liegt jetzt hinter dem Text.
  - ✅ VERIFIED 2026-09-30
  - Retest: Lesbarkeit und Farben passen.
- ~~PT-SUITE-051 Angezeigtes Fenster: grüner Punkt und „Angezeigt“~~
  - ✅ VERIFIED 2026-09-30
  - RETIRED 2026-10-02 – ausgeschriebener Status entfernt; Status nur noch per Farbpunkt (PT-SUITE-033).
- ~~PT-SUITE-052 Ausgeblendetes Fenster: grauer Punkt und „Ausgeblendet“, Name grau~~
  - ✅ VERIFIED 2026-09-30
  - RETIRED 2026-10-02 – ausgeschriebener Status entfernt; Status nur noch per Farbpunkt (PT-SUITE-034).
- [ ] PT-SUITE-053 Tooltip der Zeile lesbar: Addon-Name und „Klicken, um dieses Fenster auszublenden/anzuzeigen.“
- [ ] PT-SUITE-054 Hover nach dem Umbau (kompakte Einträge) weiterhin lesbar, vertikal und horizontal

## Vertikal (Standard)

- [ ] PT-SUITE-100 Kompakte vertikale Darstellung, deutlich schmaler als vorher, kein leerer Platz rechts
- [ ] PT-SUITE-101 Alle installierten Addons sichtbar, je Punkt + kurzer Name, keine abgeschnittenen Namen
- [ ] PT-SUITE-102 Klick auf einen Eintrag (ganze Zeile) blendet genau dieses Fenster ein bzw. aus
- [ ] PT-SUITE-103 Der „Alle“-Button passt ins Fenster und funktioniert (PT-SUITE-048)

## Horizontal

- [ ] PT-SUITE-110 Einstellungen → Darstellung → Layout „Horizontal“: wirkt sofort, ohne `/reload`
- [ ] PT-SUITE-111 Einträge stehen nebeneinander, jeder nur so breit wie Punkt + Name, keine Überlappung
  - Owner 2026-10-02 (Teilbefund): die Addons stehen horizontal schön inline; Rest offen.
- [ ] PT-SUITE-112 Jeder Eintrag einzeln anklickbar, blendet genau sein Fenster ein/aus
- [ ] PT-SUITE-113 Statusfarben (grün/grau), Hover und Tooltip wie vertikal
- [ ] PT-SUITE-114 Keine abgeschnittenen Namen; Fenster breiter und niedriger als vertikal
- [ ] PT-SUITE-115 „Alle“-Button funktioniert horizontal
- [ ] PT-SUITE-116 Zurück auf „Vertikal“: wirkt sofort, Position springt nicht unnötig
- [ ] PT-SUITE-117 Horizontal: alle Addons und der Button „Alle ausblenden/einblenden“ in einer Reihe, Button am
  Ende, vollständig lesbar, Klick funktioniert; nach dem Klick (andere Beschriftung) bleibt die Reihe sauber
- [ ] PT-SUITE-118 deDE und enUS: keine Überlappung; Größe 0,8 / 1,0 / 1,25 sinnvoll
- [ ] PT-SUITE-119 Kleine Bildschirmbreite oder große Skalierung: die Reihe bricht sauber um (Button wandert mit),
  nichts ragt aus dem Bildschirm

## Layout-Persistenz

- [ ] PT-SUITE-120 Horizontal einstellen → `/reload` → bleibt horizontal
- [ ] PT-SUITE-121 Vertikal einstellen → `/reload` → bleibt vertikal
- [ ] PT-SUITE-122 Update von einer alten Version: Sprache, Größe, Sperre, Deckkraft und Position bleiben, Layout ist
  vertikal und ausgeklappt

## Collapse

- [ ] PT-SUITE-125 ••• → „Einklappen“: nur der Header bleibt, keine Einträge, kein Button, kein Hinweis
- [ ] PT-SUITE-126 ••• → „Ausklappen“: Inhalt wieder sichtbar
- [ ] PT-SUITE-127 Eingeklappter Zustand bleibt nach `/reload`
- [ ] PT-SUITE-128 Collapse funktioniert vertikal und horizontal, auch im Kampf ohne Fehler

## Sichtbarkeit über /reload

- [ ] PT-SUITE-130 „Alle ausblenden“ → `/reload` → alle bleiben ausgeblendet, PaTiSuite selbst bleibt sichtbar
  und bedienbar
- [ ] PT-SUITE-131 „Alle einblenden“ → `/reload` → alle bleiben sichtbar
- [ ] PT-SUITE-132 Ein einzelnes Addon über PaTiSuite ausblenden → `/reload` → bleibt ausgeblendet
- [ ] PT-SUITE-133 Mischzustand (z. B. Heal aus, Tank an, Quest aus) → `/reload` → derselbe Mischzustand
- [ ] PT-SUITE-134 Im Kampf „Alle ausblenden“: Heal/Auras/Rota/Lead bleiben (Hinweis) → nach dem Kampf `/reload` →
  Heal/Auras/Rota/Lead sind nicht als ausgeblendet gespeichert, die anderen schon
- [ ] PT-SUITE-135 Ein Fenster, das nur im Addon selbst ausgeblendet wurde (z. B. `/pt hide`), wird nicht
  gespeichert: nach `/reload` startet es wie das Addon es startet
- [ ] PT-SUITE-136 „Standard wiederherstellen“ vergisst die gespeicherte Sichtbarkeit: nach `/reload` starten alle
  Fenster wieder wie ihr Addon sie startet

## Tooltips (PaTiShared)

- [ ] PT-SUITE-140 Steuerfenster in der linken Bildschirmhälfte: Tooltip einer Zeile steht rechts daneben, der
  Punkt und der Name bleiben sichtbar
- [ ] PT-SUITE-141 Steuerfenster in der rechten Hälfte: Tooltip steht links daneben
- [ ] PT-SUITE-142 ••• -Button: Tooltip neben dem Button, Menü öffnet weiter; Klick und Hover auf Zeilen unverändert
- [ ] PT-SUITE-143 Tooltip am oberen/unteren Bildschirmrand bleibt vollständig sichtbar; kein Lua-Fehler

## Fenster-Header (PaTiShared)

- [ ] PT-SUITE-150 Titel in mehreren Fenstern (z. B. Heal, Auras, Tank, Suite): sichtbar und lesbar, aber deutlich
  ruhiger als vorher (kleiner, grau, leicht transparent)
- [ ] PT-SUITE-151 Gameplay-Inhalte unverändert kräftig: Lebensbalken, Warnungen, Aura-Texte, Aggro-Zeilen
- [ ] PT-SUITE-152 Einstellungsfenster (Modals): Titel normal hell, nicht ausgegraut
- [ ] PT-SUITE-153 ••• ist ruhig, beim Hover voll sichtbar und bedienbar; TEST-Badge im Test Mode gut sichtbar
- [ ] PT-SUITE-154 Im Kampf am Header verschieben: Tank, Group, Quest, Dungeon, Social, Alerts und Suite lassen sich ziehen,
  Heal, Auras, Rota und Lead nicht (Secure-Buttons); kein Lua-Fehler, kein `ADDON_ACTION_BLOCKED`; gesperrte Fenster nie

## Themes (alle Fenster)

- [ ] PT-SUITE-160 Default: alle PaTi-Fenster sehen aus wie vor den Themes (Farben, Rahmen, Hover, Akzent-Blau)
- [ ] PT-SUITE-161 Einstellungen → Fenster → Theme „WoForever“ in einem Addon: warmes Braun, Gold-/Bronzerahmen, gut lesbar;
  gleiche Größen und Positionen wie Default
- [ ] PT-SUITE-162 Theme „Dracula“: dunkel, Lila-Akzent, rosa Hover-Rahmen, Mana cyan; Warnung/Gefahr/Erfolg klar
  unterscheidbar; gleiche Geometrie
- [ ] PT-SUITE-163 Theme bleibt pro Addon nach `/reload` und Relog; „Standard wiederherstellen“ setzt es auf Default
- [ ] PT-SUITE-164 PaTiSuite → Einstellungen → Theme: alle geladenen PaTi-Fenster wechseln gemeinsam; jedes behält das Theme
  nach `/reload` (jedes Addon speichert es selbst)
- [ ] PT-SUITE-165 Theme-Wechsel betrifft auch Menüs, Einstellungsfenster, Tooltips-Farben, Buttons (Hover, gesperrt),
  Checkboxen und das TEST-Badge; keine Fläche bleibt in der alten Farbe
- [ ] PT-SUITE-166 Theme-Wechsel im Kampf: kein Lua-Fehler, kein `ADDON_ACTION_BLOCKED`; Secure-Fenster (Heal, Auras, Rota,
  Lead) funktionieren danach unverändert

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
